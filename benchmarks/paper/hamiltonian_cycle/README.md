# Hamiltonian Cycle

Find a Hamiltonian cycle in a directed graph: a cycle through every node exactly once, using the given links.

## Task

Given node/1 and link/2, choose edges hpath/2 from the links that form a single cycle through every node exactly once. Output: hpath/2.

## Source

- Instances: University of Kentucky ASP course material (Truszczynski).
- Seed: the course encoding, comments kept.
- Validator: hpath/2 must form one cycle through every node, using only the given links.

## Split

48 instances, split once 2:1:1 into train 25, validate 12 and test 11, stratified by verdict and solving time. Reporting cap 120 s.
