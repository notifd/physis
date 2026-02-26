"""
    rules.jl — Production rule types for L-systems

Defines the rule types that drive L-system derivation:
- `Rule`: deterministic, context-free (D0L)
- `ParametricRule{N}`: parametric with optional guard condition
- `StochasticRule`: weighted random choice among alternatives
- `RuleSet`: indexed collection for O(1) lookup by LHS character

Reference: ABOP §1.2 (DOL-systems), §1.10 (parametric L-systems)
"""

# ──────────────────────────────────────────────────────────────────
# Abstract base
# ──────────────────────────────────────────────────────────────────

"""
    AbstractRule

Supertype for all L-system production rules.
"""
abstract type AbstractRule end

# ──────────────────────────────────────────────────────────────────
# D0L Rule  (deterministic, context-free)
# ──────────────────────────────────────────────────────────────────

"""
    Rule(lhs::LSymbol, rhs::LString)

A deterministic, context-free production rule (D0L).
Replaces every occurrence of `lhs` with `rhs`.

# Examples
```julia
Rule(LSymbol('F'), LString("F+F"))   # F → F+F
Rule(LSymbol('A'), LString("AB"))    # A → AB
```

Reference: ABOP §1.2
"""
struct Rule <: AbstractRule
    lhs::LSymbol
    rhs::LString
end

# ──────────────────────────────────────────────────────────────────
# Parametric Rule
# ──────────────────────────────────────────────────────────────────

"""
    ParametricRule{N}(lhs, condition, production)
    ParametricRule(lhs, production)

A parametric production rule with an optional guard condition.
The condition function receives the symbol's parameters as a tuple
and returns a Bool. The production function receives the same
parameters and returns a `Vector{AbstractSymbol}`.

When constructed without a condition, the rule always matches.

# Examples
```julia
# A(x) : x > 0 → F A(x-1)
ParametricRule(
    ParametricSymbol('A', (0.0,)),
    (x,) -> x > 0,
    (x,) -> AbstractSymbol[LSymbol('F'), ParametricSymbol('A', (x-1,))]
)
```

Reference: ABOP §1.10
"""
struct ParametricRule{N} <: AbstractRule
    lhs::ParametricSymbol{N}
    condition::Function
    production::Function
end

# Convenience: no condition → always true
function ParametricRule(lhs::ParametricSymbol{N}, production::Function) where {N}
    ParametricRule{N}(lhs, Returns(true), production)
end

# ──────────────────────────────────────────────────────────────────
# Stochastic Rule
# ──────────────────────────────────────────────────────────────────

"""
    StochasticRule(lhs, weights, alternatives)

A stochastic production rule that randomly selects among weighted
alternatives. Requires an `AbstractRNG` for reproducible derivation.

Constructor validates:
- At least 2 alternatives
- All weights positive
- Weights and alternatives have matching lengths

# Examples
```julia
StochasticRule(
    LSymbol('F'),
    [0.5, 0.5],
    [LString("F+F"), LString("F-F")]
)
```
"""
struct StochasticRule <: AbstractRule
    lhs::LSymbol
    weights::Vector{Float64}
    alternatives::Vector{LString}

    function StochasticRule(lhs::LSymbol, weights::Vector{Float64}, alternatives::Vector{LString})
        length(alternatives) >= 2 || throw(ArgumentError(
            "StochasticRule requires at least 2 alternatives, got $(length(alternatives))"))
        length(weights) == length(alternatives) || throw(ArgumentError(
            "weights length ($(length(weights))) must match alternatives length ($(length(alternatives)))"))
        all(w -> w > 0, weights) || throw(ArgumentError(
            "all weights must be positive"))
        new(lhs, weights, alternatives)
    end
end

# ──────────────────────────────────────────────────────────────────
# Internal helpers: extract LHS char from any rule type
# ──────────────────────────────────────────────────────────────────

_lhs_char(r::Rule) = r.lhs.char
_lhs_char(r::ParametricRule) = r.lhs.char
_lhs_char(r::StochasticRule) = r.lhs.char

# ──────────────────────────────────────────────────────────────────
# RuleSet — indexed rule collection
# ──────────────────────────────────────────────────────────────────

"""
    RuleSet(rules::Vector{<:AbstractRule})

An indexed collection of rules keyed by LHS character for O(1) lookup.
First matching rule wins (insertion order preserved).

Validates that `StochasticRule` is not mixed with other rule types
for the same LHS character.
"""
struct RuleSet
    rules::Dict{Char, Vector{AbstractRule}}

    function RuleSet(rules::Vector{<:AbstractRule})
        grouped = Dict{Char, Vector{AbstractRule}}()
        for r in rules
            c = _lhs_char(r)
            push!(get!(Vector{AbstractRule}, grouped, c), r)
        end

        # Validate: no mixing stochastic with other types for same char
        for (c, rs) in grouped
            has_stochastic = any(r -> r isa StochasticRule, rs)
            has_other = any(r -> !(r isa StochasticRule), rs)
            if has_stochastic && has_other
                throw(ArgumentError(
                    "cannot mix StochasticRule with other rule types for character '$c'"))
            end
        end

        new(grouped)
    end
end

"""
    lookup(rs::RuleSet, c::Char) -> Union{Vector{AbstractRule}, Nothing}

Return the rules for character `c`, or `nothing` if no rules match.
Internal function — not exported.
"""
function lookup(rs::RuleSet, c::Char)
    get(rs.rules, c, nothing)
end
