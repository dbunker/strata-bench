# Decision Tree Induction

A course exercise: from labelled examples, build a decision tree of bounded size that classifies every example correctly.

## Task

Given example/2, output a decision tree that classifies every example correctly within the size bound. Output: edge/2, positive/1, decision/2.

## Source

- Instances: the course exercise.
- Seed: the course's encoding (dec.lp), comments kept.
- Reference: an expert's encoding from a collection of human-written encodings; it decides every instance.
- Validator: the answer must be exactly one of the reference's solutions.

## Split

20 instances, split once 2:1:1 into train 9, validate 7 and test 4, stratified by verdict and solving time. Reporting cap 120 s.
