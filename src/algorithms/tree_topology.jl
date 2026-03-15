"""
    tree_topology.jl — Extract tree structure from L-system line segments

Builds parent-child relationships from the line segments produced by the 3D turtle,
using positional matching to identify branching points.

Reference: Shinozaki et al. 1964 "A quantitative analysis of plant form — the pipe model theory"
"""

using StaticArrays

# ──────────────────────────────────────────────────────────────────
# TreeNode
# ──────────────────────────────────────────────────────────────────

"""
    TreeNode

A node in the tree topology graph. Each node corresponds to one line segment.

# Fields
- `segment_index::Int` — index into the original segment vector
- `children::Vector{Int}` — indices of child TreeNodes in the tree
- `descendant_leaves::Int` — number of terminal descendants (leaves)
"""
struct TreeNode
    segment_index::Int
    children::Vector{Int}
    descendant_leaves::Int
end

# ──────────────────────────────────────────────────────────────────
# build_tree
# ──────────────────────────────────────────────────────────────────

"""
    build_tree(segments::Vector{LineSegment3D}) -> Vector{TreeNode}

Build a tree topology from line segments. Segment `j` is a child of
segment `i` when `segments[j].start ≈ segments[i].stop`.

Descendant leaf counts are computed bottom-up: a leaf node (no children)
counts as 1, and each parent sums its children's counts.

Reference: Shinozaki et al. 1964
"""
function build_tree(segments::Vector{LineSegment3D})
    n = length(segments)
    n == 0 && return TreeNode[]

    # Build adjacency: segment j is child of segment i if j.start ≈ i.stop
    children = [Int[] for _ in 1:n]
    is_child = falses(n)

    # Index segments by stop position for faster lookup
    for j in 1:n
        for i in 1:n
            i == j && continue
            if isapprox(segments[j].start, segments[i].stop; atol=1e-10)
                push!(children[i], j)
                is_child[j] = true
                break  # Each segment has at most one parent
            end
        end
    end

    # Compute descendant leaf counts bottom-up via topological sort
    descendant_count = zeros(Int, n)

    # Find processing order: leaves first, then parents
    # Use iterative post-order traversal
    processed = falses(n)

    function count_descendants(idx::Int)
        processed[idx] && return descendant_count[idx]
        if isempty(children[idx])
            descendant_count[idx] = 1  # Leaf node
        else
            total = 0
            for child in children[idx]
                total += count_descendants(child)
            end
            descendant_count[idx] = total
        end
        processed[idx] = true
        descendant_count[idx]
    end

    for i in 1:n
        count_descendants(i)
    end

    [TreeNode(i, children[i], descendant_count[i]) for i in 1:n]
end
