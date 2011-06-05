-module(rrr).
-include("common.hrl").
-export([build/1, build/3]).
-export([rank/2]).

rank(RRR, Position) -> 0.

%select(Position) ->
%    Position.

-define(SUPERBLOCKSIZE, 32).
-define(class(V), popcount:popcount16(V)).
-define(block(V), {?class(V), rrr_table:get_offset(V)}).
-define(compress_block(C, O), <<C:(?CLASSBITS), O:(?CEILLOG2BINOMIAL(C)) >>).
-define(append_bits(X, Y), <<X/bits, Y/bits>>).

get_accumulator(SuperblockSize) ->
    fun({{rrr, Superblocks, Blocks}, {Count, Offset, I}}, Next) ->
        {C, O} = ?block(Next),
        B = ?compress_block(C, O),

        % TODO: Convert to tuple instead of list (or bin?)
        % Update Superblocks at boundary, but not first
        case (I rem SuperblockSize == 0) and (I /= 0) of
            % on a superblock boundary
            true -> Append = [{Count, Offset}];
            % not on a superblock boundary:
            false -> Append = []
        end,

        {{rrr, Superblocks ++ Append, ?APPEND_BITS(Blocks, B)},
               {Count + C, Offset + bit_size(B), I + 1}}
    end.

-define(EMPTY_RRR, {rrr, [], <<>>}).
-define(INIT_RRR, {?EMPTY_RRR, {0, 0, 0}}).
build(Bin) -> build(Bin, ?BLOCKSIZE, ?SUPERBLOCKSIZE).
build(Bin, BlockSize, SuperblockSize) when BlockSize =< ?BLOCKSIZE ->
    Accumulator = get_accumulator(SuperblockSize),
    {RRR, _} = bin:fold(Accumulator, ?INIT_RRR, BlockSize, Bin),
    RRR.
