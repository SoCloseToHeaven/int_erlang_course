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

-record(config, {
  table_info :: [{attributes, RecordInfo :: term()}],
  schema_location :: term(),
  debug :: none | verbose | debug | trace | false | true,
  core_dir :: term(),
  max_transfer_size :: term()
}).


-record(entry, {key :: term(), value :: term()}).



-define(DEFAULT_CONFIG, #config{
  table_info = [{attributes, record_info(fields, entry)}],
  schema_location = "~/distributed_db",
  debug = true,
  core_dir = "Mnesia",
  max_transfer_size = 64000
}).

-define(COMMANDS, 'get' | 'set' | 'match' | 'delete').



-export([
  record_to_table_info/1
  , init/1, handle_call/3, handle_cast/2]).

record_to_table_info(Record) when is_atom(Record) -> {attributes, record_info(fields, Record)}.

-spec init(Config :: #config{}) -> {ok, Pid :: pid()} | {error, Reason :: term()}.
init(#config{table_info = Info, schema_location = SchemaLoc, debug = DebugFlag, core_dir = CoreDirName, max_transfer_size = MaxTransferSize})
  -> erlang:error(not_implemented).

-spec process_command({Command :: ?COMMANDS, Args :: list()}) -> Result :: term() | {error, Reason :: term()}.
process_command({Command, Args}) -> erlang:error(not_implemented).


handle_call(Request, From, State) ->
  erlang:error(not_implemented).

handle_cast(Request, State) ->
  erlang:error(not_implemented).