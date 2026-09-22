"""The answer must pass the competition's checking program (checker.lp, unmodified)."""

import pathlib

from strata_bench.score import check_with_program

CHECKER = pathlib.Path(__file__).with_name("checker.lp")
OUTPUTS = {"vertex_color", "vertex_bin", "bin", "edge_matching_selected", "usedcolor", "usedbin"}


def validate(instance, model):
    return check_with_program(CHECKER, instance, model, OUTPUTS)
