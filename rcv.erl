-module(rcv).

-export([go/0]).

go() ->
    receive
        {msg, Subject, Body} ->
            io:format("Subject: ~p~nBody: ~p~n", [Subject, Body]);
        {msg, Subject} ->
            io:format("Subject: ~p~n", [Subject]);
        Other ->
            io:format("Received Unexpected Message: ~p~n", [Other])
    end.

