%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%                       Errors and Processes
%%% @end
%%% Created : 18. июнь 2024 00:35
%%%-------------------------------------------------------------------
-module(err_proc).
-author("dmitry").

%% API
-export([
  chain/1,
  chain/2,
  chain_receive/3,
  chain_receive/4,
  chain_use_example/0
]).


%%Chain of linked processes

chain_receive(N, Pid, Prev, Next)
  when is_integer(N) andalso is_pid(Pid) andalso is_pid(Prev) andalso is_pid(Next) ->
    timer:sleep(2 * 1000),

    receive
      {'EXIT', From, Reason} when is_pid(From) ->
        io:format("[N: ~w] ~w:  EXIT SIGNAL - CHAIN ENDPOINT: ~w~n", [N, Pid, Reason]),
        exit(Reason);
      {From, Original} = Msg when is_pid(From) ->
        io:format("[N: ~w] ~w:  GOT MESSAGE: ~p~n", [N, Pid, Msg]),

        To = case From of
               Prev -> Next;
               Next -> Prev
             end,
        To ! {Pid, Original},


        chain_receive(N, Pid, Prev, Next)
      end.


chain_receive(N, Pid, To) when is_integer(N) andalso is_pid(Pid) andalso is_pid(To) ->
  timer:sleep(2 * 1000),

  receive
    {'EXIT', From, Reason} when is_pid(From) ->
      io:format("[N: ~w] ~w:  EXIT SIGNAL - CHAIN ENDPOINT: ~w~n", [N, Pid, Reason]),
      exit(Reason);
    {From, Original} = Msg when is_pid(From) ->
      io:format("[N: ~w] ~w:  GOT MESSAGE: ~p~n", [N, Pid, Msg]),
      To ! {Pid, Original},

      chain_receive(N, Pid, To)
  end.


chain(0 = N, PrevID) when is_pid(PrevID) ->
  OriginalMessage = "This is simple chain",

  process_flag(trap_exit, true), %% Put exit signal to mailbox as a regular message
  Pid = self(),


  PrevID ! {Pid, OriginalMessage},

  io:format("[N: ~w] ~w: START MESSAGE CHAIN - ~p~n", [N, Pid, OriginalMessage]),

  chain_receive(N, Pid, PrevID);

chain(N, PrevID) when is_integer(N) andalso is_pid(PrevID) ->
  Pid = self(),

  process_flag(trap_exit, true), %% Put exit signal to mailbox as a regular message

  SpawnedID = spawn(fun() -> chain(N - 1, Pid) end),
  link(SpawnedID),

  chain_receive(N, Pid, PrevID, SpawnedID).

chain(N) when is_integer(N) ->
  Pid = self(),

  SpawnedID = spawn(fun() -> chain(N - 1, Pid) end),
  link(SpawnedID),

  process_flag(trap_exit, true), %% Put exit signal to mailbox as a regular message

  chain_receive(N, Pid, SpawnedID).



chain_use_example() ->
  Pid = spawn (fun() -> chain(4) end),
  timer:sleep(10 * 1000),
  exit(Pid, just_for_fun).