% SEED for uky_hc: enc6.lp, the best published encoding on the TRAIN split (benchmarks/uniform/pick_seed.py, 2026-09-15); alternatives scored in benchmarks/uniform/seed_picks.json
%Generator

{ hpath(X,Y) : link(X,Y) } =1:-node(X).

{ hpath(X,Y) : link(X,Y) } =1:-node(Y).


%rule

reach(1).

reach(Y) :- reach(X),hpath(X,Y).


%test

:- not reach(X),node(X).


%show

#show hpath/2.
