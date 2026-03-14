"""
    common.jl — Shared helpers for 2D and 3D turtle interpreters

Provides parametric symbol extraction utilities used by both interpret2d and interpret3d.
"""

"""Extract step distance from a parametric symbol, or use default."""
_get_step(::LSymbol, default::Float64) = default
_get_step(sym::ParametricSymbol, default::Float64) = sym.params[1]

"""Extract angle (converting degrees → radians) from a parametric symbol, or use default (already radians)."""
_get_angle(::LSymbol, default_rad::Float64) = default_rad
_get_angle(sym::ParametricSymbol, ::Float64) = deg2rad(sym.params[1])
