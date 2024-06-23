%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. июнь 2024 21:45
%%%-------------------------------------------------------------------
-module(db_server).
-author("dmitry").

-include("include/db.hrl").
-include("commands.erl").

-export([
  start_server/0,
  stop_server/0
]).

%% Public
start_server() ->
  init_db(),
  {ok, Listen} = gen_tcp:listen(
    ?SERVER_PORT,
    [binary, {packat, 4}, {reuseaddr, true}, {active, true}]
  ),
  spawn(fun() -> par_connect(Listen) end).


%% Public
stop_server() -> ok.


%% Private
init_db() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(entry, [{attributes, record_info(fields, entry)}]).

par_connect(Listen) ->
  {ok, Socket} = gen_tcp:accept(Listen),
  spawn(fun() -> par_connect(Listen) end),
  loop(Socket).


loop(Socket) ->
  receive
    {tcp, Socket, Bin} ->
      io:format("RECEIVED BINARY - ~p~n", [Bin]),
      Str = binary_to_term(Bin),
      %%      TODO
      loop(Socket)
  end.