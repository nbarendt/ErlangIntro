-module(echo).

-export([start/0, listen/0, accept/1, handle/1]).

-define(PORT, 3000).

start() ->
    spawn(?MODULE, listen, []).

listen() ->
    Options = [list, % return data from socket as Erlang List
                {active, true}, % send data to process as Erlang messages
                {packet, line}, % messages are delimited by new-lines
                {reuseaddr, true} % allow the port to be reused
            ],
    {ok, ListenSocket} = gen_tcp:listen(?PORT, Options),
    accept(ListenSocket).

accept(LSocket) ->
    case gen_tcp:accept(LSocket) of
        {ok, Socket} ->
            io:format("Received incoming connection!~n"),
            Handler = spawn(?MODULE,  handle, [Socket]),
            gen_tcp:controlling_process(Socket, Handler),
            accept(LSocket);
        {error, closed } ->
            io:format("Listening Socket Closed!~n")
    end.


handle(Socket) ->
    receive
        {tcp, Socket, Data} ->
            io:format("Server received: ~p~n", [Data]),
            gen_tcp:send(Socket, Data),
            handle(Socket);
        {tcp_closed, Socket} ->
            io:format("Socket closed!~n")
    end.

