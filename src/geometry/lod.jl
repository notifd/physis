"""
    lod.jl — Level of Detail mesh generation

Generates progressively simplified meshes by reducing radial subdivisions
and pruning branches beyond a depth threshold.

Reference: Deussen et al. 2002, "Interactive Visualization of Complex Plant Ecosystems"
"""

"""
    generate_lod(segments::Vector{LineSegment3D}; levels=3,
                 base_radius=0.1, taper=0.7, base_segments=8) -> Vector{TriangleMesh}

Generate `levels` meshes at decreasing levels of detail.

LOD 0 (index 1) is full detail. Each subsequent level:
1. Reduces radial cylinder subdivisions (segments)
2. Prunes branches beyond a depth threshold

# Arguments
- `segments` — input line segments with depth information
- `levels::Int=3` — number of LOD levels to generate
- `base_radius`, `taper` — passed to `segments_to_mesh`
- `base_segments::Int=8` — radial segments at full detail

# Returns
Vector of `TriangleMesh`, from highest to lowest detail.

Reference: Deussen et al. 2002
"""
function generate_lod(segments::Vector{LineSegment3D};
                      levels::Int=3,
                      base_radius::Float64=0.1,
                      taper::Float64=0.7,
                      base_segments::Int=8)
    levels >= 1 || throw(ArgumentError("levels must be >= 1, got $levels"))

    if isempty(segments)
        return [segments_to_mesh(segments; base_radius=base_radius, taper=taper,
                                 segments=base_segments) for _ in 1:levels]
    end

    max_depth = maximum(seg.depth for seg in segments)
    meshes = TriangleMesh[]

    for lod in 0:levels-1
        # Reduce radial segments: full at LOD 0, minimum 3 at highest LOD
        lod_segments = max(3, base_segments - lod * max(1, base_segments ÷ levels))

        # Prune branches: at LOD 0 keep all, at highest LOD keep only trunk
        if levels > 1
            max_allowed_depth = max_depth - round(Int, lod * max_depth / (levels - 1))
        else
            max_allowed_depth = max_depth
        end
        max_allowed_depth = max(0, max_allowed_depth)

        # Filter segments by depth
        filtered = filter(s -> s.depth <= max_allowed_depth, segments)

        if isempty(filtered)
            # If all pruned, keep at least trunk segments
            filtered = filter(s -> s.depth == 0, segments)
        end

        mesh = segments_to_mesh(filtered; base_radius=base_radius, taper=taper,
                                segments=lod_segments)
        push!(meshes, mesh)
    end

    meshes
end
