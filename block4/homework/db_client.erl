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
-export([connect/0, loop/1, handle_input/1, handle_receive_msg/2, handle_receive/1]).


connect() ->
  {ok, Socket} = gen_tcp:connect(?SERVER_HOST, ?SERVER_PORT, [binary, {packet, 4}]),
  loop(Socket).


loop(Socket) ->
  Input = handle_input(io:get_line(?INPUT_MESSAGE)),

  BinInput = term_to_binary(Input),

  io:format("GOT INPUT - ~p - BINARY - ~p - SENDING TO SOCKET - ~p ~n", [Input, BinInput, Socket]),

  ok = gen_tcp:send(Socket, BinInput),

  io:format("SENT VIA TCP PROTOCOL - ~p - BINARY - ~p - START RECEIVING - ~p ~n", [Input, BinInput, Socket]),

  handle_receive(fun() -> loop(Socket) end).

handle_input(eof) ->
  io:format("INPUT ENDED, STOPPING LOOP ~n", []),
  exit(normal);
handle_input({_Error, _ErrorDescr} = Error) -> exit(Error);
handle_input(Input) -> string:to_lower(string:trim(Input)).

handle_receive(Callback) ->
  receive
    Response -> handle_receive_msg(Response, Callback)
  after ?CLIENT_RESPONSE_TIMEOUT ->
    io:format("SOCKET CONECTION TIMEOUT - PID TIMEOUT - ~p ~n", [self()])
  end.


handle_receive_msg({tcp_closed, Socket}, _Callback) -> io:format("SERVER SOCKET CLOSE - NEED RECONNECT - ~p ~n", [Socket]);
handle_receive_msg({tcp_error = Error, Socket}, _Callback) -> io:format("Socket - ~p - Error occured - ~p ~n ", [Socket, Error]);
handle_receive_msg({tcp, _Socket, Data}, Callback) ->
  Result = binary_to_term(Data),
  io:format("GOT RESPONSE - ~p - BINARY - ~p ~n", [Result, Data]),
  Callback();
handle_receive_msg(Other, Callback) ->
  io:format("GOT INCORRECT MESSAGE - ~p ~n", [Other]),
  Callback().


