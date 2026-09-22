"""strata reward | pick | test

strata reward <benchmark> <encoding.lp>     train split at the fitness cap; a wrong answer costs 1
strata pick   <benchmark> <a.lp> <b.lp> ...  best validation score among sound candidates
strata test   <benchmark> <encoding.lp>     test split at the reporting cap, then the pool at the
                                            fitness cap; a wrong answer on test gives score 0

Options: --workers N, --out result.json, reward --wrong-penalty P, test --cap N and --lenient.
"""

import argparse
import json
import sys

from .score import Benchmark, score


def reward(args, bench):
    train = score(bench, args.encoding, "train", workers=args.workers,
                  wrong_penalty=args.wrong_penalty)

    print(f"{bench.id} train@{train['cap']}s: score {train['score']}  "
          f"passed {train['passed']}/{train['n']}  wrong {train['wrong']}  PAR2 {train['par2']}")

    return {"split": "train", "wrong_penalty": args.wrong_penalty, "score": train["score"],
            "train": train}


def pick(args, bench):
    results = {}
    for candidate in args.candidates:
        result = score(bench, candidate, "validate", workers=args.workers)
        results[candidate] = {k: v for k, v in result.items() if k != "instances"}
        print(f"  {candidate}: validation score {result['score']}  "
              f"passed {result['passed']}/{result['n']}  wrong {result['wrong']}")

    sound = [c for c in results if results[c]["wrong"] == 0] or list(results)
    best = max(sound, key=lambda c: (results[c]["score"], -results[c]["solved_seconds"]))
    note = "" if results[best]["wrong"] == 0 else "  (every candidate has a wrong answer)"

    print(f"pick: {best}{note}")
    return {"split": "validate", "pick": best, "candidates": results}


def test(args, bench):
    cap = args.cap or bench.cap("reporting")
    result = score(bench, args.encoding, "test", cap=cap, workers=args.workers)
    wrong = sorted(name for name, row in result["instances"].items() if row["wrong"])
    line = (f"{bench.id} test@{cap}s: passed {result['passed']}/{result['n']}  "
            f"wrong {result['wrong']}  PAR2 {result['par2']}")

    if wrong and not args.lenient:
        result["raw_score"], result["score"], result["disqualified"] = result["score"], 0.0, wrong
        line += f"  DISQUALIFIED (wrong on {', '.join(wrong)})"
    print(f"{line}  score {result['score']}")

    pool = score(bench, args.encoding, "pool", workers=args.workers)
    print(f"{bench.id} pool@{pool['cap']}s: passed {pool['passed']}/{pool['n']}  "
          f"wrong {pool['wrong']}  PAR2 {pool['par2']}")

    return {"reporting_cap": cap, "strict": not args.lenient, "test": result, "pool": pool}


def main(argv=None):
    args = parse_arguments(argv)
    bench = Benchmark(args.benchmark)

    result = {"benchmark": bench.id, "encoding": getattr(args, "encoding", None)}
    result.update(args.command(args, bench))

    if args.out:
        with open(args.out, "w") as f:
            f.write(json.dumps(result, indent=1) + "\n")

    return 0


def parse_arguments(argv):
    parser = argparse.ArgumentParser(
        prog="strata",
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    commands = parser.add_subparsers(required=True)

    reward_parser = add_command(commands, "reward", reward)
    reward_parser.add_argument("encoding")
    reward_parser.add_argument("--wrong-penalty", type=float, default=1.0)

    pick_parser = add_command(commands, "pick", pick)
    pick_parser.add_argument("candidates", nargs="+")

    test_parser = add_command(commands, "test", test)
    test_parser.add_argument("encoding")
    test_parser.add_argument("--cap", type=int)
    test_parser.add_argument("--lenient", action="store_true")

    return parser.parse_args(argv)


def add_command(commands, name, function):
    """A sub-command with the options every command shares."""
    command = commands.add_parser(name)
    command.add_argument("benchmark")
    command.add_argument("--workers", type=int, default=1)
    command.add_argument("--out")
    command.set_defaults(command=function)
    return command


if __name__ == "__main__":
    sys.exit(main())
