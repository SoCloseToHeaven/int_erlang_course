%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. июнь 2024 20:32
%%%-------------------------------------------------------------------
-module(storage).
-author("dmitry").

-behavior(gen_server).


-record(entry, {key :: term(), value :: term()}).
-record(state, {}).

-define(COMMANDS, 'get' | 'set' | 'match' | 'delete').



-export([
  record_to_table_info/1
  , init/1, handle_call/3, handle_cast/2]).

record_to_table_info(Record) when is_atom(Record) -> {attributes, record_info(fields, Record)}.

-spec init([]) -> {ok, State :: #state{}} | {error, Reason :: term()}.
init([]) ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(entry, [{attributes, record_info(fields, entry)}]),
  {ok, #state{}}.

-spec process_command({Command :: ?COMMANDS, Args :: list()}) -> Result :: term() | {error, Reason :: term()}.
process_command({Command, Args}) -> erlang:error(not_implemented).


handle_call(Request, From, State) ->
  erlang:error(not_implemented).

handle_cast(_Request, _State) -> erlang:error(not_implemented).