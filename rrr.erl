-module(rrr).
-include("common.hrl").
-export([build/1]).
%-export([rank/1, select/1]).

%rank(Position) ->
%    Position.

%select(Position) ->
%    Position.

class(V) -> popcount:popcount16_8(V).

%Interleaving may help with caching
accumulator(RRR, V) -> {C, O} = {class(V), rrr_table:get_offset(V)},
    << RRR/bits, C:(?CLASSBITS), O:(?CEILLOG2BINOMIAL(C)) >>.

-define(EMPTY_RRR, <<>>).
% Could count how many bits required in one pass, then
% allocate that much mem, then do a 2nd pass to fill it in without all the reallocs
build(Bin) ->
    bin:fold(fun(RRR, V) -> accumulator(RRR, V) end, ?EMPTY_RRR, ?BLOCKSIZE, Bin).
