-module(popcount_table).
-export([gen_table/1]).

gen_table(Bits) -> gen_table(1, 1 bsl Bits, {0}).
gen_table(Stop, Stop, Table) -> Table;
gen_table(Value, Stop, Table) ->
    New = (Value band 1) + erlang:element((Value bsr 1) + 1, Table),
    NewTable = erlang:append_element(Table, New),
    gen_table(Value + 1, Stop, NewTable).
