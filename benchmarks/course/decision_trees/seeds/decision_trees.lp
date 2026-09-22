% instance

#show edge/2.
#show positive/1.
#show decision/2.

% #show negative/1.
% #show example/2.
% #show holds/2.
% #show node_holds/3.

node(1..n).

% Every node has 1 parent except root (node(1))
{ edge(A, B) : node(A) } = 1 :- node(B), B > 1.

% Every node has 2 children or none
{ edge(A, B) : node(B) } <= 2 :- node(A).
{ edge(A, B) : node(B) } != 1 :- node(A).

% child nodes are higher than the parent
A < B :- edge(A, B).

% for any two nodes, the one with the bigger number connects (as a parent) to bigger children
C < D :- edge(A, C), edge(B, D), A < B.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if leaf node, must be exactly 1 of negative or positive
{ positive(B) ; negative(B) } = 1 :- edge(A, B), not edge(B, _).

% if not leaf node, cannot be positive or negative
{ positive(A) ; negative(A) } = 0 :- edge(A, B), edge(B, _).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if parent node, must have exactly 1 attribute decision for all attributes possible
{ decision(A, T) : holds(_, T) } = 1 :- edge(A, _).

% can't have multiple labels on same node
X=Y :- decision(A, X), decision(A, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for all positive examples, node_holds when positive leaf
node_holds(pos, E, N) :- positive(N), example(E, pos).
example(E, pos) :- positive(N), node_holds(pos, E, N).

node_holds(neg, E, N) :- negative(N), example(E, neg).
example(E, neg) :- negative(N), node_holds(neg, E, N).

% for every positive example there's a path to the top from a leaf
node_holds(CLASS, E, 1) :- example(E, CLASS).
example(E, CLASS) :- node_holds(CLASS, E, 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parent node_holds(E, N) will be true if: child on right side (C) is positive and decision(N, T) is true for example (holds(E, T))
node_holds(CLASS, E, N) :- edge(N, C), C \ 2 = 1, node_holds(CLASS, E, C), decision(N, T), holds(E, T).

% other side: with left node and not true for attribute T
node_holds(CLASS, E, N) :- edge(N, C), C \ 2 = 0, node_holds(CLASS, E, C), decision(N, T), not holds(E, T).

% node_holds(E, N) cannot be true if right hand child is not positive and making decision for example
:- edge(N, C), C \ 2 = 1, not node_holds(CLASS, E, C), decision(N, T), holds(E, T), node_holds(CLASS, E, N).

% other side: with left node and not true for example holds(E, T)
:- edge(N, C), C \ 2 = 0, not node_holds(CLASS, E, C), decision(N, T), not holds(E, T), node_holds(CLASS, E, N).
