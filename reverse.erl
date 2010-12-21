-module(reverse).

-export([start/0, loop/0]).

start() ->
    register(server_reverse, spawn(?MODULE, loop, [])).

loop() ->
    receive
        {From, Msg} ->
           From ! {ok, lists:reverse(Msg)}
    end.

