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
#const n=27.
edge(X,X+1) :- X=1..4.
robot(r1,c1,6).  edge(6,1).
job(j11,c1,13). operation(j11,1,4). operation(j11,2,3).
job(j12,c1,21). operation(j12,1,5). operation(j12,2,1).
robot(r2,c2,7).  edge(7,1).
job(j21,c2,13). operation(j21,1,4). operation(j21,2,5).
job(j22,c2,19). operation(j22,1,2). operation(j22,2,3).
