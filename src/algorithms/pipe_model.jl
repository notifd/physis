"""
    pipe_model.jl — Pipe model for realistic branch radii

Implements the pipe model theory: each leaf is connected to the base by
one "pipe", so the cross-sectional area at any point equals the number
of downstream leaves times the pipe area.

    r_parent² = Σ r_child²  (area conservation at branching points)

Reference: Shinozaki et al. 1964 "A quantitative analysis of plant form — the pipe model theory"
"""

# ──────────────────────────────────────────────────────────────────
# compute_pipe_radii
# ──────────────────────────────────────────────────────────────────

"""
    compute_pipe_radii(segments::Vector{LineSegment3D}, base_radius::Float64) -> Vector{Float64}

Compute per-segment radii using the pipe model. The radius of each segment
is proportional to `√(descendant_leaves / max_descendants)`, ensuring
area conservation at branching points.

Returns a vector of radii, one per segment.

Reference: Shinozaki et al. 1964
"""
function compute_pipe_radii(segments::Vector{LineSegment3D}, base_radius::Float64)
    isempty(segments) && return Float64[]

    tree = build_tree(segments)

    # Find max descendant count (should be at root)
    max_descendants = maximum(t.descendant_leaves for t in tree)
    max_descendants == 0 && (max_descendants = 1)

    # r(node) = base_radius * sqrt(descendants / max_descendants)
    [base_radius * sqrt(tree[i].descendant_leaves / max_descendants) for i in 1:length(segments)]
end
