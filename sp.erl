-module(sp).

-export([test/1, f/2]).

test(NumberOfProcesses) ->
    Self = self(),
    Child = spawn(?MODULE, f, [NumberOfProcesses, Self]),
    receive
        Child -> io:format("All done~n")
    end.

f(0, ParentPid) ->
    ParentPid ! self();
f(N, ParentPid) ->
    ChildPid = spawn(?MODULE, f, [N-1, self()]),
    receive
        ChildPid ->
            ParentPid ! self()
    end.

