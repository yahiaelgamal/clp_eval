:- use_module(library(clpfd)).
% evaluation_scheduling([[	1,1,0,1,1,
% 							0,1,1,0,1,
% 							0,0,0,1,0,
% 							1,1,1,1,0,
% 							0,1,0,1,0,
% 							1,1,1,1,1],
% 						[	0,0,1,1,1,
% 						 	1,0,1,1,0,
% 							0,1,1,0,0,
% 							0,0,1,1,1,
% 							0,1,1,1,0,
% 							1,1,1,1,1],
% 						 [	0,1,0,1,1,
% 							0,1,1,1,1,
% 							1,1,1,0,0,
% 							1,0,0,1,1,
% 							0,0,1,0,0,
% 							1,1,1,1,1]],
% 						[[nada, 	[1,0,1,0,0,	1,1,1,0,0,	0,0,1,1,0,	0,0,0,0,0,	1,1,1,1,1,	1,0,0,0,0], 3],
% 						 [jta_1, 	[0,0,0,0,0,	1,0,0,1,1,	0,1,1,0,0,	1,1,1,1,0,	0,0,1,0,0,	0,1,1,1,0], 0]],
% 						 [[0,0,0],
% 						 [0,0,2],
% 						 [1,2],
% 						 [0,1],
% 						 [0,1,2],
% 						 [0,1,2],
% 						 [0,1,2],
% 						 [1,1,1],
% 						 [2,2],
% 						 [0,2,0],
% 						 [2,2,1],
% 						 [0,2]],
% 						EvalSched_ta, EvalSched_time).

% any schedule is a 30 element (1 element for each slot of the week) list of 1s (busy) and 0s (free)

% TutSched		: 	list of tutorial schedules
%					index in list -> tutorial number				
% TASched		:	list where each element is of the form [ta_name, ta_schedule, ta_dayOff] where ta is a TA or a JTA and ta_dayOff is a number in 0..5 (Sat..Thu)
% Teams			: 	list where each element represents a team (idx in list -> team number) and is a list of the tutorial groups of the members of the team
% EvalSched_ta	:	list where element i represents the ta that will evaluate team i
% EvalSched_time: 	list where element i represents evaluation time of team i. ins 0..89 (30 slots * 3 evals/slot)
evaluation_scheduling(TutSched, TASched, Teams, EvalSched_ta, EvalSched_time):-
	length(Teams, NumTeams),
	length(EvalSched_ta, NumTeams),
	length(EvalSched_time, NumTeams),
	EvalSched_time ins 0..179,
	
	schedule_teams(TutSched, TASched, Teams, EvalSched_ta, EvalSched_time, 0),
	ta_evalSlots_distinct(EvalSched_ta, EvalSched_time),
	
	maximum(EvalSched_time, Max),
	labeling([min(Max)], EvalSched_time),
	
	print(EvalSched_time), nl,
	print(EvalSched_ta), nl,
	print(Max).
	
% imposes the constraints that every student must be free for their evaluation, as well as every TA
schedule_teams(_, _, _, _, [], _).
schedule_teams(TutSched, TASched, Teams, [TeamEvalTA|EvalSched_ta], [TeamEvalSlot|EvalSched_time], TeamNum):-
	% both student and TA must be free for the evaluation to take place
	team_is_free(Teams, TutSched, TeamNum, TeamEvalSlot),
	ta_is_free(TASched, TeamEvalTA, TeamEvalSlot),
	NewTeamNum #= TeamNum + 1,
	schedule_teams(TutSched, TASched, Teams, EvalSched_ta, EvalSched_time, NewTeamNum).
	
	
% checks if a Team is free during a given evaluation slot
% for 3 member teams
team_is_free(Teams, TutSched, TeamNum, TeamEvalSlot):-
	nth0(TeamNum, Teams, [Student1, Student2, Student3]),
	nth0(Student1, TutSched, Student1_sched),
	is_free(Student1_sched, TeamEvalSlot),
	nth0(Student2, TutSched, Student2_sched),
	is_free(Student2_sched, TeamEvalSlot),
	nth0(Student3, TutSched, Student3_sched),
	is_free(Student3_sched, TeamEvalSlot).
	
% for 2 member teams
team_is_free(Teams, TutSched, TeamNum, TeamEvalSlot):-
	nth0(TeamNum, Teams, [Student1, Student2]),
	nth0(Student1, TutSched, Student1_sched),
	is_free(Student1_sched, TeamEvalSlot),
	nth0(Student2, TutSched, Student2_sched),
	is_free(Student2_sched, TeamEvalSlot).
	
% checks if a TA is free during a given evaluation slot
ta_is_free(Sched, TA, EvalSlot):-
	nth0(_, Sched, TAList),
	nth0(0, TAList, TA),
	nth0(1, TAList, TA_sched),
	nth0(2, TAList, DayOff),
	is_free(TA_sched, EvalSlot),
	\+day(EvalSlot, DayOff).
	
% checks that no TA has more than one evaluation scheduled during one evaluation slot.
ta_evalSlots_distinct(EvalSched_ta, EvalSched_time):-
	list_to_set(EvalSched_ta, TAs),
	ta_evalSlots_distinct(TAs, EvalSched_ta, EvalSched_time).
	
ta_evalSlots_distinct([], _, _).
ta_evalSlots_distinct([TA|TAs], EvalSched_ta, EvalSched_time):-
	get_ta_evalSlots(TA, EvalSched_ta, EvalSched_time, TAEvalSlots),
	all_distinct(TAEvalSlots),
	ta_evalSlots_distinct(TAs, EvalSched_ta, EvalSched_time).
	
get_ta_evalSlots(_, [], [], []).
get_ta_evalSlots(TA, [TA|TAs], [EvalSlot|EvalSlots], [EvalSlot|TAEvalSlots]):-
	get_ta_evalSlots(TA, TAs, EvalSlots, TAEvalSlots).
get_ta_evalSlots(TA, [TA1|TAs], [_|EvalSlots], TAEvalSlots):-
	TA \= TA1,
	get_ta_evalSlots(TA, TAs, EvalSlots, TAEvalSlots).
	
% checks if the given schedule has a free slot during the evaluation slot time
is_free(Sched, EvalSlot):-
	slot(EvalSlot, Slot),
	nth0(Slot, Sched, 0).
	
% checks if the given evaluation slot takes place on the given day
day(EvalSlot, Day):-
	slot(EvalSlot, Slot),
	Day #= Slot / 5.
	
slot(EvalSlot, Slot):-
	EvalSlot_1 #= EvalSlot mod 90,
	Slot #= EvalSlot_1 / 3.
	
maximum([X], X).
maximum([H|T], H):-
	H #> Max, 
	maximum(T, Max).
maximum([H|T], Max):-
	H #=< Max,
	maximum(T, Max).