%%%-------------------------------------------------------------------
%%% @author dmitry
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. июнь 2024 15:40
%%%-------------------------------------------------------------------
-author("dmitry").


-define(PSYCHO_INTERVAL, 3 * 1000).
-define(CITIZEN_INTERVAL, 8 * 1000).


-record(down_msg, {
  state = 'DOWN',
  ref,
  process = process,
  pid,
  reason
}).
