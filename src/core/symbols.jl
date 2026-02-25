"""
    symbols.jl — L-system alphabet: LSymbol, ParametricSymbol, LString

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
    LSymbol(char)

A plain (non-parametric) L-system symbol identified by a single `Char`.
"""
struct LSymbol <: AbstractSymbol
    char::Char
end

Base.:(==)(a::LSymbol, b::LSymbol) = a.char == b.char
Base.hash(s::LSymbol, h::UInt) = hash(s.char, hash(:LSymbol, h))
Base.show(io::IO, s::LSymbol) = print(io, s.char)

"""
    name(s::LSymbol)

Return the character identifier of a plain symbol.
"""
name(s::LSymbol) = s.char

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
# Different N type parameters → different arity → never equal
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
matches(a::LSymbol, b::LSymbol) = a.char == b.char
matches(a::ParametricSymbol{N}, b::ParametricSymbol{N}) where {N} = a.char == b.char
matches(::AbstractSymbol, ::AbstractSymbol) = false

# ──────────────────────────────────────────────────────────────────
# LString — a derivation string
# ──────────────────────────────────────────────────────────────────

"""
    LString(symbols::Vector{AbstractSymbol})

An ordered sequence of L-system symbols representing one generation
of a derivation. Supports indexing, iteration, and length.

LStrings are construction-only: build a new LString for each derivation
step rather than mutating an existing one. Use `copy` when you need an
independent instance sharing no backing storage.

# Examples
```julia
ls = LString([LSymbol('F'), LSymbol('+'), LSymbol('F')])
length(ls)  # 3
ls[2]       # LSymbol('+')
```
"""
struct LString
    symbols::Vector{AbstractSymbol}
end

# Construct from a plain string (each char → LSymbol)
function LString(s::AbstractString)
    LString([LSymbol(c) for c in s])
end

Base.length(ls::LString) = length(ls.symbols)
Base.getindex(ls::LString, i::Int) = ls.symbols[i]
Base.getindex(ls::LString, r::AbstractRange) = LString(ls.symbols[r])
Base.iterate(ls::LString) = iterate(ls.symbols)
Base.iterate(ls::LString, state) = iterate(ls.symbols, state)
Base.eltype(::Type{LString}) = AbstractSymbol
Base.IteratorSize(::Type{LString}) = Base.HasLength()
Base.IteratorEltype(::Type{LString}) = Base.HasEltype()
Base.firstindex(ls::LString) = 1
Base.lastindex(ls::LString) = length(ls.symbols)
Base.isempty(ls::LString) = isempty(ls.symbols)
Base.copy(ls::LString) = LString(copy(ls.symbols))

function Base.show(io::IO, ls::LString)
    for s in ls.symbols
        show(io, s)
    end
end

function Base.:(==)(a::LString, b::LString)
    length(a) == length(b) || return false
    all(x == y for (x, y) in zip(a.symbols, b.symbols))
end

Base.hash(ls::LString, h::UInt) = hash(ls.symbols, hash(:LString, h))
