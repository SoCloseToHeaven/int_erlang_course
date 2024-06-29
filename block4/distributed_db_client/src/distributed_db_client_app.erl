%%%-------------------------------------------------------------------
%% @doc distributed_db_client public API
%% @end
%%%-------------------------------------------------------------------

-module(distributed_db_client_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    distributed_db_client_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
