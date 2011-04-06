-module(rrr).
-export([build/2]).
%-export([rank/1, select/1]).

%rank(Position) ->
%    Position.

%select(Position) ->
%    Position.

% should time this, but it will only affect construction
class(V) -> popcount:hybrid(V).

% { Classes, Offsets }
-define(EMPTY_RRR, <<>>).

%Interleaving may help with caching
make_accumulator(Blocksize) ->
    ClassSize = my_math:ceillog2(Blocksize+1),
    fun(RRR, V) -> {C, O} = {class(V), 0}, % still not getting offset size, but 'GTable' will help
        % Should be log2binomial I think?
        << RRR/bits, C:ClassSize, O:(my_math:binomial(Blocksize, C)) >> end.

% Could count how many bits required in one pass, then allocate that much mem, then do a 2nd pass to fill it in without all the reallocs
build(Blocksize, Bin) ->
bin:fold(make_accumulator(Blocksize), ?EMPTY_RRR, Blocksize, Bin).
    % Construct list first then convert to binary, or construct binary for full size required and modify it
