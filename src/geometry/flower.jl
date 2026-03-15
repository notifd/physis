"""
    flower.jl — Flower and petal mesh generation for L-system plant organs

Generates flower meshes with radially symmetric petals.

Reference: Prusinkiewicz 1993; ABOP §2.5
"""

using StaticArrays
using LinearAlgebra

# ──────────────────────────────────────────────────────────────────
# petal_mesh
# ──────────────────────────────────────────────────────────────────

"""
    petal_mesh(; length=1.0, width=0.3, segments=4, rotation=0.0,
               color=SVector(1.0, 0.4, 0.7, 1.0)) -> TriangleMesh

Generate a single petal mesh. The petal extends outward in the XZ plane
from the origin, curving slightly upward.

# Arguments
- `length::Float64` — length of the petal
- `width::Float64` — maximum half-width of the petal
- `segments::Int` — number of subdivisions along length
- `rotation::Float64` — rotation angle (radians) around Y axis
- `color::SVector{4,Float64}` — vertex color
"""
function petal_mesh(; length::Float64=1.0, width::Float64=0.3, segments::Int=4,
                    rotation::Float64=0.0,
                    color::SVector{4,Float64}=SVector(1.0, 0.4, 0.7, 1.0))
    up_normal = SVector(0.0, 1.0, 0.0)
    cos_r = cos(rotation)
    sin_r = sin(rotation)

    vertices = SVector{3,Float64}[]
    norms = SVector{3,Float64}[]
    uv_coords = SVector{2,Float64}[]
    faces = NTuple{3,Int}[]

    # Petal profile: widest at ~0.4, tapering to 0 at base and tip
    # w(t) = width * sin(π*t)^0.7  (slightly wider than pure sine)
    _petal_width(t) = width * sin(π * t)^0.7

    # Base point
    push!(vertices, SVector(0.0, 0.0, 0.0))
    push!(norms, _rotate_y(up_normal, cos_r, sin_r))
    push!(uv_coords, SVector(0.5, 0.0))
    base_idx = 1

    # Interior rows: left, center, right per row
    row_indices = NTuple{3,Int}[]
    for j in 1:segments
        t = Float64(j) / Float64(segments + 1)
        # Radial distance from center (petal extends outward)
        r = t * length
        # Slight upward curve
        y_offset = 0.1 * length * sin(π * t)
        hw = _petal_width(t)

        # Local coordinates: forward along the rotated radial direction
        # Petal radial direction in XZ plane
        fwd_x = cos_r
        fwd_z = sin_r
        # Perpendicular in XZ plane
        perp_x = -sin_r
        perp_z = cos_r

        center = SVector(r * fwd_x, y_offset, r * fwd_z)
        left = SVector(r * fwd_x - hw * perp_x, y_offset, r * fwd_z - hw * perp_z)
        right = SVector(r * fwd_x + hw * perp_x, y_offset, r * fwd_z + hw * perp_z)

        rot_normal = _rotate_y(up_normal, cos_r, sin_r)

        l_idx = Base.length(vertices) + 1
        push!(vertices, left)
        push!(norms, rot_normal)
        push!(uv_coords, SVector(0.0, t))

        c_idx = Base.length(vertices) + 1
        push!(vertices, center)
        push!(norms, rot_normal)
        push!(uv_coords, SVector(0.5, t))

        r_idx = Base.length(vertices) + 1
        push!(vertices, right)
        push!(norms, rot_normal)
        push!(uv_coords, SVector(1.0, t))

        push!(row_indices, (l_idx, c_idx, r_idx))
    end

    # Tip point
    tip_r = length
    tip_y = 0.1 * length * sin(π)  # ≈ 0
    push!(vertices, SVector(tip_r * cos_r, tip_y, tip_r * sin_r))
    push!(norms, _rotate_y(up_normal, cos_r, sin_r))
    push!(uv_coords, SVector(0.5, 1.0))
    tip_idx = Base.length(vertices)

    # Triangulate: base fan to first row
    if !isempty(row_indices)
        l1, c1, r1 = row_indices[1]
        push!(faces, (base_idx, c1, l1))
        push!(faces, (base_idx, r1, c1))
    end

    # Quads between rows
    for k in 1:(Base.length(row_indices) - 1)
        la, ca, ra = row_indices[k]
        lb, cb, rb = row_indices[k + 1]
        push!(faces, (la, lb, cb))
        push!(faces, (la, cb, ca))
        push!(faces, (ca, cb, rb))
        push!(faces, (ca, rb, ra))
    end

    # Tip fan
    if !isempty(row_indices)
        ll, cl, rl = row_indices[end]
        push!(faces, (ll, tip_idx, cl))
        push!(faces, (cl, tip_idx, rl))
    end

    nv = Base.length(vertices)
    TriangleMesh(vertices, norms, faces, uv_coords, fill(color, nv))
end

"""Rotate a vector around the Y axis."""
function _rotate_y(v::SVector{3,Float64}, cos_r::Float64, sin_r::Float64)
    SVector(
        v[1] * cos_r + v[3] * sin_r,
        v[2],
        -v[1] * sin_r + v[3] * cos_r,
    )
end

# ──────────────────────────────────────────────────────────────────
# flower_mesh
# ──────────────────────────────────────────────────────────────────

"""
    flower_mesh(; petals=5, radius=1.0, segments=4,
                color=SVector(1.0, 0.4, 0.7, 1.0)) -> TriangleMesh

Generate a flower mesh with radially symmetric petals.

Each petal is generated and rotated evenly around the Y axis.

# Arguments
- `petals::Int` — number of petals
- `radius::Float64` — petal length (radial extent)
- `segments::Int` — subdivisions per petal
- `color::SVector{4,Float64}` — petal vertex color

Reference: Prusinkiewicz 1993
"""
function flower_mesh(; petals::Int=5, radius::Float64=1.0, segments::Int=4,
                     color::SVector{4,Float64}=SVector(1.0, 0.4, 0.7, 1.0))
    petal_meshes = TriangleMesh[]
    for i in 0:petals-1
        angle = 2π * i / petals
        pm = petal_mesh(; length=radius, segments=segments, color=color, rotation=angle)
        push!(petal_meshes, pm)
    end
    merge_meshes(petal_meshes)
end
