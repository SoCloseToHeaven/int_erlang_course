%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. июнь 2024 17:37
%%%-------------------------------------------------------------------
-module(server_behaviour).
-author("dmitry").




-record(state, {args :: list()}).

-callback init() -> Pid :: pid().
-callback action(Pid) -> {ok, Head :: term(), Args :: list()} | {error, Reason :: term()}.
