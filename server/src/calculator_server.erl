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

-define(ALLOWED_OPERATIONS, ['+', '-', '*', '/']).

-behavior(gen_server).

%% API
-export([init/1, start_link/0, handle_call/3, handle_cast/2]).
-export([execute_operation/1, is_allowed/1]).


start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) -> {ok, #state{}}.


handle_call(Msg, _From, State) -> {reply, execute_operation(Msg), State};
handle_call(Request, _From, State) -> {reply, {error, {unknown_request, Request}}, State}.

handle_cast(_Request, State) -> {noreply, State}.


execute_operation({Op, Args}) ->
  case is_allowed(Op) of
    true -> erlang:apply(erlang, Op, Args);
    _ -> {error, bad_operation}
  end;
execute_operation(_) -> {error, bad_request}.

is_allowed(Operation) -> lists:member(Operation, ?ALLOWED_OPERATIONS).

