"""
    catalog.jl — L-system species definition type and helpers

Defines `LSystemDef`, a complete L-system species definition that captures
axiom, rules, angle, generations, drawing characters, and metadata.

Reference: ABOP §1.2–§1.10
"""

# ──────────────────────────────────────────────────────────────────
# LSystemDef — complete species definition
# ──────────────────────────────────────────────────────────────────

"""
    LSystemDef

A complete L-system species definition capturing all parameters needed
for derivation and rendering.

# Fields
- `name::String` — human-readable species name
- `category::Symbol` — category tag (e.g. `:fractal_curves`, `:plants_trees`)
- `axiom::LString` — initial string (generation 0)
- `rules::RuleSet` — production rules
- `generations::Int` — number of derivation steps
- `angle::Float64` — turtle turn angle in degrees
- `step::Float64` — turtle step length (default 1.0)
- `draw_chars::Set{Char}` — characters that produce forward movement
- `metadata::Dict{Symbol, Any}` — additional metadata (reference, linecolor, etc.)
"""
struct LSystemDef
    name::String
    category::Symbol
    axiom::LString
    rules::RuleSet
    generations::Int
    angle::Float64
    step::Float64
    draw_chars::Set{Char}
    metadata::Dict{Symbol, Any}
end

# Convenience constructor with keyword args and defaults
function LSystemDef(;
    name::String,
    category::Symbol,
    axiom::LString,
    rules::RuleSet,
    generations::Int,
    angle::Float64,
    step::Float64 = 1.0,
    draw_chars::Set{Char} = Set(['F']),
    metadata::Dict{Symbol, Any} = Dict{Symbol, Any}()
)
    LSystemDef(name, category, axiom, rules, generations, angle, step, draw_chars, metadata)
end

# ──────────────────────────────────────────────────────────────────
# species_slug — URL/filename-safe name conversion
# ──────────────────────────────────────────────────────────────────

"""
    species_slug(name::String) -> String

Convert a species name to a URL/filename-safe slug.

# Examples
```julia
species_slug("Koch Curve")           # "koch-curve"
species_slug("Plant 1 (ABOP 1.24a)") # "plant-1-abop-1-24a"
```
"""
function species_slug(name::String)
    s = replace(lowercase(name), r"[^a-z0-9]+" => "-")
    strip(s, '-')
end

# ──────────────────────────────────────────────────────────────────
# substitute_draw_symbols — pre-processing for turtle interpretation
# ──────────────────────────────────────────────────────────────────

"""
    substitute_draw_symbols(ls::LString, draw_chars::Set{Char}) -> LString

Replace non-F drawing symbols with F for turtle interpretation.
Symbols in `draw_chars` that aren't 'F' are replaced with `LSymbol('F')`.
Returns the original LString unchanged when only F is a draw char.
"""
function substitute_draw_symbols(ls::LString, draw_chars::Set{Char})
    draw_chars == Set(['F']) && return ls
    symbols = AbstractSymbol[]
    sizehint!(symbols, length(ls))
    for s in ls
        c = name(s)
        if c != 'F' && c in draw_chars
            push!(symbols, LSymbol('F'))
        else
            push!(symbols, s)
        end
    end
    LString(symbols)
end
