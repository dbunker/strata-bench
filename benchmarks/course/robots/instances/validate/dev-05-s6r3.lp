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
#const n=48.
edge(X,X+1) :- X=1..5.
robot(r1,c1,7).  edge(7,1).
job(j11,c1,21). operation(j11,1,6). operation(j11,2,5). operation(j11,3,4).
job(j12,c1,31). operation(j12,1,4). operation(j12,2,6). operation(j12,3,1).
robot(r2,c2,8).  edge(8,1).
job(j21,c2,22). operation(j21,1,5). operation(j21,2,3). operation(j21,3,5).
job(j22,c2,38). operation(j22,1,1). operation(j22,2,6). operation(j22,3,2).
robot(r3,c1,9).  edge(9,1).
job(j31,c1,20). operation(j31,1,6). operation(j31,2,6). operation(j31,3,5).
job(j32,c1,28). operation(j32,1,5). operation(j32,2,3). operation(j32,3,6).
