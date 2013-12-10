:- use_module(library(clpfd)).
:- use_module(library(lists)).
top_level_schedule(TutsSchedules, TAsNames, TAsSchedules, TAsDaysOff, Teams, EvalSched, EvalTAs):-
  convert(TutsSchedules, NewTutsSchedules),
  convert(TAsSchedules, NewTAsSchedules),
  % will applydayoffs in TAs scheudles
  schedule(NewTutsSchedules, NewTAsSchedules, Teams, EvalSched, EvalTAs),
  ta_evalSlots_distinct(EvalTAs, EvalSched),
  %maximum(EvalSched, X),
  append(EvalSched, EvalTAs, Vars),
  %labeling([min(X)], Vars).
  print('FULL STOP').


%  convert([[   1,1,0,1,1,
%               0,1,1,0,1,
%               0,0,0,1,0,
%               1,1,1,1,0,
%               0,1,0,1,0,
%               1,1,1,1,1],
%           [   0,0,1,1,1,
%               1,0,1,1,0,
%               0,1,1,0,0,
%               0,0,1,1,1,
%               0,1,1,1,0,
%               1,1,1,1,1],
%            [  0,1,0,1,1,
%               0,1,1,1,1,
%               1,1,1,0,0,
%               1,0,0,1,1,
%               0,0,1,0,0,
%               1,1,1,1,1]], SlotSchedule)

convert([], []).
convert([OneSched|ScheduleTail], [OneSchedule2|SlotScheduleTail]):-
  help_convert(OneSched, OneSchedule2, 0),
  convert(ScheduleTail, SlotScheduleTail).

help_convert([],[],_).
help_convert([HeadOneSched|TailOneSched], List, Index):-
  0 =:= Index mod 5,
  List = [HeadOneSched, HeadOneSched, HeadOneSched, 0 | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

help_convert([HeadOneSched|TailOneSched], List, Index):-
  1 =:= Index mod 5,
  List = [HeadOneSched, HeadOneSched, HeadOneSched | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

help_convert([HeadOneSched|TailOneSched], List, Index):-
  2 =:= Index mod 5,
  List = [HeadOneSched, HeadOneSched, HeadOneSched, HeadOneSched | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

help_convert([HeadOneSched|TailOneSched], List, Index):-
  3 =:= Index mod 5,
  List = [HeadOneSched, HeadOneSched, HeadOneSched, HeadOneSched | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

help_convert([HeadOneSched|TailOneSched], List, Index):-
  4 =:= Index mod 5,
  List = [HeadOneSched, HeadOneSched, HeadOneSched, 0 | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

% Tutorials Schedule
% Scheudles here are 19 * 6
%help_convert([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], NewSched, 0).
schedule(TutsSchedules, TAsSchedules, Teams, EvalSched, EvalTAs):-
  length(Teams, LenTeams),
  length(TAsSchedules, LenTAs),
  length(EvalSched, LenTeams),
  length(EvalTAs, LenTeams),

  EvalSched ins 1..228,
  EvalTAs ins 1..LenTAs,
  scheduleTeams(TutsSchedules, TAsSchedules, Teams, EvalSched, EvalTAs).

scheduleTeams(_,_,[], [],[]).
scheduleTeams(TutsSchedules, TAsSchedules, [[Tut1,Tut2,Tut3]|Teams], [EvalSlot|EvalScheds], [EvalTA|EvalTAs]):-
  NormalEvalSlot #= ((EvalSlot-1) mod 114) +1,
  nth1(Tut1, TutsSchedules, Tut1Sched),
  nth1(Tut2, TutsSchedules, Tut2Sched),
  nth1(Tut3, TutsSchedules, Tut3Sched),
  element(NormalEvalSlot, Tut1Sched,0),
  element(NormalEvalSlot, Tut2Sched,0),
  element(NormalEvalSlot, Tut3Sched,0),

  print('%%%%%%%%%%%%%%%%%%%%%%'),nl,
  flatten(TAsSchedules, Flattened), % rename
  element(TASlot, Flattened, 0),
  EvalSlot #= ((TASlot - 1) mod 114) + 1,
  EvalTA #= ((TASlot - 3) / 114) + 1,
  scheduleTeams(TutsSchedules, TAsSchedules, Teams, EvalScheds, EvalTAs).

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
	TA #\= TA1,
	get_ta_evalSlots(TA, TAs, EvalSlots, TAEvalSlots).

maximum([X], X).
maximum([H|T], H):-
	H #> Max, 
	maximum(T, Max).
maximum([H|T], Max):-
	H #=< Max,
	maximum(T, Max).
