"""
    animation.jl — Growth animation for L-systems

Renders each generation of an L-system derivation as a separate frame,
allowing visualization of development sequences.

Reference: ABOP Ch. 1.9 "Development sequences"
"""

"""
    animate_growth(def::LSystemDef; output_dir::String=".",
                   format::Symbol=:svg, rng::AbstractRNG=Random.default_rng()) -> Vector{String}

Render generations 0 through `def.generations` as individual frames.
Returns a vector of file paths to the rendered frames.

Each frame is rendered as an SVG file showing the 2D interpretation
of the L-string at that generation.

# Arguments
- `def::LSystemDef` — the species definition to animate
- `output_dir::String` — directory to save frames (created if needed)
- `format::Symbol` — output format, `:svg` (default)
- `rng::AbstractRNG` — RNG for stochastic rules

# Returns
Vector of file paths (one per generation, 0 through N).
"""
function animate_growth(def::LSystemDef;
                        output_dir::String=".",
                        format::Symbol=:svg,
                        rng::AbstractRNG=Random.default_rng())
    mkpath(output_dir)

    frames = String[]
    current = def.axiom

    for gen in 0:def.generations
        # Process the current string for rendering
        processed = substitute_draw_symbols(current, def.draw_chars)
        segments = interpret2d(processed; angle=def.angle, step=def.step)

        # Generate SVG for this frame
        ext = string(format)
        filename = joinpath(output_dir, "frame_$(lpad(gen, 4, '0')).$ext")

        _write_svg_frame(filename, segments, gen, def.name)
        push!(frames, filename)

        # Derive next generation (except after last)
        if gen < def.generations
            current = rewrite_step(current, def.rules; rng=rng)
        end
    end

    frames
end

"""
    _write_svg_frame(path, segments, gen, title)

Write a simple SVG file for a set of 2D line segments.
"""
function _write_svg_frame(path::String, segments::Vector{LineSegment2D},
                          gen::Int, title::String)
    if isempty(segments)
        # Write minimal SVG for empty frame
        open(path, "w") do io
            write(io, """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400">
<text x="200" y="200" text-anchor="middle">$(title) - Gen $(gen) (empty)</text>
</svg>""")
        end
        return
    end

    # Compute bounding box
    all_x = Float64[]
    all_y = Float64[]
    for seg in segments
        push!(all_x, seg.start[1], seg.stop[1])
        push!(all_y, seg.start[2], seg.stop[2])
    end

    xmin, xmax = minimum(all_x), maximum(all_x)
    ymin, ymax = minimum(all_y), maximum(all_y)

    # Add margin
    margin = max(xmax - xmin, ymax - ymin) * 0.1 + 1.0
    xmin -= margin; xmax += margin
    ymin -= margin; ymax += margin

    width = xmax - xmin
    height = ymax - ymin

    # SVG coordinate system (flip Y)
    svg_width = 800
    svg_height = round(Int, 800 * height / max(width, 1e-10))
    svg_height = max(svg_height, 100)

    open(path, "w") do io
        write(io, """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="$(svg_width)" height="$(svg_height)" viewBox="$(xmin) $(-ymax) $(width) $(height)">
<rect width="100%" height="100%" fill="black"/>
<g stroke="#50fa7b" stroke-width="0.02" stroke-linecap="round">
""")
        for seg in segments
            x1, y1 = seg.start[1], -seg.start[2]
            x2, y2 = seg.stop[1], -seg.stop[2]
            write(io, """<line x1="$(x1)" y1="$(y1)" x2="$(x2)" y2="$(y2)"/>
""")
        end
        write(io, """</g>
<text x="$(xmin + 0.5)" y="$(-ymax + 1.0)" fill="white" font-size="0.8">$(title) - Gen $(gen)</text>
</svg>""")
    end
end
