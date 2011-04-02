-module(popcount).
-compile({parse_transform,ct_expand}).
-export([popcount/1]).
-export([kernighan/1]).
-export([table16/0]).
% Check out http://www.valuedlessons.com/2009/01/popcount-in-python-with-benchmarks.html for heaps of these...

% Table expanded at compile time with ct_expand
-define(TABLE(B), ct_expand:term(
        fun() ->
            case B of 0 -> {}; _ ->
                GenTable = fun(Value, Stop, Table, F) ->
                    case Value of
                        Stop -> Table;
                        _ -> New = (Value band 1) + erlang:element( (Value bsr 1) + 1, Table ),
                        NewTable = erlang:append_element(Table, New),
                        F(Value + 1, Stop, NewTable, F)
                    end
                end,
                GenTable(1, 2 bsl (B-1), {0}, GenTable)
            end
        end()
    ) ).
table16() -> ?TABLE(16).

popcount(X) -> erlang:element(X+1, table16()).

-define(LOWER_BYTE(X), X band 16#ff).
-define(BYTE(X, I), ?LOWER_BYTE(X bsr I*8)).

% Works on arbitrary length
kernighan(V) -> kernighan(0, V).
kernighan(C, 0) -> C;
% Clear least significant bit set and count up as we recurse
kernighan(C, V) -> kernighan(C+1, V band (V-1)).
