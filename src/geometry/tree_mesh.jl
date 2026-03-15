"""
    tree_mesh.jl — Convert L-system line segments to 3D meshes

Combines cylinder meshes from individual segments into a unified tree mesh.
"""

# ──────────────────────────────────────────────────────────────────
# merge_meshes
# ──────────────────────────────────────────────────────────────────

"""
    merge_meshes(meshes::Vector{TriangleMesh}) -> TriangleMesh

Combine multiple meshes into a single mesh. Face indices are offset
so they reference the correct vertices in the combined vertex array.
"""
function merge_meshes(meshes::Vector{TriangleMesh})
    isempty(meshes) && return TriangleMesh(
        SVector{3,Float64}[],
        SVector{3,Float64}[],
        NTuple{3,Int}[],
        SVector{2,Float64}[],
        SVector{4,Float64}[],
    )

    total_verts = sum(length(m.vertices) for m in meshes)
    total_faces = sum(length(m.faces) for m in meshes)

    all_verts = Vector{SVector{3,Float64}}(undef, total_verts)
    all_normals = Vector{SVector{3,Float64}}(undef, total_verts)
    all_uvs = Vector{SVector{2,Float64}}(undef, total_verts)
    all_colors = Vector{SVector{4,Float64}}(undef, total_verts)
    all_faces = Vector{NTuple{3,Int}}(undef, total_faces)

    vert_offset = 0
    face_offset = 0

    for m in meshes
        nv = length(m.vertices)
        nf = length(m.faces)

        copyto!(all_verts, vert_offset + 1, m.vertices, 1, nv)
        copyto!(all_normals, vert_offset + 1, m.normals, 1, nv)
        copyto!(all_uvs, vert_offset + 1, m.uvs, 1, nv)

        # Copy colors if present, else fill white
        if !isempty(m.colors)
            copyto!(all_colors, vert_offset + 1, m.colors, 1, nv)
        else
            fill!(view(all_colors, vert_offset+1:vert_offset+nv), SVector(1.0, 1.0, 1.0, 1.0))
        end

        for i in 1:nf
            a, b, c = m.faces[i]
            all_faces[face_offset + i] = (a + vert_offset, b + vert_offset, c + vert_offset)
        end

        vert_offset += nv
        face_offset += nf
    end

    TriangleMesh(all_verts, all_normals, all_faces, all_uvs, all_colors)
end

# ──────────────────────────────────────────────────────────────────
# segments_to_mesh
# ──────────────────────────────────────────────────────────────────

"""
    segments_to_mesh(segments::Vector{LineSegment3D};
                     base_radius=0.1, taper=0.7, segments=8,
                     radius_mode=:fixed) -> TriangleMesh

Convert 3D line segments into a unified triangle mesh by generating
a cylinder (truncated cone) for each segment.

# Arguments
- `base_radius::Float64=0.1` — base cylinder radius, scaled by segment width
- `taper::Float64=0.7` — ratio of end radius to start radius
- `segments::Int=8` — number of radial subdivisions per cylinder
- `radius_mode::Symbol=:fixed` — `:fixed` (default, width-based) or `:pipe_model`
  (biologically realistic radii from descendant leaf count)

Reference: Shinozaki et al. 1964 (pipe model)
"""
function segments_to_mesh(
    segs::Vector{LineSegment3D};
    base_radius::Float64=0.1,
    taper::Float64=0.7,
    segments::Int=8,
    radius_mode::Symbol=:fixed
)
    isempty(segs) && return merge_meshes(TriangleMesh[])

    meshes = TriangleMesh[]
    sizehint!(meshes, length(segs))

    # Compute max depth for normalization
    max_depth = maximum(seg.depth for seg in segs; init=0)
    norm_denom = max_depth > 0 ? Float64(max_depth) : 1.0

    # Compute per-segment radii based on radius_mode
    pipe_radii = radius_mode == :pipe_model ? compute_pipe_radii(segs, base_radius) : nothing

    for (idx, seg) in enumerate(segs)
        if pipe_radii !== nothing
            r_start = pipe_radii[idx]
        else
            r_start = base_radius * seg.width
        end
        r_end = r_start * taper

        # Encode normalized depth in vertex color R channel
        norm_depth = Float64(seg.depth) / norm_denom
        seg_color = SVector(norm_depth, 1.0, 0.0, 1.0)
        m = cylinder_mesh(seg.start, seg.stop, r_start, r_end;
                          segments=segments, color=seg_color)
        if !isempty(m.vertices)
            push!(meshes, m)
        end
    end

    merge_meshes(meshes)
