"""The answer must be exactly one of the reference encoding's solutions."""

import pathlib

from strata_bench.score import check_with_reference

REFERENCE = pathlib.Path(__file__).parent / "seeds" / "cbctt.lp"
OUTPUTS = {"assigned"}


def validate(instance, model):
    return check_with_reference(REFERENCE, instance, model, OUTPUTS)
