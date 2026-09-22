# Labyrinth

Labyrinth from the Fourth ASP Competition, 2013: push rows and columns of a grid of fields, which wrap around at the border, until the player can walk from the start to the goal within a step limit.

## Task

Given field/2, connect/3, init_on/2, goal_on/2 and max_steps/1, push one row or column per step until the player can walk from the start to the goal, within max_steps steps. Output: push/3, the row or column, the direction and the step.

## Source

- Instances: Fourth ASP Competition, 2013 (Alviano, Calimeri, Charwat et al.), problem 24.
- Seed: the competition's encoding, comments kept: the strongest published labyrinth encoding with no wrong answer on these instances.
- Validator: replays the pushes and the player's walks step by step.

## Split

48 instances, split once 2:1:1 into train 23, validate 11 and test 14, stratified by verdict and solving time. Reporting cap 120 s.
