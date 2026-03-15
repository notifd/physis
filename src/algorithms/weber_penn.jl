"""
    weber_penn.jl — Weber-Penn parametric tree generation

Implements a simplified version of the Weber-Penn tree model for realistic
tree generation using branching parameters per level.

Reference: Weber & Penn 1995, "Creation and Rendering of Realistic Trees", SIGGRAPH 1995
"""

using StaticArrays
using LinearAlgebra
using Random

"""
    WeberPennParams

Parameters for the Weber-Penn tree model. Simplified from the full 80+ parameter
set in the original paper to the most impactful parameters.

# Key Parameters (per-level arrays indexed by level+1, where level 0 = trunk)
- `shape::Int` — overall tree shape envelope (0=conical, 1=spherical, 2=hemispherical,
   3=cylindrical, 4=tapered cylindrical, 5=flame, 6=inverse conical, 7=tend flame)
- `levels::Int` — number of branching levels (1=trunk only, 2=trunk+branches, etc.)
- `base_size::Float64` — fraction of trunk bare of branches
- `scale::Float64` — overall scale of the tree
- `ratio::Float64` — ratio of branch radius to parent radius
- `ratio_power::Float64` — power applied to ratio scaling
- `n_length::Vector{Float64}` — relative length per level (fraction of parent)
- `n_curve::Vector{Float64}` — curvature angle per level (degrees)
- `n_seg_splits::Vector{Float64}` — number of splits per segment per level
- `n_branches::Vector{Int}` — number of branches per level
- `down_angle::Vector{Float64}` — angle from parent axis (degrees)
- `rotate_angle::Vector{Float64}` — rotation around parent axis (degrees)
- `trunk_length::Float64` — length of trunk
- `trunk_segments::Int` — number of segments in trunk

Reference: Weber & Penn 1995, Table 1
"""
struct WeberPennParams
    shape::Int
    levels::Int
    base_size::Float64
    scale::Float64
    ratio::Float64
    ratio_power::Float64
    n_length::Vector{Float64}
    n_curve::Vector{Float64}
    n_seg_splits::Vector{Float64}
    n_branches::Vector{Int}
    down_angle::Vector{Float64}
    rotate_angle::Vector{Float64}
    trunk_length::Float64
    trunk_segments::Int
end

# Keyword constructor with defaults
function WeberPennParams(;
    shape::Int=0,
    levels::Int=2,
    base_size::Float64=0.3,
    scale::Float64=10.0,
    ratio::Float64=0.02,
    ratio_power::Float64=1.3,
    n_length::Vector{Float64}=[1.0, 0.3, 0.6, 0.4],
    n_curve::Vector{Float64}=[0.0, 40.0, 75.0, 0.0],
    n_seg_splits::Vector{Float64}=[0.0, 0.0, 0.0, 0.0],
    n_branches::Vector{Int}=[1, 20, 10, 5],
    down_angle::Vector{Float64}=[0.0, 30.0, 45.0, 45.0],
    rotate_angle::Vector{Float64}=[0.0, 140.0, 140.0, 77.0],
    trunk_length::Float64=1.0,
    trunk_segments::Int=8
)
    WeberPennParams(shape, levels, base_size, scale, ratio, ratio_power,
                    n_length, n_curve, n_seg_splits, n_branches,
                    down_angle, rotate_angle, trunk_length, trunk_segments)
end

