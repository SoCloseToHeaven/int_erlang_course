%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. июнь 2024 20:26
%%%-------------------------------------------------------------------
-module(calculator_server).
-author("dmitry").

-include("calculator_server.erl").

-record(state, {}).

-behavior(gen_server).

%% API
-export([init/1, start_link/0, handle_call/3]).
-export([execute_operation/1]).


start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) -> {ok, #state{}}.


handle_call({Op, Args}, _From, State) -> {reply, State};
handle_call(Request, _From, State) -> {reply, {error, {unknown_request, Request}}, State}.

handle_cast(_Request, State) -> {noreply, State}.


execute_operation({Op, Args}) -> todo.

