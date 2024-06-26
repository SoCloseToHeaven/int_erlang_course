%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. июнь 2024 11:49
%%%-------------------------------------------------------------------
-module(db).
-author("dmitry").

%% API
-export([
  new/0,
  handle_connection/0,
  handle_connection/1,
  destroy/1,
  delete/2,
  read/2,
  match/2,
  send_then_receive/2,
  save/2
]).


new() -> spawn(fun() -> handle_connection() end).


handle_connection() -> handle_connection(#{}).
handle_connection(Storage) when is_map(Storage) ->
  {NewStorage, ID, ResAtom, Res} =
    receive
      {From, 'SAVE', {Key, Value} = Pair} when is_pid(From) ->
        Saved = maps:put(Key, Value, Storage),
        {Saved, From, ok, Pair};
      {From, 'READ', Key} when is_pid(From) ->
        Found = maps:find(Key, Storage),
        {Storage, From, ok, Found};
      {From, 'DELETE', Key} when is_pid(From) ->
        Removed = maps:remove(Key, Storage),
        {Removed, From, ok, Key};
      {From, 'MATCH', Value} when is_pid(From) ->
        Keys = maps:filter(fun(_K, V) -> Value == V end, Storage),
        {Storage, From, ok, Keys}
    end,
  ID ! {self(), ResAtom, Res},
  handle_connection(NewStorage).

destroy(Pid) when is_pid(Pid) -> exit(Pid, "got exit signal").

save({_K, _V} = Pair, Pid) when is_pid(Pid) -> send_then_receive({'SAVE', Pair}, Pid).

delete(Key, Pid) when is_pid(Pid) -> send_then_receive({'DELETE', Key}, Pid).

read(Key, Pid) when is_pid(Pid) -> send_then_receive({'READ', Key}, Pid).

match(Element, Pid) when is_pid(Pid) -> send_then_receive({'MATCH', Element}, Pid).

send_then_receive({Operation, Args}, ID) when is_atom(Operation) andalso is_pid(ID) ->
  Request = {self(), Operation, Args},
  ID ! Request,
  receive
    {Pid, Atom, _} = Resp when is_pid(Pid) andalso is_atom(Atom) -> Resp
  end.