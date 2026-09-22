"""strata-calibrate: run the reference encoding on a benchmark and write metadata.json.

Usage:
    strata-calibrate <benchmark> [--survey-cap 120] [--reporting-cap N] [--workers 4] [--force]

metadata.json holds:
    caps        The time limits. The survey cap is --survey-cap. The fitness cap is the 60th
                percentile of the reference's times on the instances it decides, at least 5 s.
                The reporting cap is --reporting-cap, else the one metadata.json already has,
                else 120 s.
    instances   For each instance: its split, the reference's verdict (SAT, UNSAT or UNKNOWN)
                and the reference run's measurements. On optimisation benchmarks, also the
                reference's cost at each cap it ran with.
    encodings   The seed and, where it differs, the reference, scored on every split.
    selftest    Whether the validator accepts the reference's answer, and rejects an empty
                answer and an answer with one atom removed.

An existing metadata.json is only replaced with --force.
"""

import argparse
import datetime
import json
import platform
import subprocess
import sys

from . import score as S


def main(argv=None):
    args = parse_arguments(argv)
    bench = S.Benchmark(args.benchmark)
    if (bench.dir / "metadata.json").exists() and not args.force:
        print("metadata.json exists; use --force to measure again")
        return 1

    reference = bench.reference_encoding
    bench.meta = {"caps": starting_caps(bench, args)}

    survey = run_survey(bench, reference, args.survey_cap, args.workers)
    bench.meta["caps"]["fitness"] = fitness_cap(survey, args.survey_cap)
    say(f"caps {bench.meta['caps']}")
    bench.meta["instances"] = describe_instances(bench, survey)
    keep_costs(bench, survey, args.survey_cap)

    encodings = score_encodings(bench, args.workers)
    test = selftest(bench, reference, survey)
    say(f"validator self-test: {test}")

    write_metadata(bench, encodings, test, args.workers)
    say("wrote metadata.json")
    return 0


def parse_arguments(argv):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("benchmark")
    parser.add_argument("--survey-cap", type=int, default=120)
    parser.add_argument("--reporting-cap", type=int)
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--force", action="store_true")
    return parser.parse_args(argv)


def starting_caps(bench, args):
    """The reporting cap is --reporting-cap, else the one metadata.json already has, else 120 s."""
    reporting = args.reporting_cap or bench.meta.get("caps", {}).get("reporting", 120)
    return {"survey": args.survey_cap, "fitness": 5, "reporting": int(reporting)}


def run_survey(bench, reference, survey_cap, workers):
    """Run the reference on every instance at the survey cap."""
    count = len(bench.instances("pool"))
    say(f"{bench.id}: reference on {count} instances at {survey_cap}s")
    result = S.score(bench, reference, "pool", cap=survey_cap, workers=workers)
    return result["instances"]


def fitness_cap(survey, survey_cap):
    """The 60th percentile of the reference's times on the instances it decides, at least 5 s."""
    times = [run["seconds"] for run in survey.values() if run["verdict"] in ("SAT", "UNSAT")]
    if not times:
        return survey_cap

    times.sort()
    percentile_60 = times[int(len(times) * 0.6)]
    return max(5, int(round(percentile_60)))


def describe_instances(bench, survey):
    """For each instance: its split, the reference's verdict and the reference run's
    measurements."""
    split_of = {}
    for split in S.SPLITS:
        for path in bench.instances(split):
            split_of[path.name] = split

    instances = {}
    for name, run in survey.items():
        decided = run["verdict"] in ("SAT", "UNSAT")
        instances[name] = {
            "split": split_of[name],
            "verdict": run["verdict"] if decided else "UNKNOWN",
            "seconds": run["seconds"],
            "solving_seconds": run["solving_seconds"],
            "grounding_bound": run["grounding_bound"],
            "peak_rss_mb": run["peak_rss_mb"],
        }
    return instances


def score_encodings(bench, workers):
    """Score the seed and, where it differs, the reference on every split, and on test at the
    reporting cap."""
    reporting = bench.meta["caps"]["reporting"]
    paths = {"seed": bench.seed}
    if bench.reference_encoding != bench.seed:
        paths["reference"] = bench.reference_encoding

    encodings = {}
    for role, path in paths.items():
        results = {}
        for split in S.SPLITS:
            results[split] = S.score(bench, path, split, workers=workers)

        at_reporting = S.score(bench, path, "test", cap=reporting, workers=workers)
        results["test_at_reporting_cap"] = at_reporting

        if path == bench.reference_encoding:
            for result in results.values():
                keep_costs(bench, result["instances"], result["cap"])

        encodings[role] = {"file": str(path.relative_to(bench.dir)), "results": results}
        say(f"{role}: {summary(results, reporting)}")
    return encodings


def summary(results, reporting):
    parts = []
    for split in S.SPLITS:
        parts.append(f"{split} {results[split]['passed']}/{results[split]['n']}")
    parts.append(f"test@{reporting}s {results['test_at_reporting_cap']['passed']}")
    return "  ".join(parts)


def keep_costs(bench, runs, cap):
    """On optimisation benchmarks, record the reference's cost on each instance at this cap."""
    for name, run in runs.items():
        if run.get("cost") is None:
            continue
        costs = bench.meta["instances"][name].setdefault("cost", {})
        costs[str(cap)] = run["cost"]


def selftest(bench, reference, survey, limit=8):
    """On up to `limit` instances the reference solved: the validator must accept the reference's
    answer, reject an empty answer, and reject the answer with one atom removed (one atom of each
    predicate is tried, and any rejection counts)."""
    if bench.validate is None:
        return None

    counts = {"instances": 0, "accept_witness": 0, "reject_one_atom_removed": 0, "reject_empty": 0}
    for instance in bench.instances("pool"):
        if counts["instances"] >= limit or survey[instance.name]["verdict"] != "SAT":
            continue
        answer = S.run(reference, instance, bench.cap("survey"))["model"]
        if not answer:
            continue

        counts["instances"] += 1

        if accepts(bench, instance, answer):
            counts["accept_witness"] += 1
        if not accepts(bench, instance, ""):
            counts["reject_empty"] += 1

        smaller_answers = without_one(answer)
        if any(not accepts(bench, instance, smaller) for smaller in smaller_answers):
            counts["reject_one_atom_removed"] += 1

    checks = ("accept_witness", "reject_one_atom_removed", "reject_empty")
    all_checks_hold = all(counts[check] == counts["instances"] for check in checks)
    counts["pass"] = counts["instances"] > 0 and all_checks_hold
    return counts


def accepts(bench, instance, answer):
    result = bench.validate(str(instance), answer)
    return bool(result[0])


def without_one(answer):
    """The answer with one atom removed, once for each predicate that appears in it."""
    atoms = answer.split()
    seen = set()
    smaller = []

    for index, atom in enumerate(atoms):
        predicate = atom.split("(")[0]
        if predicate in seen:
            continue
        seen.add(predicate)
        smaller.append(" ".join(atoms[:index] + atoms[index + 1:]))

    return smaller


def write_metadata(bench, encodings, test, workers):
    meta = {
        "id": bench.id,
        "generated": f"{datetime.datetime.now():%Y-%m-%d %H:%M}",
        "measurement": machine(workers),
        "caps": bench.meta["caps"],
        "instances": bench.meta["instances"],
        "encodings": encodings,
        "validator_selftest": test,
    }

    path = bench.dir / "metadata.json"
    path.write_text(json.dumps(meta, indent=1) + "\n")


def machine(workers):
    """Where and how the measurements were taken."""
    import clingo

    return {
        "clingo": clingo.__version__,
        "python": platform.python_version(),
        "os": platform.platform(),
        "cores": int(sysctl("hw.ncpu") or 0),
        "memory_gb": round(int(sysctl("hw.memsize") or 0) / 2**30),
        "load_1min": float(sysctl("vm.loadavg").split()[1]),
        "workers": workers,
        "memory_cap_mb": S.MEMORY_CAP_MB,
        "backstop_seconds": S.BACKSTOP_SECONDS,
    }


def sysctl(key):
    result = subprocess.run(["sysctl", "-n", key], capture_output=True, text=True)
    return result.stdout.strip()


def say(text):
    print(f"[{datetime.datetime.now():%H:%M}] {text}", flush=True)


if __name__ == "__main__":
    sys.exit(main())
