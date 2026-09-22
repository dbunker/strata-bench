#show err/1.
%%% NO ERRORS
% TODO: uncomment for competition!!!
:- err(X).

vertex(X) :- edge(X,_).
vertex(X) :- edge(_,X).

% every color in a solution is used and vice versa 
color_vertex(C) :- vertex_color(X,C).
:- usedcolor(C), not color_vertex(C).
:- color_vertex(C), not usedcolor(C).

% vertex is colored with one color only
err(multicolor(X)):- vertex(X), not 1 {vertex_color(X,C)} 1.

% check number of colors
%err(colors) :- not NC {color_vertex(C)} NC, nrofcolors(NC).
err(colors) :-  NC+1 {color_vertex(C)}, nrofcolors(NC).

%%% BIN PACKING

% every bin in a solution is used and vice versa
u_bin(B) :- vertex_bin(X,B).
:- usedbin(B), not u_bin(B).
:- u_bin(B), not usedbin(B).

% check number of bins
%err(nrofbins) :- not NB {u_bin(B)} NB, nrofbins(NB).
err(nrofbins) :- NB+1 {u_bin(B)}, nrofbins(NB).

% every vertex is stored in one bin only
err(multiple_bin(X)):- vertex(X), not 1 {vertex_bin(X,B)} 1.

% check bin and vertex_bin sync
v_bin(C,B,V) :- vertex_bin(V,B), vertex_color(V,C).
err(unsync_bin(C,B,V)) :- v_bin(C,B,V), not bin(C,B,V).
err(unsync_bin(C,B,V)) :- bin(C,B,V), not v_bin(C,B,V).

% check bin capacity
err(bin_capacity(C,B)):- color_vertex(C), u_bin(B), CP+1 #sum { S,V : size(V,S) , bin(C,B,V)}, maxbinsize(CP).

%%% PATH
err(path_color(V1,V2,C)):-path1(V1), path2(V2), vertex_color(V1,C), vertex_color(V2,C).

%%% MATCHING
area(A) :- edge_matching(A,B).
borderelement(B) :- edge_matching(A,B).

% check if border elements have the same color
err(area_color(A)):- area(A), vertex_color(B1,C1) , vertex_color(B2,C2), edge_matching_selected(A,B1) , edge_matching_selected(A,B2), B1!=B2, C1!=C2.

% check number of border elements 
err(max_border(A)):- area(A), MB+1 {edge_matching_selected(A,B)}, maxborder(MB).

% border element not assigned or assigned to multiple areas
err(false_assign(B)) :- borderelement(B), not 1 { edge_matching_selected(A,B) } 1.

% CONNECTEDNESS
% reuse the encoding, since reachable_color/2 is not in the output schema

e(X,Y):-edge(X,Y).
e(X,Y):-edge(Y,X).
% REPAIRED 2026-08-25 for clingo 5.8: `vertex(V1;V2)` is POOLING, which expands into two
% separate rules each leaving the other variable unsafe. gringo accepted this in 2016 under
% older conditional-literal safety rules. The intent is unambiguous -- pred(V1,V2) means V1
% is the immediate predecessor of V2 in the vertex order -- so both vertices are bound
% explicitly and the conditional literal stays a filter. Validated against the checker's own
% 01-instance.OK / 01-instance.FAIL fixtures; original kept as constraint.asp.orig.
% FAST PATH 2026-08-30. Semantically identical to the rule above; the ONLY change is how the
% immediate-successor relation is computed.
%
% The original is quadratic in vertex PAIRS with a conditional literal ranging over vertices --
% cubic overall: ~309M ground operations at 676 vertices, ~1.07B at 1024. It is the entire reason
% verifying a witness costs minutes while PRODUCING one costs seconds: our encoding grounds
% 1,762,915 lines in 2.6s, and the checker then spends 160-1100s grounding this single rule.
%
% pred(V1,V2) means "V2 is the next vertex after V1 in the vertex order". Ranking each vertex by
% how many vertices precede it gives the same relation with an aggregate per vertex instead of a
% cubic join.
%
% NOT a correctness change and NOT for the published number: the official constraint.asp produces
% every reported verdict. This exists so ITERATION is affordable.
vertex_idx(V,I) :- vertex(V), I = #count{ W : vertex(W), W < V }.
pred(V1,V2) :- vertex_idx(V1,I), vertex_idx(V2,I+1).
first(C,V2) :- usedcolor(C), pred(V1,V2), not vertex_color(V1,C), first(C,V1) : pred(V,V1).
reachable_color(C,V1) :- usedcolor(C), vertex(V1), first(C,V1) : pred(V,V1).
reachable_color(C,V2) :- reachable_color(C,V1), e(V1,V2), vertex_color(V1,C).
err(unreachable_color(V,C)):- vertex_color(V,C), not reachable_color(C,V).
