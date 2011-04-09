-module(popcount).
-compile({parse_transform, ct_expand}).
-compile({popcount_table}).
-export([popcount8/1, popcount16/1, popcount16_8/1, popcount32_8/1, popcount32_16/1]).
-export([kernighan/1]).

% Check out http://www.valuedlessons.com/2009/01/popcount-in-python-with-benchmarks.html for heaps of these...

-define(TABLE(B), ct_expand:term(popcount_table:gen_table(B)) ).
-define(TABLE8, ct_expand:term(?TABLE(8))).
-define(TABLE16, ct_expand:term(?TABLE(16))).
-define(POPCOUNT8(V), erlang:element(V+1, ?TABLE8)).
-define(POPCOUNT16(V), erlang:element(V+1, ?TABLE16)).

% Macros to avoid function calls
popcount8(V) -> ?POPCOUNT8(V).
popcount16(V) -> ?POPCOUNT16(V).
popcount16_8(V) -> ?POPCOUNT8(V band 16#ff) + ?POPCOUNT8( (V bsr 8) band 16#ff).
popcount32_8(V) -> ?POPCOUNT8(V band 16#ff) + ?POPCOUNT8( (V bsr 8) band 16#ff)
    + ?POPCOUNT8((V bsr 16) band 16) + ?POPCOUNT8( (V bsr 24) band 16#ff).
% could make a macro to do this for bigger numbers
popcount32_16(V) -> ?POPCOUNT16( V band 16#ffff ) + ?POPCOUNT16( (V bsr 16) band 16#ffff).

% Works on arbitrary length
kernighan(V) -> kernighan(0, V).
kernighan(C, 0) -> C;
% Clear least significant bit set and count up as we recurse
kernighan(C, V) -> kernighan(C+1, V band (V-1)).
