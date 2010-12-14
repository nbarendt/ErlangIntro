-module(sp).

-export([test/1, f/2]).

test(NumberOfProcesses) ->
    Self = self(),
    Child = spawn(?MODULE, f, [NumberOfProcesses, Self]),
    receive
        Child -> io:format("All done~n")
    end.

f(0, ParentPid) ->
    %io:format("Last Process Pid: ~p~n", [self()]),
    % send a message (just our Pid) to our parent
    %io:format("~p Sending message to ~p~n", [self(), ParentPid]),
    ParentPid ! self();
f(N, ParentPid) ->
    % recursively spawn children
    ChildPid = spawn(?MODULE, f, [N-1, self()]),
    %io:format("~p Waiting for ~p~n", [self(), ChildPid]),
    % wait for a message from our child
    receive
        ChildPid ->
            % send a message to our parent
            %io:format("~p Sending message to ~p~n", [self(), ParentPid]),
            ParentPid ! self()
    end.

