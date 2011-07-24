-module(koth_authz).

-export([get_userid/1, authz/3]).

-include("koth.hrl").
-include_lib("erlauth/include/erlauth.hrl").

get_userid(RD) ->
  Info = wrq:path_info(RD),
  ?l2i(koth_util:get_value(user, dict:to_list(Info))).

authz(user_or_admin, RD, Ctx) ->
  Body = mochiweb_util:parse_qs(wrq:req_body(RD)),
  Cookie = wrq:get_cookie_value(?COOKIE, RD),
  case authn:authenticate(Body, Cookie) of
    {ok, AuthType, User=#user{admin=true}} ->
      allowed(AuthType, User, RD, Ctx);
    {ok, AuthType, User=#user{id=Id}} ->
      case get_userid(RD) of
        Id -> % requested userid matches authn'd userid
          allowed(AuthType, User, RD, Ctx);
        _ ->
          forbidden(RD, Ctx)
      end;
    _Error ->
      forbidden(RD, Ctx)
  end.

%%
%% internal
%%

allowed(creds_auth, User, RD, Ctx) ->
  RD1 = erlauth_util:set_cookie(?COOKIE, User, RD),
  allowed(cookie_auth, User, RD1, Ctx);
allowed(cookie_auth, User, RD, Ctx) ->
  Resp = erlauth_util:user_resp(User),
  Ctx1 = add_user_to_context(User, Ctx),
  {true, wrq:append_to_response_body(Resp, RD), Ctx1}.

forbidden(RD, Ctx) ->
  Resp = mochijson2:encode(
           {struct,
            [{error, <<"forbidden">>},
             {reason, <<"Name or password is incorrect.">>}]}),
  {{halt, 403}, wrq:append_to_response_body(Resp, RD), Ctx}.

add_user_to_context(User, Ctx) when is_list(Ctx) ->
  lists:keystore(user, 1, Ctx, {user, User});
add_user_to_context(User, _Ctx) ->
  %% not sure what's in context here if it's not a list,
  %% so starting over with fresh one.
  [{user, User}].
