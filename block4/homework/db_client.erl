%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. июнь 2024 21:45
%%%-------------------------------------------------------------------
-module(db_client).
-author("dmitry").

-include("include/db.hrl").

%% API
-export([connect/0, loop/1]).


connect() ->
  {ok, Socket} = gen_tcp:connect(?SERVER_HOST, ?SERVER_PORT, [binary, {packet, 4}]),
  loop(Socket).


loop(Socket) ->
  Input = io:get_line("Input request in one line: \n"),
  gen_tcp:send(Socket, term_to_binary(Input)),
  receive
    {tcp, Socket, Bin} ->
      io:format("GOT RESPONSE: ~p~n", [binary_to_term(Bin)]),
      loop(Socket);
    {tcp_closed, _Socket} -> io:format("Socket closed", [])
  end.
