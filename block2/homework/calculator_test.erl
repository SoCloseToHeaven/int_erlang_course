%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. июнь 2024 00:03
%%%-------------------------------------------------------------------
-module(calculator_test).
-author("dmitry").

-define(SLEEP_TIME, 1 * 100).
-define(BASIC_ARGS, [1, 2]).
-define(ZERO_DIVISION_ARGS, [1, 0]).

-include_lib("eunit/include/eunit.hrl").
-include("calculator.hrl").

connect_test() ->
  Pid = calculator:connect(),

  timer:sleep(?SLEEP_TIME),

  ?assert(is_process_alive(Pid)),

  exit(Pid, normal).

basic_operations_test() ->
  Pid = calculator:connect(),

  RealResults = [calculator:calculate(Pid, {Operation, ?BASIC_ARGS}) || Operation <- ?ALLOWED_OPERATIONS],

  ExpectedResults = [erlang:apply(erlang, Operation, ?BASIC_ARGS) || Operation <- ?ALLOWED_OPERATIONS],

  ?assertEqual(RealResults, ExpectedResults),

  exit(Pid, normal).



zero_division_test() ->
  Pid = calculator:connect(),

  {'EXIT', {Reason, _}} = calculator:calculate(Pid, {'/', ?ZERO_DIVISION_ARGS}),

  ?assertEqual(badarith, Reason),

  exit(Pid, normal).

bad_request_test() ->
  Pid = calculator:connect(),

  Result = calculator:calculate(Pid, bad),

  ?assertEqual({error, bad_request}, Result),

  exit(Pid, normal).


polish_notation_test() ->
  Pid = calculator:connect(),

  Result = calculator:calculate(Pid, {'+', [1, {'+', ?BASIC_ARGS}]}),

  ?assertEqual(lists:sum([1] ++ ?BASIC_ARGS), Result),

  exit(Pid, normal).
