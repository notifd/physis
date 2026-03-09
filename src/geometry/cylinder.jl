"""
    cylinder.jl — Cylinder mesh generation for L-system branch segments

Generates truncated cone meshes (cylinders with different start/end radii)
to represent branch segments in 3D L-system visualizations.
"""

using StaticArrays
using LinearAlgebra

# ──────────────────────────────────────────────────────────────────
# cylinder_mesh
# ──────────────────────────────────────────────────────────────────

"""
    cylinder_mesh(start, stop, radius_start, radius_end; segments=8) -> TriangleMesh

Generate a truncated cone (cylinder) mesh between two 3D points.

Returns an empty mesh if the segment has zero length.

# Arguments
- `start::SVector{3,Float64}` — center of the bottom ring
- `stop::SVector{3,Float64}` — center of the top ring
- `radius_start::Float64` — radius at `start`
- `radius_end::Float64` — radius at `stop`
- `segments::Int=8` — number of radial subdivisions
"""
function cylinder_mesh(
    start::SVector{3,Float64},
    stop::SVector{3,Float64},
    radius_start::Float64,
    radius_end::Float64;
    segments::Int=8
)
    axis = stop - start
    len = norm(axis)

    # Degenerate: zero-length segment
    if len < 1e-14
        return TriangleMesh(
            SVector{3,Float64}[],
            SVector{3,Float64}[],
            NTuple{3,Int}[],
            SVector{2,Float64}[],
        )
    end

    dir = axis / len

    # Build a local coordinate frame perpendicular to the cylinder axis
    # Choose a reference vector not parallel to dir
    ref = abs(dot(dir, SVector(1.0, 0.0, 0.0))) < 0.9 ?
          SVector(1.0, 0.0, 0.0) : SVector(0.0, 1.0, 0.0)
    tangent = normalize(cross(dir, ref))
    bitangent = cross(dir, tangent)

    n_verts = 2 * segments
    vertices = Vector{SVector{3,Float64}}(undef, n_verts)
    normals = Vector{SVector{3,Float64}}(undef, n_verts)
    uvs = Vector{SVector{2,Float64}}(undef, n_verts)
    faces = Vector{NTuple{3,Int}}(undef, 2 * segments)

    # Slope angle for normal calculation (truncated cone)
    dr = radius_start - radius_end
    slope_len = sqrt(len^2 + dr^2)
    cos_slope = len / slope_len
    sin_slope = dr / slope_len

    for i in 0:segments-1
        θ = 2π * i / segments
        cosθ = cos(θ)
        sinθ = sin(θ)

        # Radial direction in the perpendicular plane
        radial = cosθ * tangent + sinθ * bitangent

        # Bottom ring vertex (index i+1)
        vertices[i+1] = start + radius_start * radial
        # Top ring vertex (index segments+i+1)
        vertices[segments+i+1] = stop + radius_end * radial

        # Normal: outward radial, adjusted for cone slope
        n = cos_slope * radial + sin_slope * dir
        normals[i+1] = n
        normals[segments+i+1] = n

        # UV coordinates
        u = Float64(i) / segments
        uvs[i+1] = SVector(u, 0.0)
        uvs[segments+i+1] = SVector(u, 1.0)

        # Face indices (two triangles per quad)
        i0 = i + 1           # bottom current
        i1 = (i + 1) % segments + 1  # bottom next
        i2 = segments + i + 1        # top current
        i3 = segments + (i + 1) % segments + 1  # top next

        faces[2i+1] = (i0, i1, i2)
        faces[2i+2] = (i1, i3, i2)
    end

    TriangleMesh(vertices, normals, faces, uvs)
end
