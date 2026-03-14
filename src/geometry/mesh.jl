"""
    mesh.jl — Triangle mesh type for 3D geometry

A simple indexed triangle mesh with vertices, normals, faces, and UV coordinates.

Reference: Standard polygon mesh representation
"""

using StaticArrays

# ──────────────────────────────────────────────────────────────────
# TriangleMesh
# ──────────────────────────────────────────────────────────────────

"""
    TriangleMesh

An indexed triangle mesh with per-vertex normals, UV coordinates, and vertex colors.

# Fields
- `vertices::Vector{SVector{3, Float64}}` — vertex positions
- `normals::Vector{SVector{3, Float64}}` — per-vertex normals
- `faces::Vector{NTuple{3, Int}}` — triangle face indices (1-based)
- `uvs::Vector{SVector{2, Float64}}` — per-vertex UV coordinates
- `colors::Vector{SVector{4, Float64}}` — per-vertex RGBA colors
"""
struct TriangleMesh
    vertices::Vector{SVector{3, Float64}}
    normals::Vector{SVector{3, Float64}}
    faces::Vector{NTuple{3, Int}}
    uvs::Vector{SVector{2, Float64}}
    colors::Vector{SVector{4, Float64}}
end

# Backward-compatible 4-arg constructor (colors default to empty)
TriangleMesh(
    vertices::Vector{SVector{3, Float64}},
    normals::Vector{SVector{3, Float64}},
    faces::Vector{NTuple{3, Int}},
    uvs::Vector{SVector{2, Float64}},
) = TriangleMesh(vertices, normals, faces, uvs, SVector{4, Float64}[])
