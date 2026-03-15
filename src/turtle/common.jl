"""
    common.jl — Shared helpers for 2D and 3D turtle interpreters

Provides parametric symbol extraction utilities used by both interpret2d and interpret3d,
and the OrganPlacement struct for recording organ positions during turtle interpretation.
"""

using StaticArrays

"""Extract step distance from a parametric symbol, or use default."""
_get_step(::LSymbol, default::Float64) = default
_get_step(sym::ParametricSymbol, default::Float64) = sym.params[1]

"""Extract angle (converting degrees → radians) from a parametric symbol, or use default (already radians)."""
_get_angle(::LSymbol, default_rad::Float64) = default_rad
_get_angle(sym::ParametricSymbol, ::Float64) = deg2rad(sym.params[1])

# ──────────────────────────────────────────────────────────────────
# OrganPlacement
# ──────────────────────────────────────────────────────────────────

"""
    OrganPlacement

Records the position and orientation where an organ (leaf, flower, fruit)
should be placed, along with its type and scale.

# Fields
- `position::SVector{3, Float64}` — world position of the organ
- `heading::SVector{3, Float64}` — forward direction (turtle H vector)
- `up::SVector{3, Float64}` — up direction (turtle U vector)
- `left::SVector{3, Float64}` — left direction (turtle L vector)
- `organ_type::Symbol` — one of `:leaf`, `:flower`, `:fruit`
- `scale::Float64` — scale factor for the organ mesh

Reference: ABOP §2.5 "Predefined surfaces"
"""
struct OrganPlacement
    position::SVector{3, Float64}
    heading::SVector{3, Float64}
    up::SVector{3, Float64}
    left::SVector{3, Float64}
    organ_type::Symbol  # :leaf, :flower, :fruit
    scale::Float64
end
