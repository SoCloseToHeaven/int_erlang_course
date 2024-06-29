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



-callback init(Config :: #config{}) -> {ok, Pid :: pid()} | {error, Reason :: term()}.

-callback process_command(Command :: atom(), Args :: list()) -> {ok, Result :: term()} | {error, Reason :: term()}.

-export([
  record_to_table_info/1
]).

record_to_table_info(Record) when is_atom(Record) -> {attributes, record_info(fields, Record)}.