"""
    weber_penn_preset(name::Symbol) -> WeberPennParams

Return preset parameters from Weber & Penn 1995, Table 4.
Available presets: `:quaking_aspen`, `:black_tupelo`, `:weeping_willow`, `:palm`

Reference: Weber & Penn 1995, Section 5
"""
function weber_penn_preset(name::Symbol)
    presets = Dict{Symbol, WeberPennParams}(
        :quaking_aspen => WeberPennParams(
            shape=2, levels=3, base_size=0.4, scale=13.0,
            ratio=0.015, ratio_power=1.3,
            n_length=[1.0, 0.3, 0.6, 0.0],
            n_curve=[0.0, -40.0, -40.0, 0.0],
            n_seg_splits=[0.0, 0.0, 0.0, 0.0],
            n_branches=[1, 50, 30, 0],
            down_angle=[0.0, 60.0, 45.0, 0.0],
            rotate_angle=[0.0, 140.0, 140.0, 0.0],
            trunk_length=1.0, trunk_segments=10
        ),
        :black_tupelo => WeberPennParams(
            shape=4, levels=3, base_size=0.2, scale=23.0,
            ratio=0.015, ratio_power=1.3,
            n_length=[1.0, 0.3, 0.4, 0.0],
            n_curve=[0.0, -40.0, -40.0, 0.0],
            n_seg_splits=[0.0, 0.0, 0.0, 0.0],
            n_branches=[1, 40, 120, 0],
            down_angle=[0.0, 60.0, 30.0, 0.0],
            rotate_angle=[0.0, 140.0, 77.0, 0.0],
            trunk_length=1.0, trunk_segments=12
        ),
        :weeping_willow => WeberPennParams(
            shape=3, levels=3, base_size=0.05, scale=15.0,
            ratio=0.02, ratio_power=1.5,
            n_length=[1.0, 0.5, 1.5, 0.0],
            n_curve=[0.0, 40.0, 0.0, 0.0],
            n_seg_splits=[0.0, 0.0, 0.0, 0.0],
            n_branches=[1, 25, 10, 0],
            down_angle=[0.0, 20.0, 120.0, 0.0],
            rotate_angle=[0.0, -120.0, -120.0, 0.0],
            trunk_length=1.0, trunk_segments=10
        ),
        :palm => WeberPennParams(
            shape=4, levels=2, base_size=0.95, scale=12.0,
            ratio=0.05, ratio_power=1.0,
            n_length=[1.0, 2.0, 0.0, 0.0],
            n_curve=[0.0, -80.0, 0.0, 0.0],
            n_seg_splits=[0.0, 0.0, 0.0, 0.0],
            n_branches=[1, 12, 0, 0],
            down_angle=[0.0, 50.0, 0.0, 0.0],
            rotate_angle=[0.0, 137.5, 0.0, 0.0],
            trunk_length=1.0, trunk_segments=6
        ),
    )
    haskey(presets, name) || throw(ArgumentError(
        "Unknown Weber-Penn preset: $name. Available: $(join(keys(presets), ", "))"))
    presets[name]
end

"""
    generate_weber_penn(params::WeberPennParams; rng=Random.default_rng()) -> Vector{LineSegment3D}

Generate a tree using the Weber-Penn parametric model. Returns a vector of
`LineSegment3D` representing the tree skeleton.

Each segment has:
- `start`, `stop`: 3D positions (SVector{3,Float64})
- `width`: branch radius at that segment
- `depth`: branching level (0=trunk, 1=primary branches, etc.)

Reference: Weber & Penn 1995, Section 3
"""
function generate_weber_penn(params::WeberPennParams; rng::AbstractRNG=Random.default_rng())
    segments = LineSegment3D[]

    # Compute trunk length from scale and level-0 length parameter
    trunk_length = params.scale * params.trunk_length * _wp_get_param(params.n_length, 1)
    seg_length = trunk_length / params.trunk_segments

    pos = SVector(0.0, 0.0, 0.0)
    heading = SVector(0.0, 1.0, 0.0)  # Y-up

    # Generate trunk segments
    trunk_positions = SVector{3,Float64}[pos]
    curve_per_seg = _wp_get_param(params.n_curve, 1) / params.trunk_segments

    trunk_width = params.scale * params.ratio

    for i in 1:params.trunk_segments
        new_pos = pos + seg_length * heading
        # Taper trunk width linearly
        t = (i - 1) / params.trunk_segments
        w = trunk_width * (1.0 - 0.5 * t)
        push!(segments, LineSegment3D(pos, new_pos, w, 0))
        push!(trunk_positions, new_pos)
        pos = new_pos

        # Apply curvature to heading
        if abs(curve_per_seg) > 0.01
            heading = _wp_apply_curve(heading, curve_per_seg, rng)
        end
    end

    # Generate branches at deeper levels
    if params.levels >= 2
        _wp_generate_branches!(segments, params, trunk_positions, trunk_length,
                               heading, trunk_width, 1, rng)
    end

    segments
end

# ── Internal helpers ─────────────────────────────────────────────────

"""Safely get a level parameter (1-indexed; level 0 = index 1)."""
function _wp_get_param(arr::AbstractVector, level_1indexed::Int)
    idx = clamp(level_1indexed, 1, length(arr))
    arr[idx]
