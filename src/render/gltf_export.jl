"""
    gltf_export.jl — Export TriangleMesh to glTF 2.0 binary format (.glb)

Pure Julia implementation of GLB (binary glTF) export. Produces files
viewable in any 3D viewer: browsers (three.js), Blender, VS Code, etc.

Reference: glTF 2.0 specification (https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html)
"""

using JSON3
using StaticArrays

# ──────────────────────────────────────────────────────────────────
# GLB constants
# ──────────────────────────────────────────────────────────────────

const GLB_MAGIC = UInt32(0x46546C67)     # "glTF"
const GLB_VERSION = UInt32(2)
const GLB_JSON_CHUNK = UInt32(0x4E4F534A) # "JSON"
const GLB_BIN_CHUNK = UInt32(0x004E4942)  # "BIN\0"

# ──────────────────────────────────────────────────────────────────
# export_glb
# ──────────────────────────────────────────────────────────────────

"""
    export_glb(path, mesh::TriangleMesh; color=(0.45, 0.32, 0.18)) -> String

Export a TriangleMesh to a binary glTF 2.0 (.glb) file.

Returns the output file path.

Throws `ArgumentError` if the mesh is empty.

# Arguments
- `path::String` — output file path
- `mesh::TriangleMesh` — the mesh to export
- `color::NTuple{3,Float64}` — base color RGB (0–1 range)
"""
function export_glb(
    path::String,
    mesh::TriangleMesh;
    color::Tuple{Real,Real,Real}=(0.45, 0.32, 0.18)
)
    isempty(mesh.vertices) && throw(ArgumentError("cannot export empty mesh to GLB"))

    # ── Build binary buffer ──────────────────────────────────────
    n_verts = length(mesh.vertices)
    n_faces = length(mesh.faces)

    # Binary data layout:
    # [positions: n_verts×3×Float32] [normals: n_verts×3×Float32] [indices: n_faces×3×UInt32]
    pos_bytes = n_verts * 3 * 4   # Float32
    norm_bytes = n_verts * 3 * 4  # Float32
    idx_bytes = n_faces * 3 * 4   # UInt32

    bin_data = Vector{UInt8}(undef, pos_bytes + norm_bytes + idx_bytes)

    # Write positions
    pos_min = SVector(Inf, Inf, Inf)
    pos_max = SVector(-Inf, -Inf, -Inf)
    offset = 0
    for v in mesh.vertices
        for j in 1:3
            val = Float32(v[j])
            copyto!(bin_data, offset + 1, reinterpret(UInt8, [val]), 1, 4)
            offset += 4
        end
        pos_min = min.(pos_min, v)
        pos_max = max.(pos_max, v)
    end

    # Write normals
    for n in mesh.normals
        for j in 1:3
            val = Float32(n[j])
            copyto!(bin_data, offset + 1, reinterpret(UInt8, [val]), 1, 4)
            offset += 4
        end
    end

    # Write indices (0-based)
    idx_min = typemax(UInt32)
    idx_max = UInt32(0)
    for (a, b, c) in mesh.faces
        for idx in (a, b, c)
            val = UInt32(idx - 1)  # Convert 1-based to 0-based
            copyto!(bin_data, offset + 1, reinterpret(UInt8, [val]), 1, 4)
            offset += 4
            idx_min = min(idx_min, val)
            idx_max = max(idx_max, val)
        end
    end

    # ── Build JSON chunk ─────────────────────────────────────────
    json_obj = Dict{String, Any}(
        "asset" => Dict("version" => "2.0", "generator" => "Physis.jl"),
        "scene" => 0,
        "scenes" => [Dict("nodes" => [0])],
        "nodes" => [Dict("mesh" => 0)],
        "meshes" => [Dict(
            "primitives" => [Dict(
                "attributes" => Dict(
                    "POSITION" => 0,
                    "NORMAL" => 1,
                ),
                "indices" => 2,
                "material" => 0,
            )],
        )],
        "materials" => [Dict(
            "pbrMetallicRoughness" => Dict(
                "baseColorFactor" => [Float64(color[1]), Float64(color[2]), Float64(color[3]), 1.0],
                "metallicFactor" => 0.1,
                "roughnessFactor" => 0.8,
            ),
        )],
        "accessors" => [
            # 0: positions
            Dict(
                "bufferView" => 0,
                "componentType" => 5126,  # FLOAT
                "count" => n_verts,
                "type" => "VEC3",
                "min" => [Float32(pos_min[1]), Float32(pos_min[2]), Float32(pos_min[3])],
                "max" => [Float32(pos_max[1]), Float32(pos_max[2]), Float32(pos_max[3])],
            ),
            # 1: normals
            Dict(
                "bufferView" => 1,
                "componentType" => 5126,  # FLOAT
                "count" => n_verts,
                "type" => "VEC3",
            ),
            # 2: indices
            Dict(
                "bufferView" => 2,
                "componentType" => 5125,  # UNSIGNED_INT
                "count" => n_faces * 3,
                "type" => "SCALAR",
                "min" => [idx_min],
                "max" => [idx_max],
            ),
        ],
        "bufferViews" => [
            # 0: positions
            Dict(
                "buffer" => 0,
                "byteOffset" => 0,
                "byteLength" => pos_bytes,
                "target" => 34962,  # ARRAY_BUFFER
            ),
            # 1: normals
            Dict(
                "buffer" => 0,
                "byteOffset" => pos_bytes,
                "byteLength" => norm_bytes,
                "target" => 34962,  # ARRAY_BUFFER
            ),
            # 2: indices
            Dict(
                "buffer" => 0,
                "byteOffset" => pos_bytes + norm_bytes,
                "byteLength" => idx_bytes,
                "target" => 34963,  # ELEMENT_ARRAY_BUFFER
            ),
        ],
        "buffers" => [Dict("byteLength" => length(bin_data))],
    )

    json_str = JSON3.write(json_obj)
    # Pad JSON to 4-byte alignment
    json_bytes = Vector{UInt8}(json_str)
    while length(json_bytes) % 4 != 0
        push!(json_bytes, 0x20)  # space padding
    end

    # Pad binary to 4-byte alignment
    while length(bin_data) % 4 != 0
        push!(bin_data, 0x00)
    end

    # ── Write GLB file ───────────────────────────────────────────
    total_length = 12 +                          # GLB header
                   8 + length(json_bytes) +       # JSON chunk
                   8 + length(bin_data)            # BIN chunk

    open(path, "w") do io
        # GLB header (12 bytes)
        write(io, GLB_MAGIC)
        write(io, GLB_VERSION)
        write(io, UInt32(total_length))

        # JSON chunk
        write(io, UInt32(length(json_bytes)))
        write(io, GLB_JSON_CHUNK)
        write(io, json_bytes)

        # BIN chunk
        write(io, UInt32(length(bin_data)))
        write(io, GLB_BIN_CHUNK)
        write(io, bin_data)
    end

    path
end
