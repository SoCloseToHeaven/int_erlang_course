%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. июнь 2024 17:59
%%%-------------------------------------------------------------------
-module(exceptions).
-author("dmitry").

%% API
-export([
  catch_example/0,
  get_header/1,
  try_catch_example/0,
  catch_exit/0,
  kill_process_example/0
]).



%%this function exists only to throw exceptions (case_clause)
get_header(Var) ->
  case Var of
    [H | _T] -> H
  end.

catch_example() ->
  catch get_header(atom).


%%Try catch construction is used only for exceptions raised by throw/1
try_catch_example() ->
  try
    throw(all_ok)
  catch
    all_ok -> caught
  end.

%%Exit signal can also be caught by catch construction
catch_exit() -> catch exit(all_ok).



kill_process_example() ->
  Pid = spawn(
    fun() ->
      process_flag(trap_exit, true), %% Put exit signal to mailbox as a regular message
      Pid = self(),
      receive
        {Atom, From, Reason} when is_atom(Atom) andalso is_pid(From) ->
          io:format("~w: GOT MESSAGE: ~w\n", [Pid, Reason])
      end,
      io:format("~w: Done", [Pid])
    end
  ),
  timer:sleep(1 * 1000),
  exit(Pid, i_just_wanted_to).



