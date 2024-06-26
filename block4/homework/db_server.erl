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

-export([start_server/0, stop_server/0]).
-export([loop/1, par_connect/1, init_db/0]).
-export([process_command/1, execute_command/2, get_first/1]).

%% Public
start_server() ->
  init_db(),
  {ok, Listen} = gen_tcp:listen(?SERVER_PORT, [binary, {packet, 4}, {reuseaddr, true}, {active, false}]),
  spawn(fun() -> par_connect(Listen) end).


%% Public
stop_server() -> mnesia:stop().


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

      Reply = process_command(Str),

      io:format("SERVER REPLY - ~p~n", [Reply]),

      BinReply = term_to_binary(Reply),

      gen_tcp:send(Socket, BinReply),

      loop(Socket);
    {tcp_closed, _Socket} -> io:format("Server socket closed ~n")
  end.


process_command(Str) ->
  [Command | Args] = string:split(Str, " ", all),

  mnesia:transaction(fun() -> execute_command(Command, Args) end).


get_first([]) -> {error, no_such_element};
get_first([H | _T]) -> {ok, H}.

execute_command(<<"get">>, [Key | _T]) -> get_first(mnesia:read(#entry{key = Key}));
execute_command(<<"set">>, [Key | [Value | []]]) -> {mnesia:write(#entry{key = Key, value = Value}), Key, Value};
execute_command(<<"delete">>, [Key | _T]) -> {mnesia:delete_object(#entry{key = Key}), Key};
execute_command(_Command, _Args) -> {error, bad_option}.