"""The answer must be exactly one of the reference encoding's solutions.
The reference's objective gives the answer's cost."""

import pathlib

from strata_bench.score import check_with_reference

REFERENCE = pathlib.Path(__file__).parent / "seeds" / "robots.lp"
OUTPUTS = {"at", "assign"}


def validate(instance, model):
    return check_with_reference(REFERENCE, instance, model, OUTPUTS)
