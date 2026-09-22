"""The answer must pass the 2011 competition's checking program (checker.lp, unmodified)."""

import pathlib

from strata_bench.score import check_with_program

CHECKER = pathlib.Path(__file__).with_name("checker.lp")
OUTPUTS = {"link"}


def validate(instance, model):
    return check_with_program(CHECKER, instance, model, OUTPUTS)
