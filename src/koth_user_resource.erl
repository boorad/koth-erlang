-module(koth_user_resource).

-export([init/1,
         content_types_provided/2,
         is_authorized/2,
         resource_exists/2,
         to_json/2
        ]).

-include("koth.hrl").
-include_lib("erlauth/include/erlauth.hrl").

init(Config) ->
  %% {{trace, "/tmp"}, Config}. %% debugging code
  {ok, Config}.                 %% regular code

content_types_provided(RD, Ctx) ->
  {[{"application/json", to_json}], RD, Ctx}.

is_authorized(RD, Ctx) ->
  koth_authz:authz(user_or_admin, RD, Ctx).

resource_exists(RD, Ctx) ->
  case lists:keyfind(user, 1, Ctx) of
    {user, _} -> {true, RD, Ctx};
    _ -> {false, RD, Ctx}
  end.

to_json(RD, Ctx) ->
  {user, User=#user{}} = lists:keyfind(user, 1, Ctx),
  Resp = erlauth_util:user_resp(User),
  {Resp, RD, Ctx}.
