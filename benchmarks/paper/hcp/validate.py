"""The answer must pass CHECKMATE's checking encoding (checker.lp, unmodified)."""

import pathlib

from strata_bench.score import check_with_program

CHECKER = pathlib.Path(__file__).with_name("checker.lp")
OUTPUTS = {"cabinet", "room", "cabinetTOthing", "roomTOcabinet"}


def validate(instance, model):
    return check_with_program(CHECKER, instance, model, OUTPUTS)
