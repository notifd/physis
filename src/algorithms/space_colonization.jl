"""
    space_colonization.jl — Space colonization algorithm for tree generation

Grows tree structures by iteratively extending buds toward scattered
attraction points in a 3D envelope.

Reference: Runions, Lane & Prusinkiewicz 2007, "Modeling Trees with a Space Colonization Algorithm"
"""

using StaticArrays
using LinearAlgebra
using Random

"""
    generate_envelope(shape::Symbol, n::Int; kwargs...) -> Vector{SVector{3,Float64}}

Generate `n` attraction points within a 3D envelope.

# Shapes
- `:sphere` — uniform random points in a sphere
- `:cylinder` — uniform random points in a cylinder
- `:cone` — uniform random points in a cone
- `:crown` — spherical shell (hollow sphere)

# Keyword Arguments
- `radius::Float64=5.0`
- `height::Float64=10.0` (for cylinder/cone)
- `center::SVector{3,Float64}=SVector(0.0, 5.0, 0.0)`
- `rng::AbstractRNG=Random.default_rng()`
- `inner_radius::Float64=0.0` (for crown shape)
"""
function generate_envelope(shape::Symbol, n::Int;
                           radius::Float64=5.0,
                           height::Float64=10.0,
                           center::SVector{3,Float64}=SVector(0.0, 5.0, 0.0),
                           inner_radius::Float64=0.0,
                           rng::AbstractRNG=Random.default_rng())
    points = Vector{SVector{3,Float64}}(undef, n)

    if shape == :sphere
        for i in 1:n
            points[i] = _random_in_sphere(rng, radius, center)
        end
    elseif shape == :cylinder
        for i in 1:n
            points[i] = _random_in_cylinder(rng, radius, height, center)
        end
    elseif shape == :cone
        for i in 1:n
            points[i] = _random_in_cone(rng, radius, height, center)
        end
    elseif shape == :crown
        for i in 1:n
            points[i] = _random_in_crown(rng, radius, inner_radius, center)
        end
    else
        error("Unknown envelope shape: $shape. Use :sphere, :cylinder, :cone, or :crown.")
    end

    return points
end

# ── Envelope sampling helpers ─────────────────────────────────────

function _random_in_sphere(rng::AbstractRNG, radius::Float64, center::SVector{3,Float64})
    # Rejection sampling for uniform distribution in sphere
    while true
        x = 2.0 * rand(rng) - 1.0
        y = 2.0 * rand(rng) - 1.0
        z = 2.0 * rand(rng) - 1.0
        if x^2 + y^2 + z^2 <= 1.0
            return center + radius * SVector(x, y, z)
        end
    end
end

function _random_in_cylinder(rng::AbstractRNG, radius::Float64, height::Float64,
                             center::SVector{3,Float64})
    # Uniform in disk (rejection) + uniform height
    while true
        x = 2.0 * rand(rng) - 1.0
        z = 2.0 * rand(rng) - 1.0
        if x^2 + z^2 <= 1.0
            y = rand(rng) * height + center[2]
            return SVector(x * radius, y, z * radius)
        end
    end
end

function _random_in_cone(rng::AbstractRNG, radius::Float64, height::Float64,
                         center::SVector{3,Float64})
    # Sample height with PDF proportional to (1 - y/h)^2 for uniform volume
    # Using CDF inversion: y = h * (1 - cbrt(u))
    while true
        u = rand(rng)
        y = height * (1.0 - cbrt(u))
        max_r = radius * (1.0 - y / height)
        # Uniform in disk of radius max_r
        dx = 2.0 * rand(rng) - 1.0
        dz = 2.0 * rand(rng) - 1.0
        if dx^2 + dz^2 <= 1.0
            return center + SVector(dx * max_r, y, dz * max_r)
        end
    end
end

function _random_in_crown(rng::AbstractRNG, radius::Float64, inner_radius::Float64,
                          center::SVector{3,Float64})
    # Rejection sampling: uniform in sphere, reject if inside inner sphere
    while true
        p = _random_in_sphere(rng, radius, center)
        if norm(p - center) >= inner_radius
            return p
        end
    end
end

# ── Tree bud for space colonization ──────────────────────────────

struct TreeBud
    position::SVector{3,Float64}
    parent_index::Int  # index of parent bud (-1 for root)
end

"""
    space_colonize(attraction_points; root, growth_step, d_attraction, d_kill,
                   max_iterations, rng) -> Vector{LineSegment3D}

Run the space colonization algorithm.

# Algorithm (Runions et al. 2007)
1. For each attraction point, find the closest bud within `d_attraction`
2. For each influenced bud, average the normalized directions to its attraction points
3. Grow a new bud at `growth_step` distance in the averaged direction
4. Remove attraction points within `d_kill` of any bud
5. Repeat until no attraction points remain or `max_iterations` reached

Returns segments as `Vector{LineSegment3D}` with depth tracking.
"""
function space_colonize(attraction_points::Vector{SVector{3,Float64}};
                        root::SVector{3,Float64}=SVector(0.0, 0.0, 0.0),
                        growth_step::Float64=1.0,
                        d_attraction::Float64=10.0,
                        d_kill::Float64=2.0,
                        max_iterations::Int=100,
                        rng::AbstractRNG=Random.default_rng())
    isempty(attraction_points) && return LineSegment3D[]

    points = copy(attraction_points)
    buds = [TreeBud(root, -1)]
    segments = LineSegment3D[]
    bud_depth = Dict{Int,Int}(1 => 0)

    for _ in 1:max_iterations
        isempty(points) && break

        # For each attraction point, find the closest bud within d_attraction
        bud_influences = Dict{Int,Vector{SVector{3,Float64}}}()

        for p in points
            closest_bud = -1
            closest_dist = Inf
            for (bi, bud) in enumerate(buds)
                d = norm(p - bud.position)
                if d < d_attraction && d < closest_dist
                    closest_dist = d
                    closest_bud = bi
                end
            end
            if closest_bud > 0
                if !haskey(bud_influences, closest_bud)
                    bud_influences[closest_bud] = SVector{3,Float64}[]
                end
                push!(bud_influences[closest_bud], p)
            end
        end

        isempty(bud_influences) && break

        # Grow new buds toward averaged attraction directions
        new_buds = TreeBud[]
        for (bi, influenced_points) in bud_influences
            avg_dir = sum(normalize(p - buds[bi].position) for p in influenced_points)
            avg_dir_norm = norm(avg_dir)
            avg_dir_norm < 1e-14 && continue
            avg_dir = avg_dir / avg_dir_norm

            new_pos = buds[bi].position + growth_step * avg_dir
            depth = get(bud_depth, bi, 0)
            push!(segments, LineSegment3D(buds[bi].position, new_pos, 1.0, depth))
            push!(new_buds, TreeBud(new_pos, bi))
        end

        # Add new buds and track their depths
        for nb in new_buds
            push!(buds, nb)
            bud_depth[length(buds)] = get(bud_depth, nb.parent_index, 0) + 1
        end

        # Remove attraction points within d_kill of any bud
        filter!(p -> all(norm(p - b.position) > d_kill for b in buds), points)
    end

    return segments
end
