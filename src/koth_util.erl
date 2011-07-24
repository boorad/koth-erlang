-module(koth_util).

-export([get_value/2, get_value/3, get_config/1]).
-export([ensure_started/1]).
-export([db_conn/0, squery/1, equery/2, get_fields/1]).
%% @doc get_value/2 and /3 replaces proplist:get_value/2 and /3
%%      this list function is a bit more efficient
%% @end
get_value(Key, List) ->
  get_value(Key, List, undefined).

get_value(Key, List, Default) ->
  case lists:keysearch(Key, 1, List) of
    {value, {Key,Value}} ->
      Value;
    false ->
      Default
  end.

get_config(Key) ->
  ConfigFile = code:priv_dir(koth) ++ "/koth.conf",
  {ok, Terms} = file:consult(ConfigFile),
  [{koth_config, Configs}|_] = Terms,
  get_value(Key, Configs).

ensure_started(App) ->
  case application:start(App) of
    ok -> ok;
    {error, {already_started, App}} -> ok
  end.

db_conn() ->
  DbConfig = get_config(database),
  Host = get_value(host, DbConfig),
  User = get_value(user, DbConfig),
  Name = get_value(name, DbConfig),
  Port = get_value(port, DbConfig),
  Opts = [{database, Name}, {port, Port}],
  pgsql:connect(Host, User, Opts).

squery(Query) ->
  {ok, C} = koth_util:db_conn(),
  Result = pgsql:squery(C, Query),
  ok = pgsql:close(C),
  Result.

equery(Query, Args) ->
  {ok, C} = koth_util:db_conn(),
  Result = pgsql:equery(C, Query, Args),
  ok = pgsql:close(C),
  Result.

get_fields(Cols) ->
  lists:map(fun({column, Field, _, _, _, _}) -> Field end, Cols).
