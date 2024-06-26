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

-include_lib("eunit/include/eunit.hrl").

connect_test() ->
  Pid = calculator:connect(),

  timer:sleep(?SLEEP_TIME),

  ?assert(is_process_alive(Pid)),

  exit(Pid, normal).
