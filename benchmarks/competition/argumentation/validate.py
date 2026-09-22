"""The in/1 atoms must be a preferred extension: admissible, with no larger admissible set.
The empty set is a preferred extension when nothing non-empty is admissible."""

import re

from strata_bench.score import clingo, temporary_file

IN = re.compile(r"(?<![A-Za-z0-9_])in\(([^()]*)\)")

# SAT exactly when the chosen set is NOT admissible
NOT_ADMISSIBLE = """
bad :- chosen(X), not arg(X).
bad :- chosen(X), chosen(Y), att(X,Y).
defended_against(Y) :- chosen(X), att(X,Y).
bad :- chosen(X), att(Y,X), not defended_against(Y).
:- not bad.
"""

# SAT exactly when a strictly larger admissible set exists
LARGER_ADMISSIBLE = """
in(X) :- chosen(X).
{ in(X) : arg(X), not chosen(X) }.
:- in(X), in(Y), att(X,Y).
defeated(X) :- in(Y), att(Y,X).
:- in(X), att(Y,X), not defeated(Y).
:- #count{ X : in(X), not chosen(X) } = 0.
"""


def validate(instance, model, cap=60):
    chosen = "".join(f"chosen({a}).\n" for a in IN.findall(model or ""))
    checks = ((NOT_ADMISSIBLE, "not admissible"),
              (LARGER_ADMISSIBLE, "not maximal: a larger admissible set exists"))

    for program, failure in checks:
        with temporary_file(chosen + program) as path:
            out = clingo([instance, path], cap)
        if "SATISFIABLE" in out and "UNSATISFIABLE" not in out:
            return False, failure
        if "UNSATISFIABLE" not in out:
            return False, "undecided: the check ran out of time"

    return True, ""
