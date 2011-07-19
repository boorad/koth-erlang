-module(koth_authz).

-export([get_user/1, authz/3]).

-include("koth.hrl").
-include_lib("erlauth/include/erlauth.hrl").

get_user(RD) ->
  Info = wrq:path_info(RD),
  ?l2i(koth_util:get_value(user, dict:to_list(Info))).

authz(_Type, RD, Ctx) ->
  User = get_user(RD),
  Body = mochiweb_util:parse_qs(wrq:req_body(RD)),
  Cookie = wrq:get_cookie_value(?COOKIE, RD),
  case authn:authenticate(Body, Cookie) of
    {ok, #user{user=User}} ->
      RD1 = erlauth_util:set_cookie(?COOKIE, User, RD),
      Resp = mochijson2:encode({struct,
                                [{user, list_to_binary(User)}]}),
      {true, wrq:append_to_response_body(Resp, RD1), Ctx};
    _Error ->
      Resp = mochijson2:encode(
               {struct,
                [{error, <<"forbidden">>},
                 {reason, <<"Name or password is incorrect.">>}]}),
      {{halt, 403}, wrq:append_to_response_body(Resp, RD), Ctx}
  end.
