"""
    fruit.jl — Sphere and cone mesh generation for L-system fruit organs

Provides basic geometric primitives used for fruit representation.

Reference: Bloomenthal 1985
"""

using StaticArrays
using LinearAlgebra

# ──────────────────────────────────────────────────────────────────
# sphere_mesh
# ──────────────────────────────────────────────────────────────────

"""
    sphere_mesh(radius; segments=8, color=SVector(0.8, 0.1, 0.1, 1.0)) -> TriangleMesh

Generate a UV sphere mesh centered at the origin.

# Arguments
- `radius::Float64` — sphere radius
- `segments::Int` — number of radial and vertical subdivisions
- `color::SVector{4,Float64}` — vertex color
"""
function sphere_mesh(radius::Float64; segments::Int=8,
                     color::SVector{4,Float64}=SVector(0.8, 0.1, 0.1, 1.0))
    rings = segments  # number of latitude rings (excluding poles)
    slices = segments  # number of longitude slices

    vertices = SVector{3,Float64}[]
    norms = SVector{3,Float64}[]
    uv_coords = SVector{2,Float64}[]
    faces = NTuple{3,Int}[]

    # Bottom pole
    push!(vertices, SVector(0.0, -radius, 0.0))
    push!(norms, SVector(0.0, -1.0, 0.0))
    push!(uv_coords, SVector(0.5, 0.0))

    # Latitude rings
    for i in 1:rings-1
        phi = π * i / rings  # from 0 (top) to π (bottom), but we go bottom to top
        # Actually: i=1 is near bottom pole, i=rings-1 is near top pole
        y = -radius * cos(phi)
        r = radius * sin(phi)

        for j in 0:slices-1
            theta = 2π * j / slices
            x = r * cos(theta)
            z = r * sin(theta)

            pos = SVector(x, y, z)
            push!(vertices, pos)
            push!(norms, normalize(pos))
            push!(uv_coords, SVector(Float64(j) / slices, Float64(i) / rings))
        end
    end

    # Top pole
    push!(vertices, SVector(0.0, radius, 0.0))
    push!(norms, SVector(0.0, 1.0, 0.0))
    push!(uv_coords, SVector(0.5, 1.0))
    top_pole_idx = Base.length(vertices)

    # Faces: bottom pole fan
    for j in 0:slices-1
        j_next = (j + 1) % slices
        push!(faces, (1, 2 + j, 2 + j_next))
    end

    # Faces: quads between rings
    for i in 0:rings-3
        for j in 0:slices-1
            j_next = (j + 1) % slices
            # Current ring row start index: 2 + i*slices
            # Next ring row start index: 2 + (i+1)*slices
            a = 2 + i * slices + j
            b = 2 + i * slices + j_next
            c = 2 + (i + 1) * slices + j
            d = 2 + (i + 1) * slices + j_next

            push!(faces, (a, c, d))
            push!(faces, (a, d, b))
        end
    end

    # Faces: top pole fan
    last_ring_start = 2 + (rings - 2) * slices
    for j in 0:slices-1
        j_next = (j + 1) % slices
        push!(faces, (last_ring_start + j, top_pole_idx, last_ring_start + j_next))
    end

    nv = Base.length(vertices)
    TriangleMesh(vertices, norms, faces, uv_coords, fill(color, nv))
end

# ──────────────────────────────────────────────────────────────────
# cone_mesh
# ──────────────────────────────────────────────────────────────────

"""
    cone_mesh(radius, height; segments=8, color=SVector(0.6, 0.8, 0.2, 1.0)) -> TriangleMesh

Generate a cone mesh with base centered at origin in the XZ plane,
apex at (0, height, 0).

# Arguments
- `radius::Float64` — base radius
- `height::Float64` — cone height along Y axis
- `segments::Int` — number of radial subdivisions
- `color::SVector{4,Float64}` — vertex color
"""
function cone_mesh(radius::Float64, height::Float64; segments::Int=8,
                   color::SVector{4,Float64}=SVector(0.6, 0.8, 0.2, 1.0))
    vertices = SVector{3,Float64}[]
    norms = SVector{3,Float64}[]
    uv_coords = SVector{2,Float64}[]
    faces = NTuple{3,Int}[]

    # Slope angle for normals
    slope = atan(radius, height)
    cos_slope = cos(slope)
    sin_slope = sin(slope)

    # Base center (for bottom cap, not strictly needed but helps normals)
    # We'll create base ring + apex

    # Base ring vertices
    for i in 0:segments-1
        theta = 2π * i / segments
        x = radius * cos(theta)
        z = radius * sin(theta)
        push!(vertices, SVector(x, 0.0, z))

        # Outward-and-upward normal for cone surface
        radial = SVector(cos(theta), 0.0, sin(theta))
        n = normalize(SVector(cos_slope * radial[1], sin_slope, cos_slope * radial[3]))
        push!(norms, n)
        push!(uv_coords, SVector(Float64(i) / segments, 0.0))
    end

    # Apex vertex
    push!(vertices, SVector(0.0, height, 0.0))
    push!(norms, SVector(0.0, 1.0, 0.0))
    push!(uv_coords, SVector(0.5, 1.0))
    apex_idx = Base.length(vertices)

    # Side faces: fan from apex
    for i in 0:segments-1
        i_next = (i + 1) % segments
        push!(faces, (i + 1, i_next + 1, apex_idx))
    end

    # Base cap: fan from center
    push!(vertices, SVector(0.0, 0.0, 0.0))
    push!(norms, SVector(0.0, -1.0, 0.0))
    push!(uv_coords, SVector(0.5, 0.0))
    center_idx = Base.length(vertices)

    for i in 0:segments-1
        i_next = (i + 1) % segments
        push!(faces, (center_idx, i_next + 1, i + 1))
    end

    nv = Base.length(vertices)
    TriangleMesh(vertices, norms, faces, uv_coords, fill(color, nv))
end
