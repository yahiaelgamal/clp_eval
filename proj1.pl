:- use_module(library(clpfd)).

% TutSchedule=[[t1, free, free, not_free], [t2, not_free, free, not_free]], TASchedule = [[yahia, free, free, not_free], [nada, free, not_free, free]], Teams = [[1, t1, t2, t1], [2, t1, t1, t1]], schedule(TutSchedule, TASchedule, Teams, Slots).

% TutSchedule=[[t1, free, free, not_free], [t2, not_free, free, not_free], [t3, not_free, not_free, free],
% TAsSchedule = [[yahia, free, free, not_free], [nada, not_free, not_free, free]]
% Teams = [[1, t1, t2, t1], [2, t3, t3, t3]]
schedule(TutSchedule, TAsSchedule, Teams, Slots):-
  recursiveHelper(TutSchedule, TAsSchedule, Teams, Slots).

recursiveHelper(_, _, [], []).
recursiveHelper(TutSchedule, TAsSchedule, Teams, Slots):-
  [FirstTeam|RestTeams] = Teams,
  scheduleTeam(TutSchedule, TAsSchedule, FirstTeam, NewSlot),
  print('++++++++++'),print(NewSlot),print('++++++++++'), nl, nl, flush,

  recursiveHelper(TutSchedule, TAsSchedule, RestTeams, NewSlots),

  print('----------'),print('New Slots'), print(NewSlots),print('----------'), nl, nl, flush,
  print('%%%%%%%%%%'),print('New Slot'), print(NewSlot),print('%%%%%%%%%%'), nl, nl, flush,

  %Time is nth1(NewSlot,2), Name is nth1(NewSlot,3),
  sloppySlot = [_, Time, Name],
  %print(sloppySlot), nl,
  notmember(sloppySlot, NewSlots),
  print('append'),nl,
  append(NewSlots, [NewSlot], Slots).


% TutSchedule=[[t1, free, free, not_free], [t2, not_free, free, not_free]], TASched = [yahia, free, free, not_free], Team = [t1, t2, t1]
% TutSchedule=[[t1, free, free, not_free], [t2, not_free, free, not_free]],
% TASched = [yahia, free, free, not_free]
% Team = [TeamNum, t1, t2]
scheduleTeam(TutSchedule, TAsSchedule, [TeamNum|TeamTuts], [TeamNum, StartTime, TAName]):-
  nth1(1, TeamTuts, Mem1Tut),
  nth1(2, TeamTuts, Mem2Tut),
  nth1(3, TeamTuts, Mem3Tut), % fix this

  nth1(_, TutSchedule, [Mem1Tut|Mem1Sched]),
  nth1(_, TutSchedule, [Mem2Tut|Mem2Sched]),
  nth1(_, TutSchedule, [Mem3Tut|Mem3Sched]), % fix this

  nth1(StartTime, Mem1Sched, free),
  nth1(StartTime, Mem2Sched, free),
  nth1(StartTime, Mem3Sched, free), % fix thix

  nth1(_, TAsSchedule, [TAName|OneTAsSchedule]), % add day off
  nth1(StartTime, OneTAsSchedule, free).

notmember(X, L):-
  print('X is '), print(X),nl,
  print('L is '), print(L),nl,

  not(member(X, L)).
