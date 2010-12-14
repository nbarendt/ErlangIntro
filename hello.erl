-module(hello).
-export([hello/1]). 

hello("root") ->
    io:format("Hello, Sir!~n");
hello({username, Name})->
    io:format("Hello, ~s~n", [Name]);
hello(Name) ->
    io:format("Hello, ~s~n", [Name]).

