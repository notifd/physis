"""
Tests for Pipe Model and Tree Topology (Phase 2).

Tests that:
1. build_tree extracts correct parent-child relationships
2. Descendant leaf counts are accurate
3. compute_pipe_radii follows area conservation (r_parent² = Σ r_child²)
4. Trunk is thickest, tips are thinnest
5. segments_to_mesh with radius_mode=:pipe_model produces valid meshes

Reference: Shinozaki et al. 1964
"""

using StaticArrays

@testset "Tree Topology" begin

    @testset "Empty segments" begin
        tree = build_tree(LineSegment3D[])
        @test isempty(tree)
    end

    @testset "Single segment" begin
        seg = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        tree = build_tree([seg])
        @test length(tree) == 1
        @test tree[1].segment_index == 1
        @test isempty(tree[1].children)
        @test tree[1].descendant_leaves == 1  # Leaf node
    end

    @testset "Straight chain" begin
        # Three segments in a line: 0→1→2→3
        seg1 = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        seg2 = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(0.0, 2.0, 0.0), 1.0, 0)
        seg3 = LineSegment3D(SVector(0.0, 2.0, 0.0), SVector(0.0, 3.0, 0.0), 1.0, 0)
        tree = build_tree([seg1, seg2, seg3])

        @test length(tree) == 3
        @test tree[1].children == [2]
        @test tree[2].children == [3]
        @test isempty(tree[3].children)

        # Descendant counts: seg3 = 1 (leaf), seg2 = 1, seg1 = 1
        @test tree[3].descendant_leaves == 1
        @test tree[2].descendant_leaves == 1
        @test tree[1].descendant_leaves == 1
    end

    @testset "Y-branch" begin
        # Trunk (0→1), then two branches (1→left, 1→right)
        trunk = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        left = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(-1.0, 2.0, 0.0), 1.0, 1)
        right = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(1.0, 2.0, 0.0), 1.0, 1)
        tree = build_tree([trunk, left, right])

        @test length(tree) == 3
        @test sort(tree[1].children) == [2, 3]
        @test isempty(tree[2].children)
        @test isempty(tree[3].children)

        # Trunk has 2 descendant leaves
        @test tree[1].descendant_leaves == 2
        @test tree[2].descendant_leaves == 1
        @test tree[3].descendant_leaves == 1
    end

    @testset "Deep tree" begin
        # Trunk → Y-branch → one branch Y-branches again
        trunk = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        b1 = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(-1.0, 2.0, 0.0), 1.0, 1)
        b2 = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(1.0, 2.0, 0.0), 1.0, 1)
        b2a = LineSegment3D(SVector(1.0, 2.0, 0.0), SVector(0.5, 3.0, 0.0), 1.0, 2)
        b2b = LineSegment3D(SVector(1.0, 2.0, 0.0), SVector(1.5, 3.0, 0.0), 1.0, 2)
        tree = build_tree([trunk, b1, b2, b2a, b2b])

        @test tree[1].descendant_leaves == 3  # trunk: 3 leaves total
        @test tree[2].descendant_leaves == 1  # b1: leaf
        @test tree[3].descendant_leaves == 2  # b2: 2 leaves
        @test tree[4].descendant_leaves == 1  # b2a: leaf
        @test tree[5].descendant_leaves == 1  # b2b: leaf
    end

    @testset "Segment indices" begin
        seg = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        tree = build_tree([seg])
        @test tree[1].segment_index == 1
    end
end

@testset "Pipe Model Radii" begin

    @testset "Empty segments" begin
        radii = compute_pipe_radii(LineSegment3D[], 0.1)
        @test isempty(radii)
    end

    @testset "Single segment" begin
        seg = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        radii = compute_pipe_radii([seg], 0.1)
        @test length(radii) == 1
        @test radii[1] ≈ 0.1  # sqrt(1/1) * 0.1
    end

    @testset "Y-branch area conservation" begin
        trunk = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        left = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(-1.0, 2.0, 0.0), 1.0, 1)
        right = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(1.0, 2.0, 0.0), 1.0, 1)
        radii = compute_pipe_radii([trunk, left, right], 0.1)

        # r_parent² ≈ r_left² + r_right² (area conservation)
        @test radii[1]^2 ≈ radii[2]^2 + radii[3]^2
        # Trunk is thickest
        @test radii[1] > radii[2]
        @test radii[1] > radii[3]
    end

    @testset "Trunk thickest, tips thinnest" begin
        trunk = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        b1 = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(-1.0, 2.0, 0.0), 1.0, 1)
        b2 = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(1.0, 2.0, 0.0), 1.0, 1)
        b2a = LineSegment3D(SVector(1.0, 2.0, 0.0), SVector(0.5, 3.0, 0.0), 1.0, 2)
        b2b = LineSegment3D(SVector(1.0, 2.0, 0.0), SVector(1.5, 3.0, 0.0), 1.0, 2)

        radii = compute_pipe_radii([trunk, b1, b2, b2a, b2b], 0.1)

        # Trunk is thickest
        @test radii[1] == maximum(radii)
        # Tips are thinnest
        @test radii[4] == minimum(radii)
        @test radii[5] == minimum(radii)
        # b2 (2 descendant leaves) thicker than b1 (1 leaf)
        @test radii[3] > radii[2]
    end

    @testset "Straight chain has constant radius" begin
        seg1 = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        seg2 = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(0.0, 2.0, 0.0), 1.0, 0)
        seg3 = LineSegment3D(SVector(0.0, 2.0, 0.0), SVector(0.0, 3.0, 0.0), 1.0, 0)
        radii = compute_pipe_radii([seg1, seg2, seg3], 0.1)

        # All segments have 1 descendant leaf, so equal radii
        @test all(r ≈ 0.1 for r in radii)
    end
end

@testset "segments_to_mesh with pipe model" begin

    @testset "Fixed mode (default) unchanged" begin
        segs = [
            LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0),
            LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(0.0, 2.0, 0.0), 1.0, 0),
        ]
        mesh_fixed = segments_to_mesh(segs; base_radius=0.1, taper=0.7, segments=8)
        mesh_default = segments_to_mesh(segs; base_radius=0.1, taper=0.7, segments=8, radius_mode=:fixed)

        @test length(mesh_fixed.vertices) == length(mesh_default.vertices)
        @test mesh_fixed.vertices == mesh_default.vertices
    end

    @testset "Pipe model mode produces valid mesh" begin
        trunk = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0)
        left = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(-1.0, 2.0, 0.0), 1.0, 1)
        right = LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(1.0, 2.0, 0.0), 1.0, 1)

        mesh = segments_to_mesh([trunk, left, right]; base_radius=0.1, segments=8,
                                radius_mode=:pipe_model)
        @test !isempty(mesh.vertices)
        @test !isempty(mesh.faces)
        @test !isempty(mesh.normals)

        # All face indices valid
        nv = length(mesh.vertices)
        for (a, b, c) in mesh.faces
            @test 1 <= a <= nv
            @test 1 <= b <= nv
            @test 1 <= c <= nv
        end
    end
end
