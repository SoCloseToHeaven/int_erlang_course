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