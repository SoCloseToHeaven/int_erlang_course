%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. июнь 2024 18:22
%%%-------------------------------------------------------------------
-module(server_sup).
-author("dmitry").

-behavior(supervisor).
%% API
-export([init/1, start_link/0]).


start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) -> {ok, {{one_for_all, 0, 1}, []}}.



