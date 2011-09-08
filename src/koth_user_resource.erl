-module(koth_user_resource).

-export([init/1,
         allowed_methods/2,
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

allowed_methods(RD, Ctx) ->
  {['GET','PUT'], RD, Ctx}.

content_types_provided(RD, Ctx) ->
  {[{"application/koth-v1+json", to_json}], RD, Ctx}.

is_authorized(RD, Ctx) ->
  Result = case erlauth:get_user(RD, Ctx) of
             User = #user{} -> %% authenticated user
               TargetId = erlauth_util:to_int(wrq:path_info(user, RD)),
               is_target_user_or_admin(TargetId, User);
             _ -> %% non-authenticated user
               false
           end,
  {auth_head(Result), RD, Ctx}.

resource_exists(RD, Ctx) ->
  TargetId = erlauth_util:to_int(wrq:path_info(user, RD)),
  case erlauth_user:get_user(id, TargetId) of
    {ok, User = #user{}} ->
      Ctx1 = erlauth_util:add_to_context({target, User}, Ctx),
      {true, RD, Ctx1};
    _ ->
      {false, RD, Ctx}
  end.

to_json(RD, Ctx) ->
  User = erlauth_util:get_value(target, Ctx),
  Resp = erlauth_util:user_resp(User),
  {Resp, RD, Ctx}.

%%
%% internal
%%

is_target_user_or_admin(TargetId, #user{id=TargetId}) ->
  true;
is_target_user_or_admin(_,User) ->
  erlauth:authz(User, [admin]).

auth_head(true) -> true;
auth_head(_) -> ?AUTH_HEAD.
