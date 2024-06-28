%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. июнь 2024 17:46
%%%-------------------------------------------------------------------
-module(server).
-author("dmitry").

-behavior(server_behaviour).

%% API
-export([init/0, action/1]).
-export([server/1]).

-define(BASIC_STATE, [1, 2, 3, 4]).


init() -> spawn(?MODULE, server, [?BASIC_STATE]).


action(Pid) ->
  Pid ! self(),
  receive
    Msg -> Msg
  end.


server([]) -> ok;
server([H | T]) ->
  receive
    Pid when is_pid(Pid) ->
      Pid ! {ok, H, T},
      server(T)
  end.

