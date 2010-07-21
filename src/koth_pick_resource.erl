-module(koth_pick_resource).

-export([init/1, content_types_provided/2, to_html/2, to_text/2,
         is_authorized/2]).

-include_lib("webmachine/include/webmachine.hrl").


init([]) -> {ok, undefined}.

content_types_provided(ReqData, Context) ->
   {[{"text/html", to_html}, {"text/plain", to_text}], ReqData, Context}.

to_html(ReqData, Context) ->
    {Body, _RD, Ctx2} = to_text(ReqData, Context),
    HBody = io_lib:format("<html><body>~s</body></html>~n",
                          [erlang:iolist_to_binary(Body)]),
    {HBody, ReqData, Ctx2}.

to_text(ReqData, Context) ->
    Info = wrq:path_info(ReqData),
    Pick = wrq:path_tokens(ReqData),
    Body = io_lib:format("pick info: ~p pick: ~p~n",
                         [dict:to_list(Info), Pick]),
    {Body, ReqData, Context}.

is_authorized(ReqData, Context) ->
    case length(wrq:path_tokens(ReqData)) of
        0 ->
            {true, ReqData, Context};
        _ ->
            case wrq:get_req_header("authorization", ReqData) of
                "Basic "++Base64 ->
                    Str = base64:mime_decode_to_string(Base64),
                    case string:tokens(Str, ":") of
                        ["brad", "brad"] ->
                            {true, ReqData, Context};
                        _ ->
                            {"Basic realm=koth", ReqData, Context}
                    end;
                _ ->
                    {"Basic realm=koth", ReqData, Context}
            end
    end.
