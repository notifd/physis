"""
    bbox3d.jl — 3D bounding box computation

Axis-aligned bounding box for 3D line segments, analogous to BoundingBox2D
in render_api.jl.
"""

# ──────────────────────────────────────────────────────────────────
# BoundingBox3D
# ──────────────────────────────────────────────────────────────────

"""
    BoundingBox3D(xmin, xmax, ymin, ymax, zmin, zmax)

Axis-aligned bounding box for 3D geometry.
"""
struct BoundingBox3D
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    zmin::Float64
    zmax::Float64
end

# ──────────────────────────────────────────────────────────────────
# compute_bbox for 3D segments
# ──────────────────────────────────────────────────────────────────

"""
    compute_bbox(segments::Vector{LineSegment3D}; margin=0.1) -> BoundingBox3D

Compute the axis-aligned bounding box of a collection of 3D line segments,
with an optional margin expressed as a fraction of the largest dimension.

Degenerate cases (zero extent in all dimensions) default to a 1.0 unit extent.

Throws `ArgumentError` if `segments` is empty.
"""
function compute_bbox(segments::Vector{LineSegment3D}; margin::Real=0.1)
    isempty(segments) && throw(ArgumentError("cannot compute bounding box of empty segment list"))

    xmin = Inf
    xmax = -Inf
    ymin = Inf
    ymax = -Inf
    zmin = Inf
    zmax = -Inf

    for seg in segments
        xmin = min(xmin, seg.start[1], seg.stop[1])
        xmax = max(xmax, seg.start[1], seg.stop[1])
        ymin = min(ymin, seg.start[2], seg.stop[2])
        ymax = max(ymax, seg.start[2], seg.stop[2])
        zmin = min(zmin, seg.start[3], seg.stop[3])
        zmax = max(zmax, seg.start[3], seg.stop[3])
    end

    width = xmax - xmin
    height = ymax - ymin
    depth = zmax - zmin

    # Degenerate: single point → default to 1.0 unit extent
    if width == 0.0 && height == 0.0 && depth == 0.0
        cx = (xmin + xmax) / 2
        cy = (ymin + ymax) / 2
        cz = (zmin + zmax) / 2
        xmin = cx - 0.5
        xmax = cx + 0.5
        ymin = cy - 0.5
        ymax = cy + 0.5
        zmin = cz - 0.5
        zmax = cz + 0.5
        width = 1.0
        height = 1.0
        depth = 1.0
    end

    larger_dim = max(width, height, depth)
    pad = Float64(margin) * larger_dim
    BoundingBox3D(xmin - pad, xmax + pad, ymin - pad, ymax + pad, zmin - pad, zmax + pad)
end
