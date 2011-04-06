-module(my_math).
-export([floor/1, ceil/1]).
-export([ceillog2/1]).
-export([binomial/2]).
-export([new_bin/2]).
-export([logfactorial/1]).

% Remove branching?
% Taken from http://schemecookbook.org/Erlang/NumberRounding
floor(X) ->
    T = erlang:trunc(X),
    case (X - T) of
        Neg when Neg < 0 -> T - 1;
        Pos when Pos > 0 -> T;
        _ -> T
    end.

% Taken from http://schemecookbook.org/Erlang/NumberRounding
ceil(X) ->
    T = erlang:trunc(X),
    case (X - T) of
        Neg when Neg < 0 -> T;
        Pos when Pos > 0 -> T + 1;
        _ -> T
    end.

%TODO: Optimize this as per hacker's delight
-define(INVLOG2, 1.4426950408889634). 
ceillog2(X) -> ceil(math:log(X) * ?INVLOG2).

% http://www.luschny.de/math/factorial/FastBinomialFunction.html
% Adapted from scheme example on wikipedia
% (http://en.wikipedia.org/wiki/Binomial_coefficient)
% Uses multiplicative formula and integer division, and the symmetry property
binomial(N, K) when K < (N - K) -> binomial_iter(N, K, 0, 1);
binomial(N, K) -> binomial_iter(N, N-K, 0, 1).
binomial_iter(_, K, I, Prev) when I >= K -> Prev;
binomial_iter(N, K, I, Prev) -> binomial_iter(N, K, I+1, ((N - I) * Prev) div (I+1)).
%TODO: test this against a table version

%TODO: add table with ct_expand
-define(PI, 3.141592653589793).
logfactorial(N) -> X = N+1,
    (X - 0.5)*math:log(X) - X + (0.5 * math:log(2.0*?PI)) + 1.0/(12.0 * X).

% Approximation for large values of N
%new_bin(N, K) -> G = logfactorial(N) - logfactorial(K) - logfactorial(N - K),
%    math:exp(G).
