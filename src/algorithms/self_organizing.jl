"""
    self_organizing.jl — Self-organizing tree models

Combines L-system growth with space colonization and light competition.
Buds have conical perception volumes and compete for resources based on
light availability. Low-vigor buds are pruned.

Reference: Palubicki et al. 2009, "Self-organizing Tree Models for Image Synthesis"
"""

using StaticArrays
using LinearAlgebra
using Random

"""
    LightGrid

A 3D voxel grid for tracking light/shadow in the scene.
Light values range from 0.0 (full shadow) to 1.0 (full light).
"""
mutable struct LightGrid
    resolution::Int
    extent::Float64
    grid::Array{Float64, 3}
end

"""
    LightGrid(resolution=20, extent=10.0)

Create a new light grid with all voxels at full light (1.0).
The grid covers the cube from `-extent/2` to `+extent/2` in each axis.
"""
function LightGrid(resolution::Int=20, extent::Float64=10.0)
    grid = ones(Float64, resolution, resolution, resolution)
    LightGrid(resolution, extent, grid)
end

"""Convert world position to grid indices, clamped to valid range."""
function _world_to_grid(lg::LightGrid, pos::SVector{3,Float64})
    half = lg.extent / 2
    x = clamp(round(Int, (pos[1] + half) / lg.extent * (lg.resolution - 1)) + 1, 1, lg.resolution)
    y = clamp(round(Int, (pos[2] + half) / lg.extent * (lg.resolution - 1)) + 1, 1, lg.resolution)
    z = clamp(round(Int, (pos[3] + half) / lg.extent * (lg.resolution - 1)) + 1, 1, lg.resolution)
    (x, y, z)
end

"""
    cast_shadow!(lg::LightGrid, pos::SVector{3,Float64}, strength::Float64)

Cast shadow downward from `pos`. Light decreases with attenuation proportional
to distance below the shadow-casting position.
"""
function cast_shadow!(lg::LightGrid, pos::SVector{3,Float64}, strength::Float64)
    x, _, z = _world_to_grid(lg, pos)
    _, y_pos, _ = _world_to_grid(lg, pos)
    # Shadow falls downward (decreasing y index)
    for y in y_pos:-1:1
        attenuation = strength * (1.0 - (y_pos - y) / lg.resolution)
        lg.grid[x, y, z] = max(0.0, lg.grid[x, y, z] - attenuation)
    end
end

"""
    query_light(lg::LightGrid, pos::SVector{3,Float64}) -> Float64

Query the light value at a world position. Returns a value in [0, 1].
"""
function query_light(lg::LightGrid, pos::SVector{3,Float64})
    x, y, z = _world_to_grid(lg, pos)
    lg.grid[x, y, z]
end

"""
    SelfOrgBud

A bud in the self-organizing tree with position, growth direction,
vigor (resource availability), parent tracking, and branching depth.
"""
struct SelfOrgBud
    position::SVector{3,Float64}
    direction::SVector{3,Float64}
    vigor::Float64
    parent_index::Int
    depth::Int
end

"""
    self_organize_tree(; envelope, iterations, growth_step=1.0,
                       bud_perception_angle=90.0, shadow_strength=0.3,
                       d_attraction=10.0, d_kill=2.0,
                       vigor_threshold=0.1,
                       root=SVector(0.0, 0.0, 0.0),
                       rng=Random.default_rng()) -> Vector{LineSegment3D}

Generate a tree using the self-organizing algorithm.

Buds grow toward attraction points within their conical perception volume.
Light competition via a shadow grid modulates bud vigor; low-vigor buds
are pruned. This produces naturally asymmetric, light-seeking crowns.

# Arguments
- `envelope`: attraction points defining the target crown shape
- `iterations`: maximum growth iterations
- `growth_step`: distance each bud grows per iteration
- `bud_perception_angle`: full cone angle (degrees) of bud perception
- `shadow_strength`: how much shadow each growth point casts
- `d_attraction`: max distance for a bud to sense an attraction point
- `d_kill`: distance at which a bud removes an attraction point
- `vigor_threshold`: minimum vigor for a bud to remain active
- `root`: root position of the tree
- `rng`: random number generator for reproducibility

Reference: Palubicki et al. 2009, "Self-organizing Tree Models for Image Synthesis"
"""
function self_organize_tree(;
    envelope::Vector{SVector{3,Float64}}=SVector{3,Float64}[],
    iterations::Int=50,
    growth_step::Float64=1.0,
    bud_perception_angle::Float64=90.0,
    shadow_strength::Float64=0.3,
    d_attraction::Float64=10.0,
    d_kill::Float64=2.0,
    vigor_threshold::Float64=0.1,
    root::SVector{3,Float64}=SVector(0.0, 0.0, 0.0),
    rng::AbstractRNG=Random.default_rng()
)
    isempty(envelope) && return LineSegment3D[]

    points = copy(envelope)
    segments = LineSegment3D[]
    # Size the grid to encompass all envelope points with margin
    grid_extent = maximum(norm(p) for p in envelope) * 2.5 + 1.0
    light_grid = LightGrid(20, grid_extent)

    buds = [SelfOrgBud(root, SVector(0.0, 1.0, 0.0), 1.0, -1, 0)]

    perception_cos = cos(deg2rad(bud_perception_angle / 2))

    for _iter in 1:iterations
        isempty(points) && break

        # For each attraction point, find the closest bud within its perception cone
        bud_influences = Dict{Int, Vector{SVector{3,Float64}}}()

        for p in points
            closest_bud = -1
            closest_dist = Inf
            for (bi, bud) in enumerate(buds)
                bud.vigor < vigor_threshold && continue

                diff = p - bud.position
                d = norm(diff)
                d < 1e-14 && continue

                if d < d_attraction
                    # Check if point is within the bud's perception cone
                    cos_angle = dot(diff / d, bud.direction)
                    if cos_angle >= perception_cos && d < closest_dist
                        closest_dist = d
                        closest_bud = bi
                    end
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

        # Grow new buds — iterate in sorted order for determinism
        new_buds = SelfOrgBud[]
        for bi in sort!(collect(keys(bud_influences)))
            influenced_points = bud_influences[bi]
            bud = buds[bi]

            # Average direction toward all influenced attraction points
            avg_dir = sum(normalize(p - bud.position) for p in influenced_points)
            avg_dir_norm = norm(avg_dir)
            avg_dir_norm < 1e-14 && continue
            avg_dir = avg_dir / avg_dir_norm

            new_pos = bud.position + growth_step * avg_dir

            # Vigor modulated by local light availability
            light = query_light(light_grid, new_pos)
            new_vigor = bud.vigor * light

            push!(segments, LineSegment3D(bud.position, new_pos, max(0.01, new_vigor), bud.depth))

            # New growth casts shadow on voxels below
            cast_shadow!(light_grid, new_pos, shadow_strength)

            push!(new_buds, SelfOrgBud(new_pos, avg_dir, new_vigor, bi, bud.depth + 1))
        end

        append!(buds, new_buds)

        # Remove attraction points that have been reached (within d_kill of any bud)
        filter!(p -> all(norm(p - b.position) > d_kill for b in buds), points)
    end

    segments
end
