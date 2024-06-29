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

-record(table_info, {
  atom :: atom(),
  record_info :: term()
}).

-record(config, {
  table_info :: #table_info{},
  schema_location :: term(),
  debug :: none | verbose | debug | trace | false | true,
  core_dir :: term(),
  max_transfer_size :: term()
}).



-define(DEFAULT_CONFIG, #config{
  %% TODO: WRITE CONFIG
}).



-callback init(Config :: #config{}) -> {ok, Pid :: pid()} | {error, Reason :: term()}.

%% TODO: add callback for handling commands


