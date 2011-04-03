-module(popcount).
-compile({parse_transform, ct_expand}).
-compile({popcount_table}).
-export([popcount16/1, popcount32/1]).
-export([kernighan/1]).
-export([hybrid/1]).
% Check out http://www.valuedlessons.com/2009/01/popcount-in-python-with-benchmarks.html for heaps of these...

-define(TABLE(B), ct_expand:term(popcount_table:gen_table(B)) ).
-define(TABLE16, ct_expand:term(?TABLE(16))).

table16() -> ?TABLE16.
popcount16(V) -> erlang:element(V+1, table16()).
% could make a macro to do this for bigger numbers
popcount32(V) -> popcount16( V band 16#ffff ) + popcount16( (V bsr 16) band 16#ffff).

% Works on arbitrary length
kernighan(V) -> kernighan(0, V).
kernighan(C, 0) -> C;
% Clear least significant bit set and count up as we recurse
kernighan(C, V) -> kernighan(C+1, V band (V-1)).

-define(LIMIT32, ct_expand:term( (2 bsl 31) - 1)).
hybrid(V) when V =< ?LIMIT32 -> popcount32(V);
hybrid(V) -> kernighan(V).

