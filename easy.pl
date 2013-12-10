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
  print(Index), nl,
  List = [HeadOneSched, HeadOneSched, HeadOneSched | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

help_convert([HeadOneSched|TailOneSched], List, Index):-
  2 =:= Index mod 5,
  print(Index), nl,
  List = [HeadOneSched, HeadOneSched, HeadOneSched, HeadOneSched | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

help_convert([HeadOneSched|TailOneSched], List, Index):-
  3 =:= Index mod 5,
  print(Index), nl,
  List = [HeadOneSched, HeadOneSched, HeadOneSched, HeadOneSched | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

help_convert([HeadOneSched|TailOneSched], List, Index):-
  4 =:= Index mod 5,
  print(Index), nl,
  List = [HeadOneSched, HeadOneSched, HeadOneSched, 0 | TailSlotSchedule],
  NewIndex is Index + 1,
  help_convert(TailOneSched, TailSlotSchedule, NewIndex).

% help_convert([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], NewSched, 0).
