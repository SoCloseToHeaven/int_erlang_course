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

-export([start_server/0, start/1, stop/0]).
-export([loop/1, par_connect/1, accept/2, init_db/0]).
-export([handle_command/1,execute_command/2, get_first/1, transform_execute/1]).


listen() -> gen_tcp:listen(?SERVER_PORT, [{active, false},{packet,4}]).

%% Public
start_server() ->
  init_db(),
  start(listen()).


start({ok, ListenSocket}) -> spawn_monitor(?MODULE, par_connect, [ListenSocket]);
start({error, _Reason} = Error) -> Error.




%% Public
stop() -> mnesia:stop().


%% Private
init_db() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(entry, [{attributes, record_info(fields, entry)}]).

accept({ok, Socket}, Listen) ->
  io:format("SERVER - ~p - LISTEN SOCKET ACCEPTED CONNECTION WITH SOCKET - ~p ~n", [Listen, Socket]),

  Pid = spawn(?MODULE, par_connect, [Listen]),
  io:format("SERVER - ~p - LISTEN SOCKET IS READY FOR FURTHER CONNECTIONS - ~p - NEXT PAR CONNECT PID~n", [Listen, Pid]),

  loop(Socket);
accept(Other, Listen) ->
  io:format("SERVER - ~p - LISTEN SOCKET CAN'T ACCEPT CONNECTION - ~p ~n", [Listen, Other]),
  par_connect(Listen).

par_connect(Listen) -> accept(gen_tcp:accept(Listen), Listen).

loop(Socket) -> handle_receive(Socket, fun() -> loop(Socket) end).

handle_receive(Socket, Callback) ->
  receive
    Request -> handle_receive_msg(Request, Callback)
  after ?SERVER_RECEIVE_TIMEOUT ->
    io:format("DEBUG - ~p - SOCKET RECEIVER TIMEOUT ~p - PID ~n", [Socket, self()]),
    gen_tcp:close(Socket)
  end.



handle_receive_msg({tcp_closed, _Socket}, _Callback) -> io:format("Client Socket closed ~n");
handle_receive_msg({tcp, Socket, Bin}, Callback) ->
  io:format("RECEIVED BINARY - ~p~n", [Bin]),
  Str = binary_to_term(Bin),
  Reply = transform_execute(Str),
  io:format("SERVER REPLY - ~p~n", [Reply]),
  BinReply = term_to_binary(Reply),
  gen_tcp:send(Socket, BinReply),
  Callback().


handle_command(Str) -> transform_execute(string:split(Str, " ", all)).

transform_execute([CommandText | Args]) ->
  CommandAtom = list_to_existing_atom(CommandText),
  mnesia:transaction(?MODULE, execute_command, [CommandAtom, Args]);
transform_execute(_Other) -> {error, bad_command}.


get_first([]) -> {error, no_such_element};
get_first([H | _T]) -> {ok, H}.

execute_command('get', [Key | _T]) -> get_first(mnesia:read(#entry{key = Key}));
execute_command('set', [Key | [Value | _T]]) -> {mnesia:write(#entry{key = Key, value = Value}), Key, Value};
execute_command('delete', [Key | _T]) -> {mnesia:delete_object(#entry{key = Key}), Key};
execute_command(Command, _Args) -> {error, bad_option, Command}.