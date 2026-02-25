"""
    symbols.jl — L-system alphabet: Symbol, ParametricSymbol, LString

Symbol types represent the alphabet of an L-system. Plain symbols carry only
a character; parametric symbols additionally carry a tuple of Float64 parameters.
An LString is an ordered sequence of AbstractSymbol, representing the current
state of an L-system derivation.

Reference: ABOP §1.2 (DOL-systems), §1.10 (parametric L-systems)
"""

# ──────────────────────────────────────────────────────────────────
# Abstract base
# ──────────────────────────────────────────────────────────────────

"""
    AbstractSymbol

Supertype for all L-system symbols.
"""
abstract type AbstractSymbol end

# ──────────────────────────────────────────────────────────────────
# Plain symbol  (e.g. F, +, -, [, ])
# ──────────────────────────────────────────────────────────────────

"""
    Symbol(char)

A plain (non-parametric) L-system symbol identified by a single `Char`.
"""
struct Symbol <: AbstractSymbol
    char::Char
end

Base.:(==)(a::Symbol, b::Symbol) = a.char == b.char
Base.hash(s::Symbol, h::UInt) = hash(s.char, hash(:Symbol, h))
Base.show(io::IO, s::Symbol) = print(io, s.char)

"""
    name(s::Symbol)

Return the character identifier of a plain symbol.
"""
name(s::Symbol) = s.char

# ──────────────────────────────────────────────────────────────────
# Parametric symbol  (e.g. F(1.0), A(10, 3.5))
# ──────────────────────────────────────────────────────────────────

"""
    ParametricSymbol(char, params::NTuple{N,Float64})

A parametric L-system symbol carrying `N` Float64 parameters.
Two parametric symbols match when they share the same character
**and** arity; parameter values are not considered for matching.

# Examples
```julia
ParametricSymbol('A', (10.0,))
ParametricSymbol('B', (1.0, 2.0, 3.0))
```
"""
struct ParametricSymbol{N} <: AbstractSymbol
    char::Char
    params::NTuple{N, Float64}
end

# Convenience: construct from varargs
function ParametricSymbol(char::Char, params::Float64...)
    ParametricSymbol(char, params)
end

# Convenience: construct from any Real arguments
function ParametricSymbol(char::Char, params::Real...)
    ParametricSymbol(char, Float64.(params))
end

Base.:(==)(a::ParametricSymbol{N}, b::ParametricSymbol{N}) where {N} =
    a.char == b.char && a.params == b.params
Base.:(==)(::ParametricSymbol, ::ParametricSymbol) = false

Base.hash(s::ParametricSymbol, h::UInt) =
    hash(s.params, hash(s.char, hash(:ParametricSymbol, h)))

function Base.show(io::IO, s::ParametricSymbol)
    print(io, s.char, '(')
    join(io, s.params, ", ")
    print(io, ')')
end

"""
    name(s::ParametricSymbol)

Return the character identifier (ignoring parameters).
"""
name(s::ParametricSymbol) = s.char

"""
    arity(s::ParametricSymbol{N}) -> Int

Return the number of parameters.
"""
arity(::ParametricSymbol{N}) where {N} = N

"""
    params(s::ParametricSymbol)

Return the parameter tuple.
"""
params(s::ParametricSymbol) = s.params

"""
    matches(a::AbstractSymbol, b::AbstractSymbol)

Check whether two symbols match for rule application.
Plain symbols match by character. Parametric symbols match by character and arity
(parameter values are ignored for matching — they are checked by conditions).
"""
matches(a::Symbol, b::Symbol) = a.char == b.char
matches(a::ParametricSymbol{N}, b::ParametricSymbol{N}) where {N} = a.char == b.char
matches(::AbstractSymbol, ::AbstractSymbol) = false

# ──────────────────────────────────────────────────────────────────
# LString — a derivation string
# ──────────────────────────────────────────────────────────────────

"""
    LString(symbols::Vector{AbstractSymbol})

An ordered sequence of L-system symbols representing one generation
of a derivation. Supports indexing, iteration, and length.

# Examples
```julia
ls = LString([Symbol('F'), Symbol('+'), Symbol('F')])
length(ls)  # 3
ls[2]       # Symbol('+')
```
"""
struct LString
    symbols::Vector{AbstractSymbol}
end

# Construct from a plain string (each char → Symbol)
function LString(s::AbstractString)
    LString([Symbol(c) for c in s])
end

Base.length(ls::LString) = length(ls.symbols)
Base.getindex(ls::LString, i::Int) = ls.symbols[i]
Base.getindex(ls::LString, r::AbstractRange) = LString(ls.symbols[r])
Base.iterate(ls::LString) = iterate(ls.symbols)
Base.iterate(ls::LString, state) = iterate(ls.symbols, state)
Base.eltype(::Type{LString}) = AbstractSymbol
Base.firstindex(ls::LString) = 1
Base.lastindex(ls::LString) = length(ls.symbols)
Base.isempty(ls::LString) = isempty(ls.symbols)
Base.push!(ls::LString, s::AbstractSymbol) = (push!(ls.symbols, s); ls)
Base.append!(ls::LString, other::LString) = (append!(ls.symbols, other.symbols); ls)

function Base.show(io::IO, ls::LString)
    for s in ls.symbols
        show(io, s)
    end
end

function Base.:(==)(a::LString, b::LString)
    length(a) == length(b) || return false
    all(a.symbols .== b.symbols)
end

Base.hash(ls::LString, h::UInt) = hash(ls.symbols, hash(:LString, h))
