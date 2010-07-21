%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the koth application.

-module(koth_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for koth.
start(_Type, _StartArgs) ->
    koth_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for koth.
stop(_State) ->
    ok.
