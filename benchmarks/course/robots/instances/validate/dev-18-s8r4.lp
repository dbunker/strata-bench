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
#const n=76.
edge(X,X+1) :- X=1..7.
robot(r1,c1,9).  edge(9,1).
job(j11,c1,28). operation(j11,1,3). operation(j11,2,6). operation(j11,3,3).
job(j12,c1,37). operation(j12,1,3). operation(j12,2,1). operation(j12,3,5).
job(j13,c1,45). operation(j13,1,1). operation(j13,2,1). operation(j13,3,2).
robot(r2,c2,10).  edge(10,1).
job(j21,c2,29). operation(j21,1,6). operation(j21,2,6). operation(j21,3,2).
job(j22,c2,40). operation(j22,1,7). operation(j22,2,6). operation(j22,3,8).
job(j23,c2,54). operation(j23,1,2). operation(j23,2,5). operation(j23,3,7).
robot(r3,c1,11).  edge(11,1).
job(j31,c1,33). operation(j31,1,7). operation(j31,2,8). operation(j31,3,2).
job(j32,c1,47). operation(j32,1,8). operation(j32,2,7). operation(j32,3,3).
job(j33,c1,60). operation(j33,1,7). operation(j33,2,2). operation(j33,3,1).
robot(r4,c2,12).  edge(12,1).
job(j41,c2,24). operation(j41,1,1). operation(j41,2,5). operation(j41,3,5).
job(j42,c2,35). operation(j42,1,8). operation(j42,2,4). operation(j42,3,3).
job(j43,c2,41). operation(j43,1,4). operation(j43,2,4). operation(j43,3,2).
