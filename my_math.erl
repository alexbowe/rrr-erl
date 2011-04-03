-module(my_math).
-export([floor/1, ceil/1]).
-export([ceillog2/1]).

% Taken from http://schemecookbook.org/Erlang/NumberRounding
floor(X) ->
    T = erlang:trunc(X),
    case (X - T) of
        Neg when Neg < 0 -> T - 1;
        Pos when Pos > 0 -> T;
        _ -> T
    end.

% Taken from http://schemecookbook.org/Erlang/NumberRounding
ceil(X) ->
    T = erlang:trunc(X),
    case (X - T) of
        Neg when Neg < 0 -> T;
        Pos when Pos > 0 -> T + 1;
        _ -> T
    end.

% Optimize this as per hacker's delight
-define(INVLOG2, 1.4426950408889634). 
ceillog2(X) -> ceil(math:log(X) * ?INVLOG2).
