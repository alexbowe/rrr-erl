-module(rrr).
-export([build/2]).
%-export([rank/1, select/1]).

%rank(Position) ->
%    Position.

%select(Position) ->
%    Position.

class(V) -> popcount:hybrid(V).

% { Classes, Offsets }
-define(EMPTYRRR, {<<>>, <<>>}).
% Can make a function that builds this function, using ceil(log_2(blocksize)) storage for classes
make_class_accumulator(Blocksize) ->
    ClassSize = my_math:ceillog2(Blocksize),
    fun(Classes, V) -> << Classes/bits, (class(V)):ClassSize >> end.

% Read claude's code - how does he know how many bits in an offset? how is the RRR Table generated and ordered?
make_offset_accumulator(_) ->
    fun(Offsets, _) -> << Offsets/bits, 0:1 >> end.

make_accumulator(Blocksize) ->
    CA = make_class_accumulator(Blocksize),
    OA = make_offset_accumulator(Blocksize),
    fun({Classes, Offsets}, V) -> {CA(Classes, V), OA(Offsets, V)} end.

%Interleaving may help with caching
make_interleaved_accumulator(Blocksize) ->
    ClassSize = my_math:ceillog2(Blocksize+1),
    Offset = 0,%fix these
    OffsetSize = 1, 
    fun(RRR, V) -> << RRR/bits, (class(V)):ClassSize, Offset:OffsetSize >> end.

% Could count how many bits required in one pass, then allocate that much mem, then do a 2nd pass to fill it in without all the reallocs
build(Blocksize, Bin) ->
bin:fold(make_interleaved_accumulator(Blocksize), <<>>, Blocksize, Bin).
    % Construct list first then convert to binary, or construct binary for full size required and modify it
