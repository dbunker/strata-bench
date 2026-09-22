# Numberlink

Numberlink from the Third ASP Competition, 2011: connect each numbered pair of nodes by a path, with no two paths sharing a node.

## Task

Given node/1, edge/3 and connection/3, choose edges so that each numbered pair is connected by exactly one path and no two paths share a node. Output: link/1, the chosen edges.

## Source

- Instances: Third ASP Competition, 2011 (Calimeri, Ianni, Ricca et al.), problem package.
- Seed: the competition's reference encoding, comments kept.
- Validator: the competition's checking program (checker.lp, unmodified), given only the link/1 atoms.

## Split

120 instances, split once 2:1:1 into train 58, validate 31 and test 31, stratified by verdict and solving time. Reporting cap 120 s.
