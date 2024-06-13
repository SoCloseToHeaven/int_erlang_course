%%% @author SoCloseToHeaven <Author_Email>
%%% @copyright (C) 2024, SoCloseToHeaven
%%% @doc 
%%%
%%% @end
%%% Created : 14 Jun 2024 by SoCloseToHeaven <Author_Email>
-module(factorial).

-export([fact/1]).

fact(0) -> 1;
fact(N) when is_integer(N) andalso N > 0 -> N * fact(N - 1).