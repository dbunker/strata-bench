% ENCODING VERSION 6 - checking part
:- cabinetTOthing(C1,T1), cabinetTOthing(C2,T2), C1<C2, T1>T2. % ADAPTATION - ordering has to be preserved 
:- 1 > #count {C : cabinetTOthing(C,T)}, thing(T).
:- cabinetTOthing(C1,T), cabinetTOthing(C2,T), C1 < C2.
:- 6 <= #count { T : cabinetTOthing(C,T), thing(T) }, cabinet(C).

:- roomTOcabinet(R1,C), roomTOcabinet(R2,C), R1 < R2.
:- 1 > #count {R : roomTOcabinet(R,C)}, cabinet(C).
:- 5 <= #count { C : roomTOcabinet(R,C), cabinetDomain(C) }, room(R).

personTOcabinet(P,C) :- personTOthing(P,T), cabinetTOthing(C,T).
:- personTOcabinet(P1, C), personTOcabinet(P2, C), P1<P2.

personTOroom(P,R) :- personTOcabinet(P,C), roomTOcabinet(R,C).
:- personTOroom(P1,R), personTOroom(P2,R), P1<P2.

%% added - all used cabinets and rooms have to be instantiated from the domain 
:- cabinetTOthing(C,_), not cabinet(C). 
:- roomTOcabinet(R,_), not room(R).
