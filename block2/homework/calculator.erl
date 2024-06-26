%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. июнь 2024 22:31
%%%-------------------------------------------------------------------
-module(calculator).
-author("dmitry").

-include_lib("kernel/include/logger.hrl").

-define(ALLOWED_OPERATIONS, ['+', '-', '*', '/']).

%% API
-export([
  connect/0,
  handle_connection/0,
  calculate/2,
  execute_operation/1
]).


connect() -> spawn(?MODULE, handle_connection, []).

handle_connection() ->
  receive
    {From, Request} when is_pid(From) ->
      Result = catch execute_operation(Request),
      From ! Result
  end,
  handle_connection().


execute_operation({Atom, [Num, {NextOp, NextArgs}]}) -> execute_operation({Atom, [Num] ++ [execute_operation({NextOp, NextArgs})]});
execute_operation({Operation, Args}) ->
  case is_allowed(Operation) of
    true -> erlang:apply(erlang, Operation, Args);
    _ -> throw(operation_not_allowed)
  end;
execute_operation(_) -> {error, bad_request}.

calculate(Pid, {Operation, Args} = Message) when is_atom(Operation) andalso is_list(Args) ->
    From = self(),
    Pid ! {From, Message},
    receive
      Reply -> Reply
    end.


is_allowed(Operation) -> lists:member(Operation, ?ALLOWED_OPERATIONS).


