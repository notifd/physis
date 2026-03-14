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
                     base_radius=0.1, taper=0.7, segments=8) -> TriangleMesh

Convert 3D line segments into a unified triangle mesh by generating
a cylinder (truncated cone) for each segment.

# Arguments
- `base_radius::Float64=0.1` — base cylinder radius, scaled by segment width
- `taper::Float64=0.7` — ratio of end radius to start radius
- `segments::Int=8` — number of radial subdivisions per cylinder
"""
function segments_to_mesh(
    segs::Vector{LineSegment3D};
    base_radius::Float64=0.1,
    taper::Float64=0.7,
    segments::Int=8
)
    meshes = TriangleMesh[]
    sizehint!(meshes, length(segs))

    # Compute max depth for normalization
    max_depth = maximum(seg.depth for seg in segs; init=0)
    norm_denom = max_depth > 0 ? Float64(max_depth) : 1.0

    for seg in segs
        r_start = base_radius * seg.width
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
