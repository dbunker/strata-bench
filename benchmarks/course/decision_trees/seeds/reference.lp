node(1..n).

attribute(A) :- holds(E,A).

%
% tree
%

% optimization
% poss(I,J)   :- node(I), J=I+1..2*I, J <= n-1, J \ 2 = 0.
  poss(I,J)   :- node(I), node(J), J > I, J \ 2 = 0.
{ left(I,J) } :- node(I), poss(I,J).
right(I,J+1) :- left(I,J).
%
edge(I,J) :-  left(I,J).
edge(I,J) :- right(I,J).

{ leaf(I) } :- node(I).
%
:- leaf(I), edge(I,J).
%
:- node(I), not leaf(I), { left(I,J) } != 1.
%
:- node(I), I>1, { edge(J,I) } != 1.
%
% additional constraints
:- left(N,L), 1 { left(NN,LL) : NN > N, LL < L }. 

%
% decision tree
%

% guess class (if leaf)
{ positive(N) } :- node(N), leaf(N).

% guess decision (if not leaf)
{ decision(N,A) : attribute(A)} = 1 :- node(N), not leaf(N).

% propagate decision downwards
decided(M,A,f) :- decision(N,A),  left(N,M).
decided(M,A,t) :- decision(N,A), right(N,M).
%
decided(M,A,V) :- decided(N,A,V), edge(N,M).
%
:- decision(N,A), decided(N,A,V).

% additional constraints
:- leaf(N), leaf(N+1),     positive(N),     positive(N+1), poss(_,N).
:- leaf(N), leaf(N+1), not positive(N), not positive(N+1), poss(_,N).

% check examples at leaves
:- example(E,pos), leaf(N), not positive(N), 
   not decided(N,A,f) : holds(E,A); 
   not decided(N,A,t) : attribute(A), not holds(E,A).
:- example(E,neg), leaf(N),     positive(N), 
   not decided(N,A,f) : holds(E,A); 
   not decided(N,A,t) : attribute(A), not holds(E,A).

% display
#show edge/2.
#show decision/2.
#show positive/1.
