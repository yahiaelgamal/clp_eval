:- use_module(library(clpfd)).
:- use_module(library(lists)).
% Day offs are 0-based
% Teams are 1-based
top_level_schedule(TutsSchedules, TAsNames, TAsSchedules, TAsDaysOff, Teams, EvalSched, EvalTAs):-
  convert(TutsSchedules, ExpandedTutsSchedules),
  convert(TAsSchedules, ExpandedTAsSchedules),
  apply_days_off(ExpandedTAsSchedules, TAsDaysOff, ExpandedTAsSchedulesWithDaysOff),
  schedule(ExpandedTutsSchedules, ExpandedTAsSchedulesWithDaysOff, Teams, EvalSched, EvalTAs),
  ta_evalSlots_distinct(EvalTAs, EvalSched),
  append(EvalSched, EvalTAs, Vars),
  max_member(X, EvalSched),
  % labeling([], Vars),
  labeling([minimize(X)], Vars),
  %print(EvalSched),nl,
  %print(EvalTAs),nl,
  pretty_print(EvalSched, EvalTAs, TAsNames),
  %print('full stop'),
  print(X).

apply_days_off([], [], []).
apply_days_off([OldTASchedHead|OldTASchedTail], [TADayOff|TAsDaysOff], [TASchedHead|TASchedTail]):-
  help_apply_days_off(OldTASchedHead, TADayOff, TASchedHead, 0),
  apply_days_off(OldTASchedTail, TAsDaysOff, TASchedTail).

% expects dayoff 0-based
help_apply_days_off([],_,[],_).
help_apply_days_off([_|TailOldTAScheds], DayOff, [TASched| TailTAScheds], Index):-
  DayOff is Index // 19,
  TASched = 1,
  NewIndex is Index + 1,
  help_apply_days_off(TailOldTAScheds, DayOff, TailTAScheds, NewIndex).

help_apply_days_off([OldTASched|TailOldTAScheds], DayOff, [TASched| TailTAScheds], Index):-
  \+(DayOff is Index // 19),
  TASched = OldTASched,
  NewIndex is Index + 1,
  help_apply_days_off(TailOldTAScheds, DayOff, TailTAScheds, NewIndex).

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

  % 1 week
  % domain(EvalSched, 1, 114),

  % 2 weeks (sloow)
  domain(EvalSched, 1, 228),
  domain(EvalTAs, 1, LenTAs),
  scheduleTeams(TutsSchedules, TAsSchedules, Teams, EvalSched, EvalTAs).

scheduleTeams(_,_,[], [],[]).
scheduleTeams(TutsSchedules, TAsSchedules, [[Tut1,Tut2,Tut3]|Teams], [EvalSlot|EvalScheds], [EvalTA|EvalTAs]):-
  NormalEvalSlot #= ((EvalSlot-1) mod 114) + 1,
  nth1(Tut1, TutsSchedules, Tut1Sched),
  nth1(Tut2, TutsSchedules, Tut2Sched),
  nth1(Tut3, TutsSchedules, Tut3Sched),
  element(NormalEvalSlot, Tut1Sched,0),
  element(NormalEvalSlot, Tut2Sched,0),
  element(NormalEvalSlot, Tut3Sched,0),

  flatten(TAsSchedules, Flattened), % rename

  % 1 week
  % element(TASlot, Flattened, 0),
  % EvalSlot #= ((TASlot - 1) mod 114) + 1,
  % EvalTA #= ((TASlot - 1) / 114) + 1,

  % TWO WEEKS (Slooow)
  double(Flattened, Doubled), % to support two weeks
  element(TASlot, Doubled, 0), 
  EvalSlot #= ((TASlot - 1) mod 228) + 1,
  EvalTA #= ((TASlot - 1) / 228) + 1,

  scheduleTeams(TutsSchedules, TAsSchedules, Teams, EvalScheds, EvalTAs).

scheduleTeams(TutsSchedules, TAsSchedules, [[Tut1,Tut2]|Teams], [EvalSlot|EvalScheds], [EvalTA|EvalTAs]):-
  NormalEvalSlot #= ((EvalSlot-1) mod 114) + 1,
  nth1(Tut1, TutsSchedules, Tut1Sched),
  nth1(Tut2, TutsSchedules, Tut2Sched),
  element(NormalEvalSlot, Tut1Sched,0),
  element(NormalEvalSlot, Tut2Sched,0),

  flatten(TAsSchedules, Flattened), % rename
  double(Flattened, Doubled), % to support two weeks
  element(TASlot, Doubled, 0),
  EvalSlot #= ((TASlot - 1) mod 228) + 1,
  EvalTA #= ((TASlot - 1) / 228) + 1,
  scheduleTeams(TutsSchedules, TAsSchedules, Teams, EvalScheds, EvalTAs).

ta_evalSlots_distinct(EvalSched_ta, EvalSched_time):-
  makeTASlots(EvalSched_ta, EvalSched_time, TASlots),
  all_distinct(TASlots).

makeTASlots([], [], []).
makeTASlots([TA|EvalSched_ta], [Time|EvalSched_time], [Slot|TASlots]):-
  Slot #= TA * 228 + Time,
  makeTASlots(EvalSched_ta, EvalSched_time, TASlots).

pretty_print([], [], _).
pretty_print([H|EvalSched_time], [H2|EvalSched_ta], TAsNames):-
  get_time(H, Day, Hour, Min),
  nth1(H2, TAsNames, TAName),
  print(H), print('\t'), print(Day),print(' '), print(Hour), print(':'), 
  print(Min), print('\t'), print(TAName), nl,flush_output,
  pretty_print(EvalSched_time, EvalSched_ta, TAsNames).

get_time(EvalSlot, DayName, Hour, Min):-
  day_name(EvalSlot, DayName),
  Hour is (17 + ((EvalSlot-1) mod 19) ) // 2,
  Min is 30 * ((1+((EvalSlot-1) mod 19)) mod 2).

day(EvalSlot, Day):-
  Day #= (EvalSlot-1) / 19.

day_name(EvalSlot, DayName):-
  day(EvalSlot, Day),
  DayMod #= Day mod 6,
  Relation = [[0, sat], [1, sun], [2, mon], [3, tue], [4, wed], [5, thur]],
  nth0(_, Relation, [DayMod, DayName]).

double(X, Y):-
  flatten([X,X], Y).

flatten(List, FlattenedList):-
	flatten(List, [], FlattenedList).

flatten([], Flattened, Flattened).
flatten([H|T], FlattenedSoFar, Flattened):-
	append(FlattenedSoFar, H, NewFlattenedSoFar),
	flatten(T, NewFlattenedSoFar, Flattened).
