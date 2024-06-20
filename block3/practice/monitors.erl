%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. июнь 2024 02:07
%%%-------------------------------------------------------------------
-module(monitors).
-author("dmitry").

-include("monitors.hrl").

%% API
-export([
  spawn_monitors/2,
  psycho/2,
  spawn_psycho/2,
  spawn_citizens/2,
  weird_situation_example/0,
  terminate/1
]).


%%spawn_monitors(0, List, Function) when is_list(List) andalso is_function(Function) ->
%%  Info = spawn_monitor(Function),
%%  List ++ [Info];
%%spawn_monitors(N, List, Function) when is_integer(N) andalso is_list(List) andalso is_function(Function) ->
%%  Info = spawn_monitor(Function),
%%  NewList = List ++ [Info],
%%  spawn_monitors(N - 1, NewList, Function).
%%spawn_monitors(N, Function) when is_integer(N) andalso is_function(Function) -> spawn_monitors(N, [], Function).

spawn_monitors(N, Function) when is_integer(N) andalso N > 0 -> [spawn_monitor(Function) || _ <- lists:seq(1, N)].


%% Currently there can only be one psycho
psycho(List, Interval) when is_list(List) andalso is_integer(Interval) andalso Interval > 0 ->
  ID = self(),

  io:format("~w: Psycho calmed down for ~p ms...~n", [ID, Interval]),
  timer:sleep(Interval),
  io:format("~w: Psycho woke up, something is going to happen...~n", [ID]),

  Len = length(List),

  case Len of
    0 -> exit(suicide);
    _ -> ok
  end,

  SuicideFlag = rand:uniform(),

  ToKill = case SuicideFlag of
    0 -> exit(suicide);
    _ -> rand:uniform(Len)
  end,
  ToDelete = lists:nth(ToKill, List),

  io:format("~w: Psycho attempting to kill ~p process~n", [ID, ToDelete]),
  exit(ToDelete, killed),

  psycho(
    lists:delete(ToDelete, List),
    Interval
  ).

spawn_psycho(List, Interval) when is_list(List) and is_integer(Interval) -> spawn_monitor(fun() -> psycho(List, Interval) end).


citizen(Interval) when is_integer(Interval) andalso Interval > 0 ->
  ID = self(),

  io:format("~w: Citizen is still alive!~n", [ID]),
  timer:sleep(Interval),

  citizen(Interval).

spawn_citizens(N, Interval) when is_integer(N) andalso is_integer(Interval) -> spawn_monitors(N, fun() -> citizen(Interval) end).

weird_situation_example() ->

  Citizens = spawn_citizens(10, ?CITIZEN_INTERVAL),

  Prey = lists:map(fun({Pid, _Ref} = _) -> Pid end, Citizens),
  Psycho = spawn_psycho(Prey, ?PSYCHO_INTERVAL),

  receive_loop(Citizens),

  terminate(Citizens ++ [Psycho]).


receive_loop([]) -> io:format("Seems like no one left...~n", []);
receive_loop(Citizens) when is_list(Citizens) ->
    receive
      #down_msg{state = 'DOWN', ref = Ref, process = process, pid = Pid, reason = killed} = Msg
        when is_reference(Ref) andalso is_pid(Pid) ->
          erlang:display(Msg),
          receive_loop(lists:delete({Pid, Ref}, Citizens));
      #down_msg{state = 'DOWN', ref = Ref, process = process, pid = Pid, reason = suicide} = Msg
        when is_reference(Ref) andalso is_pid(Pid) ->
          erlang:display(Msg);
      _ -> receive_loop(Citizens)
  end.

terminate(List) when is_list(List) ->
  c:flush(),
  lists:foreach(fun({Pid, Ref} = _Elem) -> demonitor(Ref), exit(Pid, normal) end, List).


