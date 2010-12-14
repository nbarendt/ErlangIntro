-module(reverse).

-export([start/0, loop/0]).

start() ->
    register(?MODULE, spawn(?MODULE, loop, [])).

loop() ->
    receive
        {From, Msg} ->
           From ! {ok, lists:reverse(Msg)}
    end.

