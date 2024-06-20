%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. июнь 2024 22:52
%%%-------------------------------------------------------------------
-module(monitors_test).
-author("dmitry").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([
  spawn_monitors_test/0
]).

-define(MONITORS_COUNT, 3).



spawn_monitors_test() ->
  MonitorsFunc = fun() -> ok end,
  Monitors = monitors:spawn_monitors(?MONITORS_COUNT, MonitorsFunc),

  ?assert(is_list(Monitors)),

  ?assert(
    lists:any(
      fun({Pid, Ref}) -> is_pid(Pid) andalso is_reference(Ref) end,
      Monitors
    )
  ),

  MonitorsLen = length(Monitors),

  ?assertEqual(?MONITORS_COUNT, MonitorsLen),

  monitors:terminate(Monitors).

