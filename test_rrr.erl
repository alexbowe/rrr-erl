-module(test_rrr).

-include_lib("eunit/include/eunit.hrl").

-define(ONE_REPEATED(N), erlang:trunc(math:pow(2, N)) - 1).

-define(LENGTH, 30).
-define(POSITIONS(L), lists:seq(1, L)).
-define(BITSTRINGS, [
    { <<0:?LENGTH>>, [0 || _ <- ?POSITIONS(?LENGTH)] },
    { <<(?ONE_REPEATED(?LENGTH)):?LENGTH>>, ?POSITIONS(?LENGTH)},
    { << 2#100100111110101101110000000010 >>, [1,1,1,2,2,2,3,4,5,6,7,7,8,8,9,10,10,11,12,13,13,13,13,13,13,13,13,13,14,14] }
]).

rank_test_() ->
    [ make_test_fun(X) || X <- ?BITSTRINGS ].

make_test_fun({Bin, Expected}) ->
    fun() ->
        RRR = rrr:build(Bin),
        Result = gather_ranks(RRR, length(Expected)),
        ?assertMatch(Result, Expected)
    end.

% Done without using the macro for length so I can make
% different lengthed queries
gather_ranks(RRR, Length) ->
    Positions = ?POSITIONS(Length),
    lists:foreach(fun(Pos) -> rrr:rank(RRR, Pos) end, Positions).

% build RRR sequence for the bitstring (later, using various rrr tables, factor creation out) [Do this for multiple blocksizes? I guess it isnt a parameter in this version...]

% unit ideas:
% bin.erl functions
% from bitstring to class/offset values, back to bitstring (RRRTable really...)
% test popcount
% test table lookup using class and offset (YES! Make a RRRTable Module that can be plugged in and run as a server, and tests
% all C/O pairs (or a fair few of them) - makes sure all Classes have the right popcount, etc...
% ALSO, with this separation, the rrr sequence would just need to be told how many bits per element (1 for binary, 2 for 4-ary, etc)
% the accumulator should deal with, then a RRRTable is plugged in that supports this, and away we go
% only thing that may need to happen differently is if the RRR table needs to be passed the RRR sequence to be created for statistic reasons,
% but the traversal code could be factored out and used in both... (in RRR bin? I guess i have done that with fold, but if fold were edited to
% traverse N bits at a time, that would be better).

%Then RRRTable uses a statistic accumulator to gather frequencies, etc...
% RRR Sequences should be constructed using a RRRTable as a reference.
