"""
    render_api.jl — Rendering API for L-system visualization

Defines the public rendering interface: bounding box computation, render stubs
(overridden by backend extensions like CairoMakie), and the convenience
`render_lsystem` pipeline.

Backend extensions (e.g. `ext/PhysisCairoMakieExt.jl`) override `render2d`
and `save_render` via Julia's package extension mechanism.
"""

# ──────────────────────────────────────────────────────────────────
# BoundingBox2D
# ──────────────────────────────────────────────────────────────────

"""
    BoundingBox2D(xmin, xmax, ymin, ymax)

Axis-aligned bounding box for 2D geometry.
"""
struct BoundingBox2D
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
end

# ──────────────────────────────────────────────────────────────────
# compute_bbox
# ──────────────────────────────────────────────────────────────────

"""
    compute_bbox(segments::Vector{LineSegment2D}; margin=0.1) -> BoundingBox2D

Compute the axis-aligned bounding box of a collection of 2D line segments,
with an optional margin expressed as a fraction of the **larger** dimension.

Degenerate cases (zero extent in both dimensions) default to a 1.0 unit extent.

Throws `ArgumentError` if `segments` is empty.
"""
function compute_bbox(segments::Vector{LineSegment2D}; margin::Real=0.1)
    isempty(segments) && throw(ArgumentError("cannot compute bounding box of empty segment list"))

    xmin = Inf
    xmax = -Inf
    ymin = Inf
    ymax = -Inf

    for seg in segments
        xmin = min(xmin, seg.start[1], seg.stop[1])
        xmax = max(xmax, seg.start[1], seg.stop[1])
        ymin = min(ymin, seg.start[2], seg.stop[2])
        ymax = max(ymax, seg.start[2], seg.stop[2])
    end

    width = xmax - xmin
    height = ymax - ymin

    # Degenerate: single point or collinear → default to 1.0 unit extent
    if width == 0.0 && height == 0.0
        cx = (xmin + xmax) / 2
        cy = (ymin + ymax) / 2
        xmin = cx - 0.5
        xmax = cx + 0.5
        ymin = cy - 0.5
        ymax = cy + 0.5
        width = 1.0
        height = 1.0
    end

    larger_dim = max(width, height)
    pad = Float64(margin) * larger_dim
    BoundingBox2D(xmin - pad, xmax + pad, ymin - pad, ymax + pad)
end

# ──────────────────────────────────────────────────────────────────
# Rendering function declarations (implemented by backend extensions)
# ──────────────────────────────────────────────────────────────────

"""
    render2d(segments; linecolor=:black, linewidth=1.0,
             backgroundcolor=:white, figsize=(800,800), margin=0.1) -> Figure

Render 2D line segments to a Makie Figure. Requires a backend (e.g. `using CairoMakie`).

Throws an informative error if no rendering backend (e.g. CairoMakie) is loaded.
"""
function render2d(args...; kwargs...)
    error("No rendering backend loaded. Run `using CairoMakie` before calling render2d.")
end

"""
    save_render(path, segments; kwargs...) -> Figure

Render 2D line segments and save to a file (PNG/SVG/PDF inferred from extension).
Requires a backend (e.g. `using CairoMakie`).

Throws an informative error if no rendering backend (e.g. CairoMakie) is loaded.
"""
function save_render(args...; kwargs...)
    error("No rendering backend loaded. Run `using CairoMakie` before calling save_render.")
end

# ──────────────────────────────────────────────────────────────────
# render_lsystem — full pipeline
# ──────────────────────────────────────────────────────────────────

"""
    render_lsystem(axiom, ruleset, generations;
                   angle=25.0, step=1.0, rng=Random.default_rng(), kwargs...) -> Figure

Full pipeline: derive → interpret2d → render2d.

Throws `ArgumentError` if derivation produces no `F` segments.
Extra `kwargs` are forwarded to `render2d`.
"""
function render_lsystem(axiom::LString, ruleset::RuleSet, generations::Integer;
                        angle::Real=25.0, step::Real=1.0,
                        rng::AbstractRNG=Random.default_rng(), kwargs...)
    derived = derive(axiom, ruleset, generations; rng=rng)
    segments = interpret2d(derived; angle=angle, step=step)
    isempty(segments) && throw(ArgumentError(
        "derivation produced no drawable segments (no F symbols after $generations generations)"))
    render2d(segments; kwargs...)
end
