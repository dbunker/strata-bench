# Curriculum-Based Course Timetabling

Curriculum-based course timetabling in the UD2 formulation of the International Timetabling Competition 2007: assign lectures to periods and rooms without curriculum, teacher or room clashes. Only feasibility is judged: the instances lack the UD2 penalty weights, so the objective is inactive.

## Task

Assign every lecture of every course to a period and a room. No two lectures of the same curriculum or the same teacher in one period, no room used twice in one period, room constraints respected, and the daily lecture limits and other UD2 constraints satisfied. Output: assigned/4.

## Source

- Instances: ITC-2007 track 3, in the UD2 formulation used by teaspoon (Banbara et al.).
- Seed: teaspoon's published UD2 encoding, comments kept.
- Validator: the answer must be exactly one of the reference's solutions.

## Split

52 instances, split once 2:1:1 into train 26, validate 12 and test 14, stratified by verdict and solving time. Reporting cap 120 s.
