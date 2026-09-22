%
% Input:
%   #const n: the time steps range from 0 to n
%   edge(N1,N2): there is an (undirected) edge between nodes N1 and N2
%   robot(R,C,N): robot R is of class C and starts at node N
%   job(J,C,D): job J is of class C and its deadline is D 
%   operation(J,O,N): J's operation O takes place at node N (O >= 1)
%
% Output:
%   at(R,N,T): robot R is at node N at time step T
%   assign(R,J,P): assign to R the job J at position P (in the sequence of jobs assigned to R) (P >= 1)
%


%
% auxiliary predicates
%

time(0..n).
edge(N1,N2) :-  edge(N2,N1).
   node(N1) :-  edge(N1,N2).
   robot(R) :- robot(R,C,N).
     job(J) :-   job(J,C,D).

%
% encoding
%

at(R,N,0) :- robot(R,C,N).
%
{ at(R,N,T) : node(N) } = 1 :- robot(R), time(T), T > 0.
%
poss(R, N,T) :- at(R, N,T-1), time(T).
poss(R,N2,T) :- at(R,N1,T-1), edge(N1,N2), time(T).
:- at(R,N,T), not poss(R,N,T), time(T), T > 0.

:- node(N), time(T), 2 { at(R,N,T) }.
%:- at(R1,N1,T-1), at(R2,N2,T-1), R1 < R2, edge(N1,N2),
%   at(R1,N2,T  ), at(R2,N1,T  ).
move(T,N1,N2) :- at(R1,N1,T-1), at(R1,N2,T), edge(N1,N2).
              :- move(T,N1,N2), move(T,N2,N1).

%   assign(R,J,P): assign to R the job J at position P (in the sequence of jobs assigned to R) (P >= 1)
{ assign(R,J,1..X) : robot(R,C,_) } = 1 :- job(J,C,_), X = { job(JJ,C,_) }.
:- assign(R,J1,P), assign(R,J2,P), J1 < J2.
:- assign(R,J1,P), P > 1, not assign(R,_,P-1).

next(R,J1,J2) :- assign(R,J1,P), assign(R,J2,P+1), J1 != J2.

state(R, J,  0,-1) :- assign(R,J,1).
state(R, J,  O, T) :- state(R,J,O,T-1), time(T).
state(R, J,O+1, T) :- state(R,J,O,T-1), operation(J,O+1,N), at(R,N,T).
state(R,JJ,  0, T) :- state(R,J,O,T  ), operation(J,  O,_), not operation(J,O+1,_), next(R,J,JJ).
    finished(J, T) :- state(R,J,O,T  ), operation(J,  O,_), not operation(J,O+1,_).

%*
% another option with state/3 that uses predicate assign/3 
state( J,  0,-1) :- assign(R,J,1).
state( J,  O, T) :- state(J,O,T-1), time(T).
state( J,O+1, T) :- state(J,O,T-1), operation(J,O+1,N), assign(R,J,_), at(R,N,T).
state(JJ,  0, T) :- state(J,O,T  ), operation(J,  O,_), not operation(J,O+1,_), assign(R,J,_), next(R,J,JJ).
  finished(J, T) :- state(J,O,T  ), operation(J,  O,_), not operation(J,O+1,_).
*%

% all finished
:- job(J), not finished(J,_).

% deadlines
:- job(J,_,D), finished(J,T), not finished(J,T-1), T > D.

#minimize{ 1,R,T: at(R,N,T), not at(R,N,T-1), T > 0 }.

%
% show
%
#show at/3.
#show assign/3.
