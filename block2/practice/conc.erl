%%% @author SoCloseToHeaven
%%% @copyright (C) 2024, SoCloseToHeaven
%%% @doc 
%%%
%%% @end
%%% Created : 14 Jun 2024 by SoCloseToHeaven
-module(conc).



-export([
    emulate_long_evaluations/1,
    long_random_fun/1,
    parralel_map/2,
    parallel_map_example/0,
    collect/1
]).

long_random_fun(Randomizer) when is_integer(Randomizer) andalso Randomizer >= 0 ->
        RandNum = rand:uniform(Randomizer),
        timer:sleep(1000 * RandNum),
        io:format("~p: Process stopped sleeping, it has been sleeping for ~p seconds\n", [self(), RandNum]).

emulate_long_evaluations(N) when is_integer(N) andalso N >= 1 ->
    [proc_lib:spawn(?MODULE, long_random_fun, [I]) || I <- lists:seq(1, N)].



parallel_map_example() -> 
    Function = fun(Elem) -> Elem + 1 end,
    List = [1, 2, 3, 4],

    parralel_map(Function, List),

    collect([]).


parralel_map(_Func, []) ->
    ParentID = self(),

    proc_lib:spawn(fun() -> ParentID ! ok end);

parralel_map(Function, [H | T]) ->
    ParentID = self(),

    proc_lib:spawn(fun() -> ParentID ! Function(H) end),

    parralel_map(Function, T).


collect(List) ->
    receive
        ok -> List;
        Elem -> 
            NewList = List ++ [Elem],
            collect(NewList)
    end.
 