-module(koth_user_resource).

-export([init/1,
         content_types_provided/2,
         is_authorized/2,
         resource_exists/2,
         to_json/2
        ]).

-include("koth.hrl").
-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

content_types_provided(RD, Ctx) ->
  {[{"application/json", to_json}], RD, Ctx}.

is_authorized(RD, Ctx) ->
  koth_authz:authz(user_and_admin, RD, Ctx).

resource_exists(RD, Ctx) ->
  User = koth_authz:get_user(RD),
  % get user info from db
  Query = ""
    "SELECT user_id, username, user_first, user_last, user_timezone "
    "FROM users "
    "WHERE user_id=$1;",
  case koth_util:equery(Query, [User]) of
    {ok, Cols, [Row|_]} ->
      %% make some json to return
      Fields = koth_util:get_fields(Cols),
      Data = lists:zip(Fields, tuple_to_list(Row)),
      Result = {struct, [{<<"user">>, {struct, Data}}]},
      {true, RD, Result};
    _ ->
      %% ensure 404 not found
      {false, RD, Ctx}
  end.

to_json(RD, Result) ->
  {mochijson2:encode(Result), RD, Result}.
