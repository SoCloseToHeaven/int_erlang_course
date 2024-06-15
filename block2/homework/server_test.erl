%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. июнь 2024 00:03
%%%-------------------------------------------------------------------
-module(server_test).
-author("dmitry").

%% API
-export([
  test_add_example/0
]).

test_add_example() ->

  io:format("@@@ Add Operation Test @@@~n", []),
  ServerID = server:connect(),
  io:format("Server ID - ~w~n", [ServerID]),

  AllArgs = [
    [rand:uniform(J)  || J <- lists:seq(10, 20)] || _I <- lists:seq(1, 4)
  ],
  ExpectedResults = [lists:sum(List) || List <- AllArgs],
  io:format("All Arguments: ~w~nExpected: ~w~n", [AllArgs, ExpectedResults]),

  RealResults = [element(2, server:calculate(ServerID, {add, List})) || List <- AllArgs],
  io:format("Real: ~w\n", [RealResults]).