module Physis

using Random

# ── Core L-system types ──────────────────────────────────────────
include("core/symbols.jl")
include("core/rules.jl")
include("core/rewriter.jl")

# ── Turtle interpreters ─────────────────────────────────────────
include("turtle/turtle2d.jl")

# ── Rendering API ─────────────────────────────────────────────
include("render/render_api.jl")

# Re-export public API
export AbstractSymbol, LSymbol, ParametricSymbol, LString
export name, arity, params, matches
export AbstractRule, Rule, ParametricRule, StochasticRule, RuleSet
export rewrite_step, derive, apply_rule
export LineSegment2D, interpret2d
export BoundingBox2D, compute_bbox, render2d, save_render, render_lsystem

end # module Physis
