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
#const n=51.
edge(X,X+1) :- X=1..6.
robot(r1,c1,8).  edge(8,1).
job(j11,c1,25). operation(j11,1,4). operation(j11,2,7). operation(j11,3,6).
job(j12,c1,36). operation(j12,1,7). operation(j12,2,2). operation(j12,3,4).
robot(r2,c2,9).  edge(9,1).
job(j21,c2,26). operation(j21,1,4). operation(j21,2,5). operation(j21,3,1).
job(j22,c2,37). operation(j22,1,2). operation(j22,2,1). operation(j22,3,7).
robot(r3,c1,10).  edge(10,1).
job(j31,c1,23). operation(j31,1,3). operation(j31,2,4). operation(j31,3,2).
job(j32,c1,31). operation(j32,1,1). operation(j32,2,2). operation(j32,3,5).
robot(r4,c2,11).  edge(11,1).
job(j41,c2,21). operation(j41,1,2). operation(j41,2,3). operation(j41,3,4).
job(j42,c2,29). operation(j42,1,5). operation(j42,2,1). operation(j42,3,1).