end

"""Apply curvature by rotating heading around a random perpendicular axis.

Uses Rodrigues' rotation formula. Reference: Weber & Penn 1995, Section 3.2
"""
function _wp_apply_curve(heading::SVector{3,Float64}, angle_deg::Float64,
                         rng::AbstractRNG)
    angle_rad = deg2rad(angle_deg)
    # Find a perpendicular axis
    ref = abs(dot(heading, SVector(1.0, 0.0, 0.0))) < 0.9 ?
          SVector(1.0, 0.0, 0.0) : SVector(0.0, 0.0, 1.0)
    perp = normalize(cross(heading, ref))
    # Random spin around heading for natural variation
    spin = rand(rng) * 2π
    perp = cos(spin) * perp + sin(spin) * cross(heading, perp)
    perp = normalize(perp)
    # Rodrigues' rotation
    _wp_rodrigues(heading, perp, angle_rad)
end

"""Rotate vector `v` around axis `k` by `angle_rad` using Rodrigues' formula."""
function _wp_rodrigues(v::SVector{3,Float64}, k::SVector{3,Float64}, angle_rad::Float64)
    c = cos(angle_rad)
    s = sin(angle_rad)
    result = v * c + cross(k, v) * s + k * dot(k, v) * (1 - c)
    normalize(result)
end

"""Recursively generate branches for a given parent level.

Reference: Weber & Penn 1995, Section 3.3
"""
function _wp_generate_branches!(segments, params, parent_positions, parent_length,
                                parent_heading, parent_width, level, rng)
    level > params.levels && return

    level_idx = level + 1  # 1-indexed (level 0 = trunk = index 1)

    n_branches = _wp_get_param(params.n_branches, level_idx)
    n_branches <= 0 && return

    branch_length = parent_length * _wp_get_param(params.n_length, level_idx)
    down_angle_deg = _wp_get_param(params.down_angle, level_idx)
    rotate_angle_deg = _wp_get_param(params.rotate_angle, level_idx)
    curve_deg = _wp_get_param(params.n_curve, level_idx)

    n_parent_pos = length(parent_positions)
    base_start_idx = max(2, round(Int, params.base_size * n_parent_pos))

    current_rotation = rand(rng) * 360.0

    for b in 1:n_branches
        # Attachment point along parent (distribute evenly above base_size)
        available = n_parent_pos - base_start_idx
        if available > 0 && n_branches > 1
            t = base_start_idx + round(Int, (b - 1) * available / (n_branches - 1))
        else
            t = base_start_idx
        end
        t = clamp(t, 1, n_parent_pos)
        branch_origin = parent_positions[t]

        # Compute branch direction: rotate parent heading by down_angle
        # Need a stable perpendicular to parent_heading
        ref = abs(dot(parent_heading, SVector(1.0, 0.0, 0.0))) < 0.9 ?
              SVector(1.0, 0.0, 0.0) : SVector(0.0, 0.0, 1.0)
        perp = normalize(cross(parent_heading, ref))

        branch_heading = _wp_rodrigues(parent_heading, perp, deg2rad(down_angle_deg))

        # Rotate around parent axis with divergence angle
        current_rotation += rotate_angle_deg + (rand(rng) - 0.5) * 10.0
        branch_heading = _wp_rodrigues(branch_heading, parent_heading,
                                       deg2rad(current_rotation))

        # Generate branch segments (4 segments per branch)
        n_segs = 4
        seg_len = branch_length / n_segs

        pos = branch_origin
        heading = branch_heading
        branch_positions = SVector{3,Float64}[pos]
        curve_per_seg = curve_deg / n_segs

        # Width decreases with level (Weber-Penn ratio model)
        width = parent_width * params.ratio^(params.ratio_power * level)
        width = max(width, 0.005)

        for s in 1:n_segs
            new_pos = pos + seg_len * heading
            push!(segments, LineSegment3D(pos, new_pos, width, level))
            push!(branch_positions, new_pos)
            pos = new_pos
            if abs(curve_per_seg) > 0.01
                heading = _wp_apply_curve(heading, curve_per_seg, rng)
            end
        end

        # Recurse for sub-branches
        if level + 1 <= params.levels
            _wp_generate_branches!(segments, params, branch_positions, branch_length,
                                   heading, width, level + 1, rng)
        end
    end
end
