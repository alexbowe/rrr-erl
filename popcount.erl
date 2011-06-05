-module(popcount).
-export([popcount8/1, popcount16/1, popcount32/1]).
-export([kernighan/1]).

% Check out http://www.valuedlessons.com/2009/01/popcount-in-python-with-benchmarks.html for heaps of these...
-include("popcount_inc.hrl").

-define(POPCOUNT8(V), erlang:element(V+1, ?TABLE8)).
-define(POPCOUNT16(V), erlang:element(V+1, ?TABLE)).

% Macros to avoid function calls
popcount8(V) -> ?POPCOUNT8(V).
popcount16(V) -> ?POPCOUNT8(V band 16#ff) + ?POPCOUNT8( (V bsr 8) band 16#ff).
popcount32(V) -> ?POPCOUNT8(V band 16#ff) + ?POPCOUNT8( (V bsr 8) band 16#ff)
    + ?POPCOUNT8((V bsr 16) band 16) + ?POPCOUNT8( (V bsr 24) band 16#ff).

% Works on arbitrary length
kernighan(V) -> kernighan(0, V).
kernighan(C, 0) -> C;
% Clear least significant bit set and count up as we recurse
kernighan(C, V) -> kernighan(C+1, V band (V-1)).
