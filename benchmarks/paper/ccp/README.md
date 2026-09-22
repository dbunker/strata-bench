# Combined Configuration Problem

Siemens' Combined Configuration Problem as encoded in ASP by the CHECKMATE project: colour a graph of typed vertices, pack the vertices into bins by size, and satisfy path and border constraints, all at once. Instances range from 24 to 1024 elements and include a grid family.

## Task

Colour every vertex, assign every vertex to a bin, and select edge matchings, so that: colours respect the given types and the colour limit; bins respect the size limit and the bin limit; selected matchings respect the path and border constraints given in the instance. Output: vertex_color/2, vertex_bin/2, bin/3, edge_matching_selected/2, usedcolor/1, usedbin/1.

## Source

- Instances: the 2015 ASP Competition's CCP instances, as published in the CHECKMATE repository (checkmate-ijcai26, Apache 2.0).
- Seed: CHECKMATE's CCP_solving_encoding.asp, comments kept.
- Validator: the competition's checking program (checker.lp, unmodified), given only the output atoms.

## Split

99 instances, split once 2:1:1 into train 49, validate 25 and test 25, stratified by verdict and solving time. Reporting cap 600 s, the paper's.
