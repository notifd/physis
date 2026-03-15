"""
    context.jl — Context-sensitive L-system rules (IL-systems / 2L-systems)

Implements bracket-aware left/right context matching for production rules
of the form: `a < b > c → χ`

Context scanning is bracket-transparent: bracketed sub-strings `[...]` are
skipped during neighbor lookup, so `A[+F]B` has A as the left context of B.

Reference: ABOP §1.6–1.7 (Context-sensitive L-systems)
"""

# ──────────────────────────────────────────────────────────────────
# ContextRule
# ──────────────────────────────────────────────────────────────────

"""
    ContextRule <: AbstractRule

A context-sensitive production rule (IL-system / 2L-system).
Matches `lhs` only when the specified left and/or right context symbols
are present in the derivation string, with bracket-transparent scanning.

# Fields
- `left_context::Union{Char, Nothing}` — required left neighbor (or nothing)
- `lhs::LSymbol` — the symbol to replace
- `right_context::Union{Char, Nothing}` — required right neighbor (or nothing)
- `rhs::LString` — replacement string

# Examples
```julia
# A < B → C  (B becomes C only when preceded by A)
ContextRule('A', LSymbol('B'), nothing, LString("C"))

# B > C → D  (B becomes D only when followed by C)
ContextRule(nothing, LSymbol('B'), 'C', LString("D"))

# A < B > C → D  (both contexts required)
ContextRule('A', LSymbol('B'), 'C', LString("D"))
```

Reference: ABOP §1.6–1.7
"""
struct ContextRule <: AbstractRule
    left_context::Union{Char, Nothing}
    lhs::LSymbol
    right_context::Union{Char, Nothing}
    rhs::LString
end

_lhs_char(r::ContextRule) = r.lhs.char

# ──────────────────────────────────────────────────────────────────
# Bracket-transparent context scanning
# ──────────────────────────────────────────────────────────────────

"""
    _find_left_context(ls::LString, index::Int) -> Union{Char, Nothing}

Scan leftward from `index-1` to find the nearest non-bracket symbol,
skipping over bracketed sub-strings `[...]`.

When scanning left and encountering `]`, we skip the entire bracketed
expression by tracking depth until the matching `[` is found.
"""
function _find_left_context(ls::LString, index::Int)
    i = index - 1
    depth = 0
    while i >= 1
        c = name(ls[i])
        if c == ']'
            depth += 1
        elseif c == '['
            if depth > 0
                depth -= 1
            else
                # Hit an unmatched '[' — we're inside a branch; no left context
                return nothing
            end
        elseif depth == 0
            return c
        end
        i -= 1
    end
    nothing
end

"""
    _find_right_context(ls::LString, index::Int) -> Union{Char, Nothing}

Scan rightward from `index+1` to find the nearest non-bracket symbol,
skipping over bracketed sub-strings `[...]`.

When scanning right and encountering `[`, we skip the entire bracketed
expression by tracking depth until the matching `]` is found.
"""
function _find_right_context(ls::LString, index::Int)
    i = index + 1
    n = length(ls)
    depth = 0
    while i <= n
        c = name(ls[i])
        if c == '['
            depth += 1
        elseif c == ']'
            if depth > 0
                depth -= 1
            else
                # Hit an unmatched ']' — we're exiting a branch; no right context
                return nothing
            end
        elseif depth == 0
            return c
        end
        i += 1
    end
    nothing
end

"""
    _rule_matches_context(rule::ContextRule, ls::LString, index::Int) -> Bool

Check whether the context requirements of a `ContextRule` are satisfied
at position `index` in the L-string `ls`.
"""
function _rule_matches_context(rule::ContextRule, ls::LString, index::Int)
    if rule.left_context !== nothing
        left = _find_left_context(ls, index)
        left == rule.left_context || return false
    end
    if rule.right_context !== nothing
        right = _find_right_context(ls, index)
        right == rule.right_context || return false
    end
    true
end
