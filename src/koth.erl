-module(koth).

-export([start/0, stop/0, restart/0]).

-define(DEPS, [sasl, crypto, bcrypt, mochiweb, erlauth, webmachine]).

start() ->
  application:set_env(webmachine, webmachine_logger_module,
                      webmachine_logger),
  start_deps(),
  application:start(koth).

stop() ->
  application:stop(koth),
  stop_deps().

restart() ->
  stop(),
  start().

%%
%% internal
%%

start_deps() ->
  lists:foreach(fun(Dep) -> koth_util:ensure_started(Dep) end, ?DEPS).

stop_deps() ->
  lists:foreach(fun(Dep) -> koth_util:ensure_started(Dep) end,
                lists:reverse(?DEPS)).
