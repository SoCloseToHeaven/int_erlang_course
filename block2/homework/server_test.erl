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
  test_add_example/0,
  parallel_connections_test/0,
  parallel_connection_fun/2,
  test_polish_notation/0
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

parallel_connection_fun(List, ServerID) when is_list(List) andalso is_pid(ServerID) ->
  Pid = self(),
  {ok, Result} = server:calculate(ServerID, {add, List}),
  io:format("[~w] - List: ~w - Result: ~w~n", [Pid, List, Result]).

parallel_connections_test() ->
  ServerID = server:connect(),

  AllArgs = [
    [rand:uniform(J)  || J <- lists:seq(10, 20)] || _I <- lists:seq(1, 4)
  ],
  ExpectedMap = maps:from_list([{K, lists:sum(K)} || K <- AllArgs]),
  io:format("List to expected: ~w~n", [ExpectedMap]),

  Spawned = [spawn(?MODULE, parallel_connection_fun, [List, ServerID]) || List <- AllArgs],
  io:format("Spawned: ~w~nPlease wait for results!~n", [Spawned]).


test_polish_notation() ->
  io:format("@@@ Polish Notation Test @@@~n", []),
  ServerID = server:connect(),

  Request1 = {add,
    [1,
      {'div',
        [2,
          {sub,
            [5, 5]
          }
        ]
      }
    ]
  },
  Request2 = {add,
    [1,
      {'div',
        [2,
          {add,
            [1, 1]
          }
        ]
      }
    ]
  },
  io:format("Server ID - ~w~n", [ServerID]),

  Response1 = server:calculate(ServerID, Request1),
  Response2 = server:calculate(ServerID, Request2),
  {Response1, Response2}.

