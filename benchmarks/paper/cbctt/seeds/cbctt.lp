% SEED for cbctt_ud2: /Users/arch/Desktop/system/ASPEvolve/benchmarks/cbctt/encodings/teaspoon.lp (includes inlined by benchmarks/uniform/build.py)
%%% Curriculum-Based Course Timetabling
%%% @author Mutsunori Banbara
% ---- inlined from encoding/hard.lp ----
%%% Hard constraints (channeling encoding)

c(C) :- course(C,_,_,_,_,_).
t(T) :- course(_,T,_,_,_,_).
r(R) :- room(R,_,_).
d(0..D-1) :- days(D).
ppd(0..P-1) :- periods_per_day(P).
cu(Cu) :- curricula(Cu,_).

%%% Lectures: All lectures of a course must be scheduled, and they
%%% must be assigned to distinct periods. A violation occurs if a
%%% lecture is not scheduled or two lectures are in the same period.

N { assigned(C,D,P) : d(D), ppd(P) } N :- course(C,_,N,_,_,_).

%%% Conflicts: Lectures of courses in the same curriculum or taught by
%%% the same teacher must be all scheduled in different periods. Two
%%% conflicting lectures in the same period represent one
%%% violation. Three conflicting lectures count as 3 violations: one
%%% for each pair.

:- not { assigned(C,D,P) : course(C,T,_,_,_,_) } 1, t(T), d(D), ppd(P).
:- not { assigned(C,D,P) : curricula(Cu,C) } 1, cu(Cu), d(D), ppd(P).

%%% RoomOccupancy: Two lectures can not take place in the same room in
%%% the same period. Two lectures in the same room at the same period
%%% represent one violation. Any extra lecture in the same period and
%%% room counts as one more violation.

1 { assigned(C,R,D,P) : r(R) } 1 :- assigned(C,D,P).
:- not { assigned(C,R,D,P) : c(C) } 1, r(R), d(D), ppd(P).

%%% Availability: If the teacher of the course is not available to
%%% teach that course at a given period, then no lecture of the course
%%% can be scheduled at that period. Each lecture in a period
%%% unavailable for that course is one violation.

:- assigned(C,D,P), unavailability_constraint(C,D,P).

%%% Additional constraints (can be omitted)

:- not { assigned(C,D,P) : c(C) } N, d(D), ppd(P), rooms(N).

% End

% ---- inlined from encoding/soft_ext_S7.lp ----
%%% Soft constraints
% ---- inlined from soft_split/aux.lp ----
%%% Auxiliary predicates

scheduled_curricula(Cu,D,P) :- assigned(C,D,P), curricula(Cu,C). % used in S3, S4

% End


% ---- inlined from soft_split/s1_room_capacity.lp ----
%%% RoomCapacity: For each lecture, the number of students that attend
%%% the course must be less than or equal the number of seats of all
%%% the rooms that host its lectures. Each student above the capacity
%%% counts as 1 point of penalty. The weight for this component is 1.

% Soft constraint
penalty("RoomCapacity",assigned(C,R,D,P),(N-Cap)*W,Prior) :- 
    assigned(C,R,D,P),
    course(C,_,_,_,N,_),
    room(R,Cap,_),
    N > Cap,
    soft_constraint("RoomCapacity",W,Prior).

% Hard constraint
:- assigned(C,R,D,P), course(C,_,_,_,N,_), room(R,Cap,_), N > Cap, hard_constraint("RoomCapacity").

% End

% ---- inlined from soft_split/s2_min_working_days.lp ----
%%% MinWorkingDays: The lectures of each course must be spread into a
%%% given minimum number of days. Each day below the minimum counts as
%%% 1 violation.

working_day(C,D) :- assigned(C,D,P).

% Soft constraint
penalty("MinWorkingDays",course(C,MWD,N),(MWD-N)*W,Prior) :- 
	course(C,_,_,MWD,_,_),
	N = { working_day(C,D) },
	N < MWD,
	soft_constraint("MinWorkingDays",W,Prior).

% Hard constraint
:- not MWD { working_day(C,D) }, course(C,_,_,MWD,_,_), hard_constraint("MinWorkingDays").

% End

%#include "soft_split/s2_min_working_days_sinz.lp".
% ---- inlined from soft_split/s3_isolated_lectures.lp ----
%%% IsolatedLectures (Compactness v.1): Lectures belonging to a
%%% curriculum should be adjacent to each other (i.e., in consecutive
%%% periods). For a given curriculum we account for a violation every
%%% time there is one lecture not adjacent to any other lecture within
%%% the same day. Each isolated lecture in a curriculum counts as 1
%%% violation.

% Soft constraint
penalty("IsolatedLectures",isolated_lectures(Cu,D,P),W,Prior) :- 
	scheduled_curricula(Cu,D,P),
	not scheduled_curricula(Cu,D,P-1),
	not scheduled_curricula(Cu,D,P+1),
	soft_constraint("IsolatedLectures",W,Prior).

% Hard constraint
:- scheduled_curricula(Cu,D,P), 
   not scheduled_curricula(Cu,D,P-1), 
   not scheduled_curricula(Cu,D,P+1),
   hard_constraint("IsolatedLectures").

% End

% ---- inlined from soft_split/s4_windows.lp ----
%%% Windows (Compactness v.2): Lectures belonging to a curriculum
%%% should not have time windows (i.e., periods without teaching)
%%% between them. For a given curriculum we account for a violation
%%% every time there is one windows between two lectures within the
%%% same day. Each time window in a curriculum counts as many
%%% violation as its length (in periods).

