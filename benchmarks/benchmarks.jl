using BenchmarkTools
using Physis
using StableRNGs

const SUITE = BenchmarkGroup()

# ── Derivation benchmarks ────────────────────────────────────────

SUITE["derive"] = BenchmarkGroup()

let rs = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))])
    axiom = LString("F")
    SUITE["derive"]["plant_5gen"] = @benchmarkable derive($axiom, $rs, 5)
    SUITE["derive"]["plant_3gen"] = @benchmarkable derive($axiom, $rs, 3)
end

# Context-sensitive derivation
SUITE["derive"]["context_sensitive"] = let
    rs = RuleSet([ContextRule('A', LSymbol('B'), nothing, LString("A"))])
    axiom = LString("ABBBBBBBBB")
    @benchmarkable derive($axiom, $rs, 5)
end

# Stochastic derivation
SUITE["derive"]["stochastic"] = let
    rs = RuleSet([StochasticRule(
        LSymbol('F'),
        [0.5, 0.5],
        [LString("F[+F]F[-F]F"), LString("F[-F]F[+F]F")]
    )])
    axiom = LString("F")
    @benchmarkable derive($axiom, $rs, 4; rng=StableRNG(42))
end

# ── Interpretation benchmarks ────────────────────────────────────

SUITE["interpret"] = BenchmarkGroup()

let rs = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))])
    ls = derive(LString("F"), rs, 4)
    SUITE["interpret"]["interpret2d"] = @benchmarkable interpret2d($ls; angle=25.7)
    SUITE["interpret"]["interpret3d"] = @benchmarkable interpret3d($ls; angle=25.7)
end

# ── Mesh generation ──────────────────────────────────────────────

SUITE["mesh"] = BenchmarkGroup()

let rs = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))])
    ls = derive(LString("F"), rs, 3)
    segs = interpret3d(ls; angle=25.7)
    SUITE["mesh"]["segments_to_mesh"] = @benchmarkable segments_to_mesh($segs)
    SUITE["mesh"]["pipe_model"] = @benchmarkable segments_to_mesh($segs; radius_mode=:pipe_model)
end

# ── Algorithm benchmarks ─────────────────────────────────────────

SUITE["algorithms"] = BenchmarkGroup()

# Space colonization
let rng = StableRNG(42)
    points = generate_envelope(:sphere, 100; rng=rng)
    SUITE["algorithms"]["space_colonize"] = @benchmarkable space_colonize($points; max_iterations=20, rng=StableRNG(42))
end

# Weber-Penn
SUITE["algorithms"]["weber_penn"] = let
    params = weber_penn_preset(:quaking_aspen)
    @benchmarkable generate_weber_penn($params; rng=StableRNG(42))
end

# Phyllotaxis
SUITE["algorithms"]["phyllotaxis"] = @benchmarkable phyllotaxis_positions(1000)

# ── LOD benchmarks ───────────────────────────────────────────────

SUITE["lod"] = let
    rs = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))])
    ls = derive(LString("F"), rs, 3)
    segs = interpret3d(ls; angle=25.7)
    @benchmarkable generate_lod($segs; levels=3)
end
