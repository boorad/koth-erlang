%%-*- mode: erlang -*-
{application, koth,
 [
  {description, "koth"},
  {vsn, "1"},
  {modules, [
             koth,
             koth_app,
             koth_sup,
             koth_resource
            ]},
  {registered, []},
  {applications, [
                  kernel,
                  stdlib,
                  crypto,
                  mochiweb,
                  webmachine
                 ]},
  {mod, { koth_app, []}},
  {env, []}
 ]}.
