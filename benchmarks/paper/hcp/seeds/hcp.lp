% hcp_seed.lp -- the House Configuration Problem (Siemens), CHECKMATE's clingo specification.
% Things belong to persons; things go in cabinets, cabinets in rooms. Constraints: each thing in
% exactly one cabinet, <=5 things per cabinet, each cabinet in exactly one room, <=4 cabinets per
% room, all things in a cabinet share an owner, all cabinets in a room share an owner, and the
% cabinet/thing ordering must be preserved.
%
% CONTRACT: solve MORE instances while every answer still passes the organisers' checker.
% The bottleneck is GROUNDING, not search: on a 20-person instance the seed spends 17.4s total of
% which 0.06s is solving, and by 35 persons it allocates 9.8 GB and never begins search at all.
%
% The #show lines are the witness contract (their input_output_parser.py) and are FROZEN.

#show cabinet/1.
#show room/1.
#show cabinetTOthing/2.
#show roomTOcabinet/2.

% # EVOLVE-BLOCK-START
% ENCODING VERSION 6 - efficient tight encoding with ordering adaptation
cabinet(C) :- cabinetDomain(C), not cabinet_n(C).
cabinet_n(C) :- cabinetDomain(C), not cabinet(C).

room(R) :- roomDomain(R), not room_n(R).
room_n(R) :- roomDomain(R), not room(R).

cabinetTOthing(C,T) :- thing(T), cabinetDomain(C), not cabinetTOthing_n(C,T).
cabinetTOthing_n(C,T) :- thing(T), cabinetDomain(C), not cabinetTOthing(C,T).
:- cabinetTOthing(C1,T), cabinetTOthing(C2,T), C1 < C2.
:- cabinetTOthing(C1,T1), cabinetTOthing(C2,T2), C1<C2, T1>T2. % ADAPTATION - ordering has to be preserved
:- 1 > #count {C : cabinetTOthing(C,T)}, thing(T).
:- 6 <= #count { T : cabinetTOthing(C,T), thing(T) }, cabinet(C).

roomTOcabinet(R,C) :- cabinet(C), roomDomain(R), not roomTOcabinet_n(R,C).
roomTOcabinet_n(R,C) :- cabinet(C), roomDomain(R), not roomTOcabinet(R,C).
:- roomTOcabinet(R1,C), roomTOcabinet(R2,C), R1 < R2.
:- 1 > #count {R : roomTOcabinet(R,C)}, cabinet(C).
:- 5 <= #count { C : roomTOcabinet(R,C), cabinetDomain(C) }, room(R).

personTOcabinet(P,C) :- personTOthing(P,T), cabinetTOthing(C,T).
:- personTOcabinet(P1, C), personTOcabinet(P2, C), P1<P2. 

personTOroom(P,R) :- personTOcabinet(P,C), roomTOcabinet(R,C).

:- personTOroom(P1,R), personTOroom(P2,R), P1<P2.


%Ordering
room(R1) :- roomDomain(R1), roomDomain(R2), room(R2), R1 < R2.
cabinet(C1) :- cabinetDomain(C1), cabinetDomain(C2), cabinet(C2), C1 < C2.

room(R) :- roomTOcabinet(R,C).

cabinet(C) :- cabinetTOthing(C,T).
% # EVOLVE-BLOCK-END
