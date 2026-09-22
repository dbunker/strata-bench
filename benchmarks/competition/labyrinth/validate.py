"""push/3 must push one row or column per step until the player can walk to the goal, and the goal must be
reachable within max_steps. The player walks only after a push."""

import re
from collections import defaultdict

STEP = {"n": (1, 0), "s": (-1, 0), "e": (0, 1), "w": (0, -1)}
OPPOSITE = {"n": "s", "s": "n", "e": "w", "w": "e"}


def validate(instance, model):
    text = open(instance).read()
    fields = {(int(x), int(y)) for x, y in atoms(text, "field")}
    rows = max(x for x, _ in fields)
    columns = max(y for _, y in fields)

    open_sides = defaultdict(set)
    for x, y, side in atoms(text, "connect"):
        open_sides[(int(x), int(y))].add(side)

    goal = tuple(int(v) for v in atoms(text, "goal_on")[0])
    reach = {tuple(int(v) for v in atoms(text, "init_on")[0])}
    steps = int(atoms(text, "max_steps")[0][0])

    pushes = defaultdict(list)
    for args in atoms(model, "push"):
        if len(args) == 3 and args[0].isdigit() and args[2].isdigit():
            pushes[int(args[2])].append((int(args[0]), args[1]))

    for step in range(1, steps + 1):
        if goal in reach:
            if pushes[step]:
                return False, f"step {step}: push after the goal was reached"
            continue

        if len(pushes[step]) != 1:
            return False, f"step {step} has {len(pushes[step])} pushes"
        line, direction = pushes[step][0]
        if direction not in STEP or not 1 <= line <= (rows if direction in "ew" else columns):
            return False, f"step {step}: push({line},{direction}) is not a row or column push"

        moved = {field: shifted(field, line, direction, rows, columns) for field in fields}
        open_sides = defaultdict(set, {moved[field]: sides for field, sides in open_sides.items()})
        goal = moved[goal]
        reach = walk({moved[field] for field in reach}, fields, open_sides)

    if goal not in reach:
        return False, f"goal not reachable after {steps} steps"
    return True, ""


def atoms(text, name):
    """The arguments of every name(...) atom in the text."""
    return [[a.strip() for a in args.split(",")] for args in re.findall(rf"\b{name}\(([^()]*)\)", text)]


def shifted(field, line, direction, rows, columns):
    """Where a field goes when row or column `line` is pushed one place, wrapping at the border."""
    x, y = field
    on_line = x == line if direction in "ew" else y == line
    if not on_line:
        return field

    dx, dy = STEP[direction]
    return (x + dx - 1) % rows + 1, (y + dy - 1) % columns + 1


def walk(start, fields, open_sides):
    """Every field the player can reach from `start` through pairs of facing open sides."""
    seen, frontier = set(start), list(start)
    while frontier:
        x, y = frontier.pop()
        for side, (dx, dy) in STEP.items():
            neighbour = (x + dx, y + dy)
            if neighbour in fields and neighbour not in seen \
                    and side in open_sides[(x, y)] and OPPOSITE[side] in open_sides[neighbour]:
                seen.add(neighbour)
                frontier.append(neighbour)
    return seen
