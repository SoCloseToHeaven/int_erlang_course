%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. июнь 2024 21:47
%%%-------------------------------------------------------------------
-author("dmitry").


-record(entry, {key, value}).

-define(SERVER_PORT, 5891).
-define(SERVER_HOST, "localhost").

-define(CLIENT_RESPONSE_TIMEOUT, 12 * 1000).
-define(SERVER_RECEIVE_TIMEOUT, 40 * 1000).

-define(DEFAULT_SERVERS, 4).

-define(INPUT_MESSAGE, "Input request in one line \n").