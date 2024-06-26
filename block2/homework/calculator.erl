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

%% API
-export([
  connect/0,
  handle_connection/0,
  apply_operation/1,
  add_operation/1,
  add_operation/2,
  calculate/2,
  sub_operation/1,
  multiply_operation/1,
  multiply_operation/2,
  divide_operation/1
]).


connect() -> spawn(?MODULE, handle_connection, []).

handle_connection() ->
  receive
    {From, Message} when is_pid(From) -> From ! apply_operation(Message)
  end,
  handle_connection().

apply_operation({Operation, Args} = Message) when is_atom(Operation) andalso is_list(Args) ->
  case Message of {Atom, [Num, {NextOp, NextArgs} = Next]}
    when is_atom(Atom) andalso is_number(Num) andalso is_atom(NextOp) andalso is_list(NextArgs) ->
      case apply_operation(Next) of
        {ok, Result} when is_number(Result) -> apply_operation({Atom, [Num, Result]});
        {error, Reason} when is_atom(Reason) -> {error, Reason};
        _Other -> {error, unsupported_behaviour}
      end;
    {add, Args} -> add_operation(Args);
    {sub, Args} -> sub_operation(Args);
    {mul, Args} -> multiply_operation(Args);
    {'div', Args} -> divide_operation(Args);
    _Other -> {error, no_such_operation}
  end
.

calculate(Pid, {Operation, Args} = Message) when is_atom(Operation) andalso is_list(Args) ->
    From = self(),
    Pid ! {From, Message},
    receive
      Reply -> Reply
    end.


add_operation([H | T]) when is_number(H) -> add_operation(H, T).
add_operation(Acc, [H | T]) when is_number(Acc) andalso is_number(H)-> add_operation(Acc + H, T);
add_operation(Acc, []) when is_number(Acc)-> {ok, Acc}.

sub_operation([H | T]) -> {ok, H - lists:sum(T)}.

multiply_operation(N) when is_number(N) -> multiply_operation([1 | [N]]);
multiply_operation([H | T]) when is_number(H) -> {ok, multiply_operation(1, [H | T])}.
multiply_operation(Acc, []) when is_number(Acc) -> Acc;
multiply_operation(Acc, [H | T]) when is_number(Acc) andalso is_number(H) ->
  NewAcc = Acc * H,
  multiply_operation(NewAcc, T).


divide_operation([H | T]) when is_number(H) ->
  case multiply_operation(T) of
    {ok, 0} -> {error, division_by_zero};
    {ok, Result} when is_number(Result) ->
      {ok, H / Result};
    _Other -> {error, unsupported_mul_result}
  end.



