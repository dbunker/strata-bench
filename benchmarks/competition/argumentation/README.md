# Preferred Extensions

Abstract argumentation: given arguments and the attacks between them, find a preferred extension, a maximal admissible set of arguments.

## Task

Given arg/1 and att/2, output a set of arguments that is conflict-free, defends itself against every attack, and is maximal among such sets. Output: in/1.

## Source

- Instances: ICCMA argumentation competition instances.
- Seed: ASPARTIX's preferred-extension encoding (Egly, Gaggl, Woltran), comments kept.
- Validator: two clingo checks that the in/1 set is admissible and that no larger admissible set exists. The empty set passes when nothing non-empty is admissible.

## Split

64 instances, split once 2:1:1 into train 31, validate 16 and test 17, stratified by verdict and solving time. Reporting cap 120 s.
