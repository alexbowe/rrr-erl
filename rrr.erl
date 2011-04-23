-module(rrr).
-include("common.hrl").
-export([build/1]).
-export([rank/2]).

rank(RRR, Position) ->
    Position.

%select(Position) ->
%    Position.

-define(class(V), popcount:popcount16_8(V)).

% TODO: USE STREAMS IN ORDER TO PROCESS SUPERBLOCKS IN A SEPARATE FUNCTION
% one to make the blocks, one to build the superblocks from the blocks, one to combine the two into a binary?

% TODO: superblocks (need to read up on them)
get_accumulator(SuperblockSize) ->
    fun({ {rrr, Superblocks, Blocks}, I} , V) ->
        {C, O} = {?class(V), rrr_table:get_offset(V)},
        % Find current superblock from I (use macro), pass temporary counting values along,
        % only add to binary when a superblock boundary is reached
        { { rrr,
            <<Superblocks/bits>>,
            << Blocks/bits, C:(?CLASSBITS), O:(?CEILLOG2BINOMIAL(C)) >> },
            I+1 }
    end.

% FORMAT: { {rrr, SuperBlocks, Blocks}, CurrentBlock }
% Add temporary block count variable?
-define(EMPTY_RRR, {{rrr, <<>>, <<>>}, 0}).

-define(SUPERBLOCKSIZE, 32).
build(Bin) -> build(Bin, ?BLOCKSIZE, ?SUPERBLOCKSIZE).
build(Bin, BlockSize, SuperblockSize) ->
    Accumulator = get_accumulator(SuperblockSize),
    {RRR, _ } = bin:fold(Accumulator, ?EMPTY_RRR, BlockSize, Bin),
    RRR.
