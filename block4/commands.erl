%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. июнь 2024 22:39
%%%-------------------------------------------------------------------
-module(commands).
-author("dmitry").

%% API
-export([
  process_command/1,
  get_value/1
]).


process_command(Str) ->
  [Command | Args] = string:split(Str, " ", all),
  case Command of
    "get" -> get_value(
      lists:nth(1, Args)
    )
  end.


get_value(Key) ->
  F = fun() ->
        Oid = {entry, Key},
        Entries = mnesia:read(Oid),
        case Entries =:= [] of
          true -> does_not_exist;
          false -> lists:nth(1, Entries)
        end
      end,
  mnesia:transaction(F).
