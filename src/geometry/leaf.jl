"""
    leaf.jl — Leaf mesh generation for L-system plant organs

Generates flat leaf meshes in various shapes using parametric profiles.
The leaf lies in the XZ plane with length along Z (forward direction),
width along X, and normals pointing in Y.

Reference: ABOP §2.5 "Predefined surfaces"
"""

using StaticArrays
using LinearAlgebra

# ──────────────────────────────────────────────────────────────────
# Leaf profile functions
# ──────────────────────────────────────────────────────────────────

"""Half-width profile for elliptic leaf shape."""
_leaf_profile_elliptic(t::Float64, width::Float64) = width * sin(π * t)

"""Half-width profile for lanceolate (narrow, pointed) leaf shape."""
_leaf_profile_lanceolate(t::Float64, width::Float64) = width * sin(π * t) * (1 - t)^0.3

"""Half-width profile for cordate (heart-shaped) leaf shape."""
_leaf_profile_cordate(t::Float64, width::Float64) = width * sin(π * t) * (1 + 0.3 * cos(2π * t))

"""Half-width profile for needle (very narrow conifer) leaf shape."""
_leaf_profile_needle(t::Float64, width::Float64) = width * 0.1 * sin(π * t)

const _LEAF_PROFILES = Dict{Symbol, Function}(
    :elliptic => _leaf_profile_elliptic,
    :lanceolate => _leaf_profile_lanceolate,
    :cordate => _leaf_profile_cordate,
    :needle => _leaf_profile_needle,
)

# ──────────────────────────────────────────────────────────────────
# leaf_mesh
# ──────────────────────────────────────────────────────────────────

"""
    leaf_mesh(; shape=:elliptic, width=0.3, length=1.0, segments=6,
              color=SVector(0.2, 0.8, 0.1, 1.0)) -> TriangleMesh

Generate a flat leaf mesh in the XZ plane.

The leaf base is at the origin, extending along +Z for `length` units.
Width is along X. Normals point in +Y direction.

# Shapes
- `:elliptic` — standard oval leaf (default)
- `:lanceolate` — narrow, pointed leaf
- `:cordate` — heart-shaped leaf
- `:needle` — very narrow conifer needle

# Arguments
- `shape::Symbol` — leaf profile shape
- `width::Float64` — maximum half-width of leaf
- `length::Float64` — length of leaf along Z
- `segments::Int` — number of subdivisions along length
- `color::SVector{4,Float64}` — vertex color

Reference: ABOP §2.5
"""
function leaf_mesh(; shape::Symbol=:elliptic, width::Float64=0.3,
                   length::Float64=1.0, segments::Int=6,
                   color::SVector{4,Float64}=SVector(0.2, 0.8, 0.1, 1.0))
    profile = get(_LEAF_PROFILES, shape) do
        throw(ArgumentError("unknown leaf shape: $shape. Valid: $(keys(_LEAF_PROFILES))"))
    end

    up_normal = SVector(0.0, 1.0, 0.0)

    # Vertices: base tip + segments of (left, center, right) + top tip
    # Total vertices = 1 (base) + 3*segments (interior rows) + 1 (tip)
    # But we skip degenerate rows at t=0 and t=1 where width=0
    #
    # Layout: center spine vertices + left/right edge vertices
    # For each interior segment i (1..segments-1): left, center, right
    # Plus base point (t=0) and tip point (t=1)

    n_interior = segments - 1  # interior rows (excluding base and tip)
    n_verts = 2 + 3 * n_interior  # base + tip + 3 per interior row

    vertices = Vector{SVector{3,Float64}}(undef, n_verts)
    normals = Vector{SVector{3,Float64}}(undef, n_verts)
    uvs = Vector{SVector{2,Float64}}(undef, n_verts)
    colors = fill(color, n_verts)
    faces = NTuple{3,Int}[]

    # Index 1: base point (t=0)
    vertices[1] = SVector(0.0, 0.0, 0.0)
    normals[1] = up_normal
    uvs[1] = SVector(0.5, 0.0)

    # Index 2: tip point (t=1)
    vertices[2] = SVector(0.0, 0.0, length)
    normals[2] = up_normal
    uvs[2] = SVector(0.5, 1.0)

    # Interior rows: indices 3..n_verts
    # For row i (0-indexed from 0 to n_interior-1):
    #   left  = index 3 + 3*i
    #   center = index 3 + 3*i + 1
    #   right = index 3 + 3*i + 2
    # Wait, let's use 1-indexed consistently:
    #   row j (1-based, j=1..n_interior)
    #   left  = 2 + 3*(j-1) + 1 = 3j
    #   center = 3j + 1
    #   right = 3j + 2
    # Hmm, let me just use a simpler scheme.

    # Re-index: base=1, then for each interior row j=1..n_interior:
    #   left  = 1 + 3*(j-1) + 1 = 3j - 1
    #   center = 3j
    #   right  = 3j + 1
    # tip = n_verts = 2 + 3*n_interior

    for j in 1:n_interior
        t = Float64(j) / Float64(segments)
        z = t * length
        hw = profile(t, width)  # half-width

        left_idx = 3 * (j - 1) + 2   # = 3j - 1
        center_idx = 3 * (j - 1) + 3  # = 3j
        right_idx = 3 * (j - 1) + 4   # = 3j + 1

        vertices[left_idx] = SVector(-hw, 0.0, z)
        vertices[center_idx] = SVector(0.0, 0.0, z)
        vertices[right_idx] = SVector(hw, 0.0, z)

        normals[left_idx] = up_normal
        normals[center_idx] = up_normal
        normals[right_idx] = up_normal

        uvs[left_idx] = SVector(0.5 - hw / (2 * max(width, 1e-10)), t)
        uvs[center_idx] = SVector(0.5, t)
        uvs[right_idx] = SVector(0.5 + hw / (2 * max(width, 1e-10)), t)
    end

    # Tip index
    tip_idx = 2 + 3 * n_interior + 1
    # Wait, recalculate. We have:
    #   index 1: base
    #   indices 2..1+3*n_interior: interior (3 per row, n_interior rows)
    #   index 2+3*n_interior: tip
    # Let me redo the indexing more carefully.

    # Actually let me just rebuild with clean indexing.
    vertices2 = SVector{3,Float64}[]
    normals2 = SVector{3,Float64}[]
    uvs2 = SVector{2,Float64}[]

    # Base point
    push!(vertices2, SVector(0.0, 0.0, 0.0))
    push!(normals2, up_normal)
    push!(uvs2, SVector(0.5, 0.0))
    base_idx = 1

    # Interior rows
    row_indices = Vector{NTuple{3,Int}}()  # (left, center, right) per row
    for j in 1:n_interior
        t = Float64(j) / Float64(segments)
        z = t * length
        hw = profile(t, width)

        left_i = Base.length(vertices2) + 1
        push!(vertices2, SVector(-hw, 0.0, z))
        push!(normals2, up_normal)
        push!(uvs2, SVector(0.5 - hw / (2 * max(width, 1e-10)), t))

        center_i = Base.length(vertices2) + 1
        push!(vertices2, SVector(0.0, 0.0, z))
        push!(normals2, up_normal)
        push!(uvs2, SVector(0.5, t))

        right_i = Base.length(vertices2) + 1
        push!(vertices2, SVector(hw, 0.0, z))
        push!(normals2, up_normal)
        push!(uvs2, SVector(0.5 + hw / (2 * max(width, 1e-10)), t))

        push!(row_indices, (left_i, center_i, right_i))
    end

    # Tip point
    push!(vertices2, SVector(0.0, 0.0, length))
    push!(normals2, up_normal)
    push!(uvs2, SVector(0.5, 1.0))
    tip_idx_val = Base.length(vertices2)

    # Triangulate: base fan to first row
    if !isempty(row_indices)
        l1, c1, r1 = row_indices[1]
        push!(faces, (base_idx, c1, l1))
        push!(faces, (base_idx, r1, c1))
    end

    # Quads between consecutive rows (each row has left, center, right)
    for k in 1:(Base.length(row_indices) - 1)
        la, ca, ra = row_indices[k]
        lb, cb, rb = row_indices[k + 1]

        # Left half: la-ca to lb-cb (2 triangles)
        push!(faces, (la, lb, cb))
        push!(faces, (la, cb, ca))

        # Right half: ca-ra to cb-rb (2 triangles)
        push!(faces, (ca, cb, rb))
        push!(faces, (ca, rb, ra))
    end

    # Tip fan from last row
    if !isempty(row_indices)
        ll, cl, rl = row_indices[end]
        push!(faces, (ll, tip_idx_val, cl))
        push!(faces, (cl, tip_idx_val, rl))
    end

    nv = Base.length(vertices2)
    TriangleMesh(vertices2, normals2, faces, uvs2, fill(color, nv))
end
