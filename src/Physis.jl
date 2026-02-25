module Physis

# ── Core L-system types ──────────────────────────────────────────
include("core/symbols.jl")

# Re-export public API
export AbstractSymbol, LSymbol, ParametricSymbol, LString
export name, arity, params, matches

end # module Physis
