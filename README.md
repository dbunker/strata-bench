# strata-bench

Benchmarks for constraint and logic programming that any harness can use. Each benchmark has a frozen instance split,
the published encoding, a validator, and the reference encoding's results on every instance. The scorer answers one
question: does a new encoding solve more instances than the published one, on instances it never saw?

## Layout

```text
strata_bench/score.py       run clingo with time and memory caps, judge each answer, compute the score
strata_bench/cli.py         strata reward | pick | test
strata_bench/calibrate.py   strata-calibrate: reference verdicts, caps and metadata.json
benchmarks/<category>/<id>/
  README.md                 description, task, source and split, in the same sections for every benchmark
  metadata.json             written by strata-calibrate
  seeds/<id>.lp             the seed: the published encoding, comments kept
  seeds/reference.lp        the reference, where it differs from the seed
  validate.py               validate(instance, model) -> (ok, why) or (ok, why, cost)
  checker.lp                where validate.py runs a checking program
  instances/train/ validate/ test/
```

## Score

`score = passed - PAR2 / (2 * n * cap + 1)`

- An answer passes when the validator accepts it and it agrees with the reference's verdict. Where the reference did
  not decide, an accepted SAT answer passes and an UNSAT claim does not.
- On an optimisation benchmark, an answer passes only if it costs no more than the reference's answer at the same cap.
- PAR2 charges twice the cap for every instance not passed, so time only breaks ties.
- A wrong answer costs one point in `strata reward` and makes the score 0 in `strata test`.
- An encoding that uses `#script`, `#include`, `#external` or `#heuristic` scores 0.

Caps: the survey cap (120 s) sets the reference's verdicts. The fitness cap, the 60th percentile of the reference's
decided times and at least 5 s, is used on train, validate and the whole pool. The reporting cap, the paper's cap or else 120 s, is
used on test.

## Commands

```text
uv sync
uv run strata-calibrate benchmarks/paper/hcp --workers 4
uv run strata reward benchmarks/paper/hcp my.lp
uv run strata pick   benchmarks/paper/hcp a.lp b.lp
uv run strata test   benchmarks/paper/hcp my.lp
```

## Adding a benchmark

1. Create `benchmarks/<category>/<id>/` with a README.md in the sections the others use.
2. Put the published encoding in `seeds/<id>.lp`, comments kept, and a different reference, if any, in
   `seeds/reference.lp`.
3. Split the instances 2:1:1 into `instances/train/`, `validate/` and `test/` before running anything.
4. Write `validate.py`.
5. Run `strata-calibrate`, with `--reporting-cap` if the paper reports at another cap than 120 s. Check that the
   validator self-test passes, and commit `metadata.json`.
