-module(rrr_table).
-include("rrr_table_inc.hrl").
-export([get_offset/1, lookup/2]).

get_offset(V) -> erlang:element(V+1, ?REVERSE_OFFSETS).

lookup(C, O) -> CBase = erlang:element(C+1, ?CLASS_BASES),
    erlang:element(1+CBase+O, ?BLOCKS).
