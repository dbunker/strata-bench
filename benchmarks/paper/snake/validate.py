"""filled/3 must complete the given clues into one snake:
the numbers 1..n*n, each next to the one before."""

import re

N = 10


def cells(text, name="filled"):
    pattern = rf"\b{name}\(\s*([\d,\s]+)\)"
    return [tuple(int(v) for v in m.group(1).split(",")) for m in re.finditer(pattern, text)]


def validate(instance, model):
    given = {(r, c): v for r, c, v in cells(open(instance).read())}

    board = {}
    for r, c, v in cells(model):
        if board.get((r, c), v) != v:
            return False, f"cell ({r},{c}) filled twice"
        board[(r, c)] = v

    if len(board) != N * N:
        return False, f"{len(board)} cells filled, expected {N * N}"
    if sorted(board.values()) != list(range(1, N * N + 1)):
        return False, "the numbers are not 1..n*n"

    for cell, v in given.items():
        if board.get(cell) != v:
            return False, f"given cell {cell}={v} not respected"

    position = {v: cell for cell, v in board.items()}
    for v in range(1, N * N):
        (r1, c1), (r2, c2) = position[v], position[v + 1]
        if max(abs(r1 - r2), abs(c1 - c2)) > 1:
            return False, f"{v} and {v + 1} are not adjacent"

    return True, ""
