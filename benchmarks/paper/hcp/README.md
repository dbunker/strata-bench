# House Configuration Problem

Siemens' House Configuration Problem as encoded in ASP by the CHECKMATE project: put each person's things into cabinets and the cabinets into rooms. Instances have 1 to 3000 persons. They are CHECKMATE's 15 training and 36 test instances; our split mixes both.

## Task

Things belong to persons. Put each thing in exactly one cabinet and each used cabinet in exactly one room, chosen from the given cabinet and room domains. A cabinet holds at most five things and a room at most four cabinets. Everything in a cabinet has one owner and everything in a room has one owner. If cabinet A is numbered below cabinet B, every thing in A is numbered below every thing in B. Output: cabinet/1, room/1, cabinetTOthing/2, roomTOcabinet/2.

## Source

- Instances: the CHECKMATE repository (checkmate-ijcai26, Apache 2.0), from Siemens' configuration problems.
- Seed: CHECKMATE's HCP_solving_encoding.lp, version 6, comments kept.
- Validator: CHECKMATE's checking encoding (checker.lp, unmodified), given only the output atoms.

## Split

51 instances, split once 2:1:1 into train 27, validate 12 and test 12, stratified by verdict and solving time. Reporting cap 120 s.