end

# ──────────────────────────────────────────────────────────────────
# build_tree_with_organs
# ──────────────────────────────────────────────────────────────────

"""
    build_tree_with_organs(segments::Vector{LineSegment3D}, organs::Vector{OrganPlacement};
                           base_radius=0.1, taper=0.7, mesh_segments=8,
                           leaf_shape=:elliptic, leaf_scale=1.0,
                           flower_petals=5, flower_scale=1.0,
                           fruit_scale=1.0) -> TriangleMesh

Build a tree mesh from segments and organ placements, merging branch cylinders
with leaf/flower/fruit meshes at their recorded positions.

# Arguments
- `base_radius`, `taper`, `mesh_segments` — passed to `segments_to_mesh`
- `leaf_shape` — shape parameter for `leaf_mesh`
- `leaf_scale`, `flower_scale`, `fruit_scale` — scale factors for organ meshes
- `flower_petals` — number of petals for flower organs
"""
function build_tree_with_organs(
    segments::Vector{LineSegment3D},
    organs::Vector{OrganPlacement};
    base_radius::Float64=0.1,
    taper::Float64=0.7,
    mesh_segments::Int=8,
    leaf_shape::Symbol=:elliptic,
    leaf_scale::Float64=1.0,
    flower_petals::Int=5,
    flower_scale::Float64=1.0,
    fruit_scale::Float64=1.0,
)
    all_meshes = TriangleMesh[]

    # Branch geometry
    if !isempty(segments)
        branch_mesh = segments_to_mesh(segments; base_radius=base_radius, taper=taper, segments=mesh_segments)
        if !isempty(branch_mesh.vertices)
            push!(all_meshes, branch_mesh)
        end
    end

    # Organ geometry
    for organ in organs
        local organ_mesh::TriangleMesh
        s = organ.scale
        if organ.organ_type == :leaf
            organ_mesh = leaf_mesh(; shape=leaf_shape, width=0.3 * s * leaf_scale,
                                   length=1.0 * s * leaf_scale)
        elseif organ.organ_type == :flower
            organ_mesh = flower_mesh(; petals=flower_petals, radius=0.5 * s * flower_scale)
        elseif organ.organ_type == :fruit
            organ_mesh = sphere_mesh(0.2 * s * fruit_scale)
        else
            continue
        end

        # Transform organ mesh to organ position/orientation
        transformed = _transform_mesh(organ_mesh, organ.position, organ.heading, organ.up, organ.left)
        if !isempty(transformed.vertices)
            push!(all_meshes, transformed)
        end
    end

    merge_meshes(all_meshes)
end

"""
    _transform_mesh(mesh, position, heading, up, left) -> TriangleMesh

Transform a mesh from local coordinates to world coordinates using the given
coordinate frame. The local Z axis maps to heading, local Y to up, local X to left.
"""
function _transform_mesh(mesh::TriangleMesh,
                         position::SVector{3,Float64},
                         heading::SVector{3,Float64},
                         up::SVector{3,Float64},
                         left::SVector{3,Float64})
    isempty(mesh.vertices) && return mesh

    new_verts = similar(mesh.vertices)
    new_normals = similar(mesh.normals)

    for i in eachindex(mesh.vertices)
        v = mesh.vertices[i]
        # v[1] = local X (width) -> left direction
        # v[2] = local Y (normal up) -> up direction
        # v[3] = local Z (forward/length) -> heading direction
        new_verts[i] = position + v[1] * left + v[2] * up + v[3] * heading
    end

    for i in eachindex(mesh.normals)
        n = mesh.normals[i]
        transformed_n = n[1] * left + n[2] * up + n[3] * heading
        len = norm(transformed_n)
        new_normals[i] = len > 1e-14 ? transformed_n / len : up
    end

    TriangleMesh(new_verts, new_normals, mesh.faces, mesh.uvs, mesh.colors)
end
