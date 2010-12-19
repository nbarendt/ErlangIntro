-module(httpd).

-export([start/0, serve/0, handle_request/0]).

-define(PORT, 8000).

start() ->
    spawn(?MODULE, serve, []).

serve() ->
    Options = [list,
                {active, false},
                {reuseaddr, true},
                {backlog, 2000}],
    {ok, LSocket} = gen_tcp:listen(?PORT, Options),
    accept_loop(LSocket).

accept_loop(LSocket) ->
    {ok, Socket} = gen_tcp:accept(LSocket),
    HandlerPid = spawn(?MODULE, handle_request, []),
    % change ownership (message delivery) to the new HandlerPid
    ok = gen_tcp:controlling_process(Socket, HandlerPid),
    % send the HandlerPid a message with the socket
    HandlerPid ! Socket,
    % go back to listening
    accept_loop(LSocket).

handle_request() ->
    receive
        Socket -> ok
    end,
    ok = inet:setopts(Socket, [{active, true},
                    {packet, http} ]),
    Request = get_request(),
    %io:format("Received Request: ~p~n", [Request]),
    Headers = get_headers([]),
    %io:format("Received Headers: ~p~n", [Headers]),
    Response = ["HTTP/1.1 200 OK\r\n",
                "Connection: close\r\n",
                "Content-Type: text/plain; charset=UTF-8\r\n",
                "Cache-Control: no-cache\r\n",
                "\r\n",
                "HelloWorld!\r\n"],
    gen_tcp:send(Socket, Response),
    gen_tcp:close(Socket).

get_request() ->
    receive
        {http, _, {http_request, Method, Uri, Version}} ->
            {Method, Uri, Version};
        {tcp_closed, Socket} ->
            gen_tcp:close(Socket),
            erlang:error(tcp_closed);
        Any -> io:format("RCV1: ~p~n", [Any])
    end.

get_headers(Headers) ->
    receive
        {http, _, {http_header, _, Field, _, Value}} ->
            get_headers([{Field, Value} | Headers]);
        {http, _, http_eoh} ->
            Headers;
        Any -> io:format("RCV2: ~p~n", [Any])
    end.

