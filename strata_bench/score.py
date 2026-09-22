"""Score an encoding on a benchmark: score = passed - PAR2 / (2 * n * cap + 1).

An answer passes when it is right:
  SAT     validate.py accepts it and the reference did not prove UNSAT. Without a validator, only
          instances the reference proved SAT can pass. On an optimisation benchmark the answer must
          also cost no more than the reference's answer at the same cap.
  UNSAT   the reference proved UNSAT.
A wrong answer (rejected, or against the reference's proof) is counted in `wrong`.
PAR2 charges 2 * cap for every instance not passed, so time only breaks ties.
"""

import concurrent.futures
import contextlib
import importlib.util
import json
import pathlib
import re
import subprocess
import sys
import tempfile
import time

SPLITS = ("train", "validate", "test")
FORBIDDEN = ("#script", "#include", "#external", "#heuristic")   # not pure ASP: scores 0

MEMORY_CAP_MB = 6000          # one clingo run
MEMORY_BUDGET_MB = 36000      # all parallel runs together
BACKSTOP_SECONDS = 20         # kill a run this long after its own time limit

ANSWER = re.compile(r"^Answer: \d+[^\n]*\n(.*)$", re.M)
SOLVING = re.compile(r"Solving:\s*([\d.]+)s")
COUNTER = re.compile(r"^(Rules|Choices|Conflicts)\s*:\s*(\d+)", re.M)
OPTIMIZATION = re.compile(r"^Optimization\s*:\s*([-\d ]+)$", re.M)


class Benchmark:
    """A benchmark directory: seeds/, validate.py, instances/<split>/ and metadata.json. The seed is
    seeds/<id>.lp; seeds/reference.lp, where present, is the reference, and otherwise the seed is."""

    def __init__(self, path):
        self.dir = pathlib.Path(path).resolve()
        self.id = self.dir.name
        self.seed = self.dir / "seeds" / f"{self.id}.lp"
        reference = self.dir / "seeds" / "reference.lp"
        self.reference_encoding = reference if reference.exists() else self.seed

        meta = self.dir / "metadata.json"
        self.meta = json.loads(meta.read_text()) if meta.exists() else {}

        self.validate = load_validator(self.dir / "validate.py")

    def instances(self, split):
        splits = SPLITS if split == "pool" else [split]
        return [p for s in splits for p in sorted((self.dir / "instances" / s).glob("*.lp"))]

    def cap(self, which):
        return int(self.meta["caps"][which])

    def reference(self, name):
        return self.meta.get("instances", {}).get(name, {}).get("verdict", "UNKNOWN")

    def reference_cost(self, name, cap):
        return self.meta.get("instances", {}).get(name, {}).get("cost", {}).get(str(cap))


