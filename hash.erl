-module(hash).

-export([start/0, stop/0, loop/0, md5/1, sha/1,
        test/0]).

md5(InputData) ->
    ?MODULE ! {self() , {md5, InputData}},
    receive
        {md5, OutputData} -> OutputData
    end.

sha(InputData) ->
    ?MODULE ! {self() , {sha, InputData}},
    receive
        {sha, OutputData} -> OutputData
    end.

test() ->
    TestString = "Hello World!",
    <<237,7,98,135,83,46,134,54,94,
        132,30,146,191,197,13,140>> = md5(TestString),
    <<46,247,189,230,8,206,84,4,233,125,95,4,47,149,248,159,
        28,35,40,113>> = sha(TestString),
    ok.

start() ->
    crypto:start(), % ignore this line for now
    register(?MODULE, spawn(?MODULE, loop, [])).
    
stop() ->
    ?MODULE ! shutdown.
            
loop() ->   
    receive 
        {From, {md5, Message}} ->
            From ! {md5, crypto:md5(Message)},
            loop(); % recurse
        {From, {sha, Message}} ->
            From ! {sha, crypto:sha(Message)},
            loop(); % recurse
        shutdown ->
            io:format("Hash server going down~n")
    after 5000 ->
        io:format("Hash Server Just Looping, nothing to see here~n"),
        loop() % recurse
    end.

