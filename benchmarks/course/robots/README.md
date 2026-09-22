# Robot Job Scheduling

A course exercise: robots move on a graph and carry out the operations of jobs; every job must finish by its deadline, with as few robot moves as possible.

## Task

Given edge/2, robot/3, job/3 and operation/3, output robot positions and job assignments that finish every job by its deadline, with as few robot moves as possible. Output: at/3, assign/3.

## Source

- Instances: the course exercise.
- Seed: an expert's encoding from a collection of human-written encodings, comments kept.
- Validator: the answer must be exactly one of the reference's solutions; the reference's objective gives its cost.

## Split

40 instances, split once 2:1:1 into train 19, validate 10 and test 11, stratified by verdict and solving time. Reporting cap 120 s.