def load_validator(path):
    if not path.exists():
        return None

    spec = importlib.util.spec_from_file_location(f"validate_{path.parent.name}", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.validate


def run(encoding, instance, cap, memory_cap_mb=MEMORY_CAP_MB):
    """Run clingo once. Returns the verdict (SAT, UNSAT, TIMEOUT, MEMOUT or ERROR), the seconds
    taken, clingo's counters and the model text."""
    command = [sys.executable, "-m", "clingo", str(encoding), str(instance),
               "--warn=none", f"--time-limit={cap}", "--stats"]

    start = time.perf_counter()
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err, killed, peak = watch(process, start, cap, memory_cap_mb)
    elapsed = round(time.perf_counter() - start, 3)

    verdict = killed or read_verdict(out, err)
    undecided = verdict in ("TIMEOUT", "MEMOUT")
    solving = SOLVING.search(out)
    solving_seconds = float(solving.group(1)) if solving else None
    models = ANSWER.findall(out)

    record = {
        "verdict": verdict,
        "seconds": float(cap) if undecided else elapsed,
        "solving_seconds": solving_seconds,
        "grounding_bound": undecided and (solving_seconds or 0.0) < 0.05,
        "peak_rss_mb": round(peak),
        "error": err.strip().splitlines()[0][:160] if verdict == "ERROR" else "",
        "model": models[-1] if verdict == "SAT" and models else "",
    }

    for name, value in COUNTER.findall(out):
        record[name.lower()] = int(value)
    return record


def watch(process, start, cap, memory_cap_mb):
    """Wait for clingo; kill it past the backstop or the memory cap.
    Returns (out, err, killed, peak MB)."""
    peak, polls = 0.0, 0

    while True:
        try:
            out, err = process.communicate(timeout=0.05)
            return out or "", err or "", None, peak
        except subprocess.TimeoutExpired:
            polls += 1

        if polls % 5 == 0:
            peak = max(peak, resident_mb(process.pid))
        if time.perf_counter() - start > cap + BACKSTOP_SECONDS:
            killed = "TIMEOUT"
        elif peak > memory_cap_mb:
            killed = "MEMOUT"
        else:
            continue

        process.kill()
        out, err = process.communicate()
        return out or "", err or "", killed, peak


def resident_mb(pid):
    ps = subprocess.run(["ps", "-o", "rss=", "-p", str(pid)], capture_output=True, text=True)
    return int(ps.stdout.strip() or 0) / 1024


def read_verdict(out, err):
    if "INTERRUPTED" in err or "shutdown signal" in err:
        return "TIMEOUT"          # the time limit stopped the run (pyclingo may call it an error)
    if "error" in err.lower() and "SATISFIABLE" not in out:
        return "ERROR"

    if "UNSATISFIABLE" in out:
        return "UNSAT"
    if "SATISFIABLE" in out or "OPTIMUM FOUND" in out or ANSWER.search(out):
        return "SAT"
    return "TIMEOUT"


def judge(record, reference, instance, validate, reference_cost=None):
    """Set counted, wrong, note and cost on a run record, and drop its model text."""
    model = record.pop("model")
    record.update(counted=False, wrong=False, note="", cost=None)

    if record["verdict"] == "UNSAT":
        if reference == "UNSAT":
            record["counted"] = True
        elif reference == "SAT":
            record.update(wrong=True, note="UNSAT, but the reference proved SAT")
        else:
            record["note"] = "UNSAT on an instance the reference did not decide: not counted"
        return record

    if record["verdict"] != "SAT":
        return record

    if validate is None and reference != "SAT":
        record["note"] = "no validator, and the reference did not prove SAT: not counted"
        return record

    ok, why, cost = check(validate, instance, model)
    record["cost"] = cost
    if not ok:
        record.update(wrong=True, note=f"witness rejected: {why}")
    elif reference == "UNSAT":
        record.update(wrong=True, note="SAT, but the reference proved UNSAT")
    elif reference_cost is not None and (cost is None or cost > reference_cost):
        record["note"] = f"valid, but costs {cost} against the reference's {reference_cost}"
    else:
        record["counted"] = True
    return record


def check(validate, instance, model):
    """(ok, why, cost) from a validator returning (ok, why) or (ok, why, cost)."""
    if validate is None:
        return True, "", None

    result = validate(str(instance), model)
    cost = result[2] if len(result) > 2 else None
    return result[0], result[1], cost


def score(bench, encoding, split, cap=None, workers=1, wrong_penalty=0.0):
    """Score one encoding on one split: "train", "validate", "test", or "pool" for all three."""
    encoding = pathlib.Path(encoding).resolve()
    cap = cap or bench.cap("fitness")
    instances = bench.instances(split)
    n = len(instances)

    result = {
        "passed": 0,
        "wrong": 0,
        "n": n,
        "par2": 2.0 * cap * n,
        "score": 0.0,
        "solved_seconds": 0.0,
        "cap": cap,
        "guard": "ok",
        "instances": {},
    }

    directive = forbidden_directive(encoding)
    if directive:
        result["guard"] = f"rejected: {directive}"
        return result

    # parallel runs share the memory budget
    memory_cap = max(1000, min(MEMORY_CAP_MB, MEMORY_BUDGET_MB // max(1, workers)))

    def run_and_judge(instance):
        record = run(encoding, instance, cap, memory_cap)
        reference = bench.reference(instance.name)
        reference_cost = bench.reference_cost(instance.name, cap)
        return instance.name, judge(record, reference, instance, bench.validate, reference_cost)

    with concurrent.futures.ThreadPoolExecutor(max(1, workers)) as pool:
        rows = dict(pool.map(run_and_judge, instances))

    passed = [row for row in rows.values() if row["counted"]]
    wrong = sum(row["wrong"] for row in rows.values())
    solved_seconds = sum(row["seconds"] for row in passed)
    par2 = solved_seconds + 2.0 * cap * (n - len(passed))

    result["passed"] = len(passed)
    result["wrong"] = wrong
    result["par2"] = round(par2, 3)
    result["solved_seconds"] = round(solved_seconds, 3)
    result["instances"] = rows

    if passed:
        value = len(passed) - wrong_penalty * wrong - par2 / (2.0 * n * cap + 1.0)
        result["score"] = round(max(0.0, value), 4)
    return result


def forbidden_directive(encoding):
    text = pathlib.Path(encoding).read_text(errors="replace")
    text = re.sub(r"%\*.*?\*%", "", text, flags=re.S)     # block comments
    text = re.sub(r"%.*", "", text)                        # line comments

    return next((d for d in FORBIDDEN if d in text), None)


def check_with_program(checker, instance, model, outputs, cap=120):
    """The answer passes a checking program. Only its output atoms reach the checker: an auxiliary
    atom given as a fact could satisfy the checker's constraints."""
    facts = "".join(f"{atom}.\n" for atom in output_atoms(model, outputs))
    with temporary_file(facts) as witness:
        out = clingo([checker, instance, witness], cap)

    ok = "SATISFIABLE" in out and "UNSATISFIABLE" not in out
    return ok, "" if ok else "the checking program rejects the answer"


def check_with_reference(reference, instance, model, outputs, cap=60):
    """The answer is exactly one of the reference encoding's solutions. Returns (ok, why, cost);
    cost is the answer's value under the reference's objective, or None without one."""
    atoms = output_atoms(model, outputs)
    if not atoms:
        return False, "the answer has none of the output atoms", None

    # the answer's atoms become given_ facts, and each output predicate must match them exactly
    rules = [f"given_{atom}." for atom in atoms]
    signatures = {(atom.split("(")[0], arity_of(atom)) for atom in atoms}
    for predicate, arity in sorted(signatures):
        variables = ",".join(f"X{i}" for i in range(arity))
        pattern = f"{predicate}({variables})" if arity else predicate
        rules.append(f":- given_{pattern}, not {pattern}.")
        rules.append(f":- {pattern}, not given_{pattern}.")

    with temporary_file("\n".join(rules)) as extra:
        out = clingo([reference, instance, extra], cap)
    if "UNSATISFIABLE" in out:
        return False, "the reference encoding rejects the answer", None
    if "SATISFIABLE" not in out and "OPTIMUM FOUND" not in out:
        return False, "undecided: the reference could not check the answer in time", None

    costs = OPTIMIZATION.findall(out)
    if not costs:
        return True, "", None
    return True, "", [int(value) for value in costs[-1].split()]


def output_atoms(model, outputs):
    return [atom for atom in model.split() if atom.split("(")[0] in outputs]


def arity_of(atom):
    if "(" not in atom:
        return 0

    depth, arity = 0, 1
    for char in atom[atom.index("(") + 1:-1]:
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        elif char == "," and depth == 0:
            arity += 1

    return arity


def clingo(files, cap):
    options = ["--warn=none", "-q", f"--time-limit={cap}"]
    command = [sys.executable, "-m", "clingo", *map(str, files), *options]
    return subprocess.run(command, capture_output=True, text=True).stdout


@contextlib.contextmanager
def temporary_file(text):
    with tempfile.NamedTemporaryFile("w", suffix=".lp", delete=False) as f:
        f.write(text)

    try:
        yield f.name
    finally:
        pathlib.Path(f.name).unlink(missing_ok=True)
