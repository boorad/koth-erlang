-module(koth_resource).

-export([init/1, content_types_provided/2, to_json/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

content_types_provided(RD, Ctx) ->
  {[{"application/json", to_json}], RD, Ctx}.

to_json(RD, Ctx) ->
  Result = {struct, [{<<"message">>, <<"Welcome to KOTH API">>}]},
  {mochijson2:encode(Result), RD, Ctx}.
