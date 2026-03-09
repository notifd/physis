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

An indexed triangle mesh with per-vertex normals and UV coordinates.

# Fields
- `vertices::Vector{SVector{3, Float64}}` — vertex positions
- `normals::Vector{SVector{3, Float64}}` — per-vertex normals
- `faces::Vector{NTuple{3, Int}}` — triangle face indices (1-based)
- `uvs::Vector{SVector{2, Float64}}` — per-vertex UV coordinates
"""
struct TriangleMesh
    vertices::Vector{SVector{3, Float64}}
    normals::Vector{SVector{3, Float64}}
    faces::Vector{NTuple{3, Int}}
    uvs::Vector{SVector{2, Float64}}
end
