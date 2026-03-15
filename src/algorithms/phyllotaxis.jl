"""
    phyllotaxis.jl — Fibonacci spiral phyllotaxis

Generates points arranged in a phyllotactic spiral pattern using
the golden angle (137.508°), as seen in sunflower heads, pinecones, etc.

Reference: Vogel 1979 "A better way to construct the sunflower head"
"""

using StaticArrays

# ──────────────────────────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────────────────────────

"""
    GOLDEN_ANGLE

The golden angle in degrees: 360° × (1 - 1/φ) ≈ 137.508°,
where φ = (1 + √5) / 2 is the golden ratio.
"""
const GOLDEN_ANGLE = 137.50776405003785

# ──────────────────────────────────────────────────────────────────
# phyllotaxis_positions
# ──────────────────────────────────────────────────────────────────

"""
    phyllotaxis_positions(n::Int; radius=1.0, divergence_angle=GOLDEN_ANGLE) -> Vector{SVector{3,Float64}}

Generate `n` positions in a phyllotactic (Fibonacci) spiral pattern.

    θ_k = k × divergence_angle (degrees → radians)
    r_k = radius × √(k / n)

Points are generated in the XZ plane (y = 0), normalized so the outermost
points are at distance `radius` from the origin.

Reference: Vogel 1979, eq. 1
"""
function phyllotaxis_positions(n::Int; radius::Float64=1.0,
                                divergence_angle::Float64=GOLDEN_ANGLE)
    n <= 0 && return SVector{3,Float64}[]

    positions = Vector{SVector{3,Float64}}(undef, n)
    for k in 1:n
        θ = deg2rad(k * divergence_angle)
        r = radius * sqrt(k / n)
        positions[k] = SVector(r * cos(θ), 0.0, r * sin(θ))
    end
    positions
end
