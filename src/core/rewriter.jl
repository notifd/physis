"""
    rewriter.jl — L-system string rewriting engine

Provides the core rewriting functions:
- `apply_rule`: apply a single rule to a symbol
- `rewrite_step`: one generation of parallel rewriting
- `derive`: n generations of derivation

Reference: ABOP §1.2 (DOL-systems), §1.10 (parametric L-systems)
"""

# ──────────────────────────────────────────────────────────────────
# apply_rule — dispatch on rule type
# ──────────────────────────────────────────────────────────────────

"""
    apply_rule(rule::Rule, sym::LSymbol) -> LString

Apply a D0L rule, returning the RHS as a new LString.
"""
function apply_rule(rule::Rule, sym::LSymbol)
    rule.rhs
end

"""
    apply_rule(rule::ParametricRule{N}, sym::ParametricSymbol{N}) -> LString

Apply a parametric rule, invoking the production function with
the symbol's parameters. The condition must have been checked
before calling this.
"""
function apply_rule(rule::ParametricRule{N}, sym::ParametricSymbol{N}) where {N}
    result = rule.production(sym.params...)
    LString(result)
end

"""
    apply_rule(rule::StochasticRule, sym::LSymbol, rng::AbstractRNG) -> LString

Apply a stochastic rule, selecting among alternatives using
weighted random sampling.
"""
function apply_rule(rule::StochasticRule, sym::LSymbol, rng::AbstractRNG)
    # Weighted selection using cumulative distribution
    total = sum(rule.weights)
    r = rand(rng) * total
    cumulative = 0.0
    for (i, w) in enumerate(rule.weights)
        cumulative += w
        if r <= cumulative
            return rule.alternatives[i]
        end
    end
    # Fallback (shouldn't reach here, but handle floating point edge)
    return rule.alternatives[end]
end

# 3-arg forwarding methods: pass RNG through for uniform dispatch in _apply_first_match
apply_rule(rule::Rule, sym::LSymbol, ::AbstractRNG) = apply_rule(rule, sym)
apply_rule(rule::ParametricRule{N}, sym::ParametricSymbol{N}, ::AbstractRNG) where {N} = apply_rule(rule, sym)

# ──────────────────────────────────────────────────────────────────
# Internal: matching helpers
# ──────────────────────────────────────────────────────────────────

"""
Check if a rule matches a given symbol (type and condition).
"""
function _rule_matches(rule::Rule, sym::AbstractSymbol)
    sym isa LSymbol && matches(rule.lhs, sym)
end

function _rule_matches(rule::ParametricRule{N}, sym::AbstractSymbol) where {N}
    sym isa ParametricSymbol{N} || return false
    matches(rule.lhs, sym) || return false
    rule.condition(sym.params...)
end

function _rule_matches(rule::StochasticRule, sym::AbstractSymbol)
    sym isa LSymbol && matches(rule.lhs, sym)
end

"""
Apply the first matching rule from a list, or return the symbol unchanged.
"""
function _apply_first_match(rules::Vector{AbstractRule}, sym::AbstractSymbol,
                            rng::AbstractRNG)
    for rule in rules
        if _rule_matches(rule, sym)
            return apply_rule(rule, sym, rng)
        end
    end
    # Identity: no matching rule → symbol passes through
    LString([sym])
end

"""
Context-aware version: also checks ContextRule matching against the full LString.
"""
function _apply_first_match(rules::Vector{AbstractRule}, sym::AbstractSymbol,
                            rng::AbstractRNG, ls::LString, index::Int)
    for rule in rules
        if rule isa ContextRule
            if sym isa LSymbol && matches(rule.lhs, sym) &&
               _rule_matches_context(rule, ls, index)
                return rule.rhs
            end
        elseif _rule_matches(rule, sym)
            return apply_rule(rule, sym, rng)
        end
    end
    LString([sym])
end

# ──────────────────────────────────────────────────────────────────
# rewrite_step — one generation
# ──────────────────────────────────────────────────────────────────

"""
    rewrite_step(ls::LString, rs::RuleSet; rng::AbstractRNG=Random.default_rng()) -> LString

Apply one generation of parallel rewriting. Each symbol in `ls`
is independently replaced according to the first matching rule
in `rs`. Symbols with no matching rule pass through unchanged.
"""
function rewrite_step(ls::LString, rs::RuleSet; rng::AbstractRNG=Random.default_rng())
    # Check once if any rules are context-sensitive (avoid overhead when not needed)
    has_context = any(any(r -> r isa ContextRule, rules) for rules in values(rs.rules))

    result = AbstractSymbol[]
    for (i, sym) in enumerate(ls.symbols)
        c = name(sym)
        rules = lookup(rs, c)
        if rules === nothing
            push!(result, sym)
        else
            if has_context
                replacement = _apply_first_match(rules, sym, rng, ls, i)
            else
                replacement = _apply_first_match(rules, sym, rng)
            end
            append!(result, replacement.symbols)
        end
    end
    LString(result)
end

# ──────────────────────────────────────────────────────────────────
# derive — n generations
# ──────────────────────────────────────────────────────────────────

"""
    derive(axiom::LString, rs::RuleSet, n::Integer; rng::AbstractRNG=Random.default_rng()) -> LString

Perform `n` generations of derivation starting from `axiom`.
Returns the axiom unchanged when `n=0`.
Throws `ArgumentError` for negative `n`.

# Examples
```julia
# Algae system (ABOP §1.1)
rs = RuleSet([Rule(LSymbol('A'), LString("AB")),
              Rule(LSymbol('B'), LString("A"))])
derive(LString("A"), rs, 4)  # "ABAABABA"
```
"""
function derive(axiom::LString, rs::RuleSet, n::Integer; rng::AbstractRNG=Random.default_rng())
    n >= 0 || throw(ArgumentError("number of generations must be non-negative, got $n"))
    current = axiom
    for _ in 1:n
        current = rewrite_step(current, rs; rng=rng)
    end
    current
end
