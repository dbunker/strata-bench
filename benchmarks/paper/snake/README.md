# Snake

The Snake puzzle: fill an n by n grid with the numbers 1 to n², each next to the one before, keeping the given clues.

## Task

Given the partially filled grid filled/3, complete it so that the filled cells form one snake path consistent with the clues. Output: filled/3.

## Source

- Instances: University of Kentucky ASP course material (Truszczynski).
- Seed: the course encoding, comments kept.
- Validator: filled/3 must hold 1 to n² once each, each number next to the one before, with every clue kept.

## Split

48 instances, split once 2:1:1 into train 23, validate 12 and test 13, stratified by verdict and solving time. Reporting cap 120 s.
