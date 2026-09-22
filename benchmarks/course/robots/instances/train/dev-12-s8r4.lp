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
#const n=81.
edge(X,X+1) :- X=1..7.
robot(r1,c1,9).  edge(9,1).
job(j11,c1,39). operation(j11,1,7). operation(j11,2,1). operation(j11,3,8).
job(j12,c1,54). operation(j12,1,2). operation(j12,2,2). operation(j12,3,8).
job(j13,c1,65). operation(j13,1,4). operation(j13,2,1). operation(j13,3,2).
robot(r2,c2,10).  edge(10,1).
job(j21,c2,29). operation(j21,1,5). operation(j21,2,1). operation(j21,3,2).
job(j22,c2,33). operation(j22,1,3). operation(j22,2,3). operation(j22,3,3).
job(j23,c2,38). operation(j23,1,3). operation(j23,2,2). operation(j23,3,3).
robot(r3,c1,11).  edge(11,1).
job(j31,c1,29). operation(j31,1,5). operation(j31,2,4). operation(j31,3,8).
job(j32,c1,39). operation(j32,1,7). operation(j32,2,3). operation(j32,3,1).
job(j33,c1,47). operation(j33,1,3). operation(j33,2,2). operation(j33,3,4).
robot(r4,c2,12).  edge(12,1).
job(j41,c2,24). operation(j41,1,2). operation(j41,2,3). operation(j41,3,1).
job(j42,c2,32). operation(j42,1,2). operation(j42,2,5). operation(j42,3,6).
job(j43,c2,42). operation(j43,1,1). operation(j43,2,2). operation(j43,3,1).
