%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. июнь 2024 22:31
%%%-------------------------------------------------------------------
-module(server).
-author("dmitry").

-include_lib("kernel/include/logger.hrl").

%% API
-export([
  connect/0,
  handle_connection/0,
  apply_operation/1,
  add_operation/1,
  add_operation/2,
  calculate/2
]).


connect() ->
  Pid = spawn(?MODULE, handle_connection, []),
  io:format("Started Calculator Server with PID=~w~n", [Pid]),
  Pid.

handle_connection() ->
  ID = self(),
  receive
    {From, Message} when is_pid(From) ->
      io:format("Calculator Server PID#~p - Got Message - ~w~n", [ID, Message]),
      Reply = apply_operation(Message),
      io:format("Calculator Server PID#~p - Got Reply - ~w~n", [ID, Reply]),
      From ! Reply
  end,
  handle_connection().

apply_operation({Operation, Args} = Message) when is_atom(Operation) andalso is_list(Args) ->
  case Message of
    {add, Args} when is_list(Args) -> {ok, add_operation(Args)};
    _Other -> {error, no_such_operation}
  end
.

calculate(Pid, {Operation, Args} = Message) when is_atom(Operation) andalso is_list(Args) ->
    From = self(),
    Pid ! {From, Message},
    receive
      {ok, _Result} = Reply -> Reply
    end.


add_operation([H | T]) when is_number(H) -> add_operation(H, T).
add_operation(Acc, [H | T]) when is_number(Acc) andalso is_number(H)-> add_operation(Acc + H, T);
add_operation(Acc, []) when is_number(Acc)-> Acc.