% Soft_constraint
penalty("Windows",windows(Cu,D,P1,P2),(P2-P1-1)*W,Prior) :- 
    scheduled_curricula(Cu,D,P1),
    scheduled_curricula(Cu,D,P2),
    P1 + 1 < P2,
    not scheduled_curricula(Cu,D,P) : P = P1+1..P2-1;
    soft_constraint("Windows",W,Prior).

% Hard_constraint
:-  scheduled_curricula(Cu,D,P1),
    scheduled_curricula(Cu,D,P2),
    P1 + 1 < P2,
    not scheduled_curricula(Cu,D,P) : P = P1+1..P2-1;
    hard_constraint("Windows").

% End


%#include "soft_split/s4_windows_alt.lp".
% ---- inlined from soft_split/s5_room_stability.lp ----
%%% RoomStability: All lectures of a course should be given in the
%%% same room. Each distinct room used for the lectures of a course,
%%% but the first, counts as 1 violation.

using_room(C,R) :- assigned(C,R,D,P).

% Soft_constraint
penalty("RoomStability",using_room(C,N),(N-1)*W,Prior) :- 
	c(C),
	N = { using_room(C,R) }, 
	N > 1,
	soft_constraint("RoomStability",W,Prior).

% Hard_constraint
:- not { using_room(C,R) } 1, c(C), hard_constraint("RoomStability").

% End

% ---- inlined from soft_split/s6_student_min_max_load.lp ----
%%% StudentMinMaxLoad: For each curriculum the number of daily
%%% lectures should be within a given range. Each lecture below the
%%% minimum or above the maximum counts as 1 violation.

% Soft constraint
penalty("StudentMinMaxLoad",student_min_max_load(Cu,D,N,many),(N-Max)*W,Prior) :- 
	cu(Cu),
	d(D),
	N = { scheduled_curricula(Cu,D,P) },
	min_max_daily_lectures(Min,Max),
	N > Max,
	soft_constraint("StudentMinMaxLoad",W,Prior).
penalty("StudentMinMaxLoad",student_min_max_load(Cu,D,N,few),(Min-N)*W,Prior) :- 
	cu(Cu),
	d(D),
	N = { scheduled_curricula(Cu,D,P) },
	min_max_daily_lectures(Min,Max),
	0 < N, N < Min,
	soft_constraint("StudentMinMaxLoad",W,Prior).

% Hard constraint
:- not Min { scheduled_curricula(Cu,D,P) } Max,
   min_max_daily_lectures(Min,Max),
   cu(Cu), d(D),
   hard_constraint("StudentMinMaxLoad").

% End


%#include "soft_split/s6_student_min_max_load_sinz.lp".
% ---- inlined from soft_split/s7_travel_distance.lp ----
%%% TravelDistance: Students should have the time to move from one
%%% building to another one between two lectures. For a given
%%% curriculum we account for a violation every time there is an
%%% instantaneous move: two lectures in rooms located in different
%%% building in two adjacent periods within the same day. Each
%%% instantaneous move in a curriculum counts as 1 violation.

scheduled_curricula(Cu,B,D,P) :- assigned(C,R,D,P), curricula(Cu,C), room(R,_,B).

% Soft constraint
penalty("TravelDistance",instantaneous_move(Cu,D,P,P+1),W,Prior) :-
    scheduled_curricula(Cu,BLG1,D,P),
    scheduled_curricula(Cu,BLG2,D,P+1),
    BLG1 != BLG2,
    soft_constraint("TravelDistance",W,Prior).

% Hard constraint
:- scheduled_curricula(Cu,BLG1,D,P),
   scheduled_curricula(Cu,BLG2,D,P+1),
   BLG1 != BLG2,
   hard_constraint("TravelDistance").

% End

%#include "soft_split/s7_travel_distance_aggregate.lp".
% ---- inlined from soft_split/s8_room_suitability.lp ----
%%% RoomSuitability: Some rooms may be not suitable for a given course
%%% because of the absence of necessary equipment (projector,
%%% amplification, . . . ). Each lecture of a course in an unsuitable
%%% room counts as 1 violation.

% Soft constraint
penalty("RoomSuitability",assigned(C,R,D,P),W,Prior) :- 
	assigned(C,R,D,P),
	room_constraint(C,R),
	soft_constraint("RoomSuitability",W,Prior).

% Hard constraint
:- assigned(C,R,D,P), room_constraint(C,R), hard_constraint("RoomSuitability").

% End

% ---- inlined from soft_split/s9_double_lectures.lp ----
%%% DoubleLectures: Some courses require that lectures in the same day
%%% are grouped together (double lectures). For a course that requires
%%% grouped lectures, every time there is more than one lecture in one
%%% day, a lecture non-grouped to another is not allowed. Two lectures
%%% are grouped if they are adjacent and in the same room. Each
%%% non-grouped lecture counts as 1 violation.

% Soft constraint
penalty("DoubleLectures",non_grouped_lecture(C,R,D,P),W,Prior) :- 
	course(C,_,_,_,_,1),
	d(D),
	2 { assigned(C,D,PPD) },
	assigned(C,R,D,P),
	not assigned(C,R,D,P-1),
	not assigned(C,R,D,P+1),
	soft_constraint("DoubleLectures",W,Prior).

% Hard constraint
:- course(C,_,_,_,_,1), d(D), 2 { assigned(C,D,PPD) },
   assigned(C,R,D,P),
   not assigned(C,R,D,P-1),
   not assigned(C,R,D,P+1),
   hard_constraint("DoubleLectures").

% End

% END

% ---- inlined from encoding/obj.lp ----
%%% Objective function

#minimize { P@L,C,S : penalty(S,C,P,L) }.

% End

#show assigned/4.
%#show assigned/3.
%#show penalty/3.

% End




