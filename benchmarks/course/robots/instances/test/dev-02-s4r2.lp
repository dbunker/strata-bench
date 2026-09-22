%
% Input:
%   #const n: the time steps range from 0 to n
%   edge(N1,N2): there is an (undirected) edge between nodes N1 and N2
%   robot(R,C,N): robot R is of class C and starts at node N
%   job(J,C,D): job J is of class C and its deadline is D
%   operation(J,O,N): J's operation O takes place at node N (O >= 1)
%
% GENERATED dev instance -- satisfiable by construction, verified with clingo.
% NOT part of the scoring suite.
#const n=16.
edge(X,X+1) :- X=1..3.
robot(r1,c1,5).  edge(5,1).
job(j11,c1,8). operation(j11,1,1). operation(j11,2,1).
robot(r2,c2,6).  edge(6,1).
job(j21,c2,11). operation(j21,1,3). operation(j21,2,2).
