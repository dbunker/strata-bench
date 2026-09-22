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
#const n=33.
edge(X,X+1) :- X=1..4.
robot(r1,c1,6).  edge(6,1).
job(j11,c1,20). operation(j11,1,5). operation(j11,2,1).
job(j12,c1,24). operation(j12,1,2). operation(j12,2,1).
robot(r2,c2,7).  edge(7,1).
job(j21,c2,13). operation(j21,1,1). operation(j21,2,2).
job(j22,c2,20). operation(j22,1,1). operation(j22,2,5).
robot(r3,c1,8).  edge(8,1).
job(j31,c1,15). operation(j31,1,4). operation(j31,2,4).
job(j32,c1,20). operation(j32,1,2). operation(j32,2,1).
