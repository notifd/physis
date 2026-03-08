"""
    PhysisCairoMakieExt — CairoMakie rendering backend for Physis

Package extension that provides 2D rendering of L-system geometry using
CairoMakie. Activated automatically when the user does `using CairoMakie`.

Overrides the stub `render2d` and `save_render` methods from Physis.
"""
module PhysisCairoMakieExt

using Physis
using CairoMakie

# ──────────────────────────────────────────────────────────────────
# render2d — render segments to a Makie Figure
# ──────────────────────────────────────────────────────────────────

function Physis.render2d(segments::Vector{Physis.LineSegment2D};
                         linecolor=:black, linewidth=1.0,
                         backgroundcolor=:white, figsize=(800, 800),
                         margin::Real=0.1)
    bbox = Physis.compute_bbox(segments; margin=margin)

    fig = Figure(; size=figsize, backgroundcolor=backgroundcolor)
    ax = Axis(fig[1, 1];
              backgroundcolor=backgroundcolor,
              aspect=DataAspect(),
              limits=(bbox.xmin, bbox.xmax, bbox.ymin, bbox.ymax))

    hidedecorations!(ax)
    hidespines!(ax)

    # Flatten segments into pairs of Point2f for linesegments!
    points = Vector{Point2f}(undef, 2 * length(segments))
    for (i, seg) in enumerate(segments)
        idx = 2 * (i - 1)
        points[idx + 1] = Point2f(seg.start[1], seg.start[2])
        points[idx + 2] = Point2f(seg.stop[1], seg.stop[2])
    end

    linesegments!(ax, points; color=linecolor, linewidth=linewidth)

    fig
end

# ──────────────────────────────────────────────────────────────────
# save_render — render and save to file
# ──────────────────────────────────────────────────────────────────

function Physis.save_render(path::AbstractString,
                            segments::Vector{Physis.LineSegment2D}; kwargs...)
    fig = Physis.render2d(segments; kwargs...)
    save(path, fig)
    fig
end

end # module PhysisCairoMakieExt
