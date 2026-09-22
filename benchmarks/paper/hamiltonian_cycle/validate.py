"""hpath/2 must be one cycle through every node, using only the given links."""

import re


def validate(instance, model):
    text = open(instance).read()
    nodes = set(re.findall(r"\bnode\((\w+)\)", text))
    links = set(re.findall(r"\blink\((\w+),(\w+)\)", text))
    edges = re.findall(r"\bhpath\((\w+),(\w+)\)", model)

    if not edges:
        return False, "no hpath/2 atoms"

    successor, incoming = {}, {}
    for a, b in edges:
        if (a, b) not in links:
            return False, f"hpath({a},{b}) is not a link"
        if a in successor:
            return False, f"node {a} has two outgoing edges"
        successor[a] = b
        incoming[b] = incoming.get(b, 0) + 1

    if set(successor) != nodes or any(incoming.get(n, 0) != 1 for n in nodes):
        return False, "not every node has exactly one outgoing and one incoming edge"

    start = node = next(iter(nodes))
    length = 0
    while True:
        node = successor[node]
        length += 1
        if node == start:
            break

    if length != len(nodes):
        return False, f"{length} of {len(nodes)} nodes on the first cycle"
    return True, ""
