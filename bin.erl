-module(bin).
-export([foreach/3]).
-export([fold/4]).

% Pads the last block with 0-bits if it isn't a multiple of blocksize
break(Blocksize, Bin) ->
    Size = bit_size(Bin),
    if
        Size >= Blocksize -> <<Head:Blocksize, Rest/bits>> = Bin;
        true -> <<V:Size>> = Bin,
                {Head, Rest} = { V bsl (Blocksize - Size), <<>> }
    end,
    {Head, Rest}.

foreach(_, _, <<>>) -> ok;
foreach(F, Blocksize, Bin) ->
    {Head, Rest} = break(Blocksize, Bin),
    F(Head),
    foreach(F, Blocksize, Rest).

fold(_, Result, _, <<>>) -> Result;
fold(F, Initial, Blocksize, Bin) ->
    {Head, Rest} = break(Blocksize, Bin),
    Temp = F(Initial, Head),
    fold(F, Temp, Blocksize, Rest).

% count(<<Value:16>>) -> 
