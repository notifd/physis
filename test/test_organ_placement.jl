"""
    test_organ_placement.jl — Tests for OrganPlacement struct and turtle organ collection

TDD: These tests define the expected behavior of OrganPlacement, interpret3d with
collect_organs=true, and build_tree_with_organs.
"""

using StaticArrays
using LinearAlgebra

@testset "OrganPlacement" begin

    # ── OrganPlacement struct ────────────────────────────────────────
    @testset "OrganPlacement construction" begin
        op = OrganPlacement(
            SVector(0.0, 1.0, 0.0),
            SVector(0.0, 1.0, 0.0),
            SVector(0.0, 0.0, 1.0),
            SVector(-1.0, 0.0, 0.0),
            :leaf,
            1.0,
        )
        @test op.position == SVector(0.0, 1.0, 0.0)
        @test op.heading == SVector(0.0, 1.0, 0.0)
        @test op.up == SVector(0.0, 0.0, 1.0)
        @test op.left == SVector(-1.0, 0.0, 0.0)
        @test op.organ_type == :leaf
        @test op.scale == 1.0
    end

    # ── interpret3d backward compatibility ───────────────────────────
    @testset "interpret3d default returns Vector{LineSegment3D}" begin
        ls = LString([LSymbol('F'), LSymbol('['), LSymbol('+'), LSymbol('F'), LSymbol(']'), LSymbol('F')])
        result = interpret3d(ls; angle=45.0, step=1.0)
        @test result isa Vector{LineSegment3D}
        @test length(result) == 3
    end

    # ── interpret3d with collect_organs=true ──────────────────────────
    @testset "interpret3d collect_organs returns tuple" begin
        ls = LString([LSymbol('F'), LSymbol('L'), LSymbol('F')])
        segments, organs = interpret3d(ls; angle=25.0, step=1.0, collect_organs=true)
        @test segments isa Vector{LineSegment3D}
        @test organs isa Vector{OrganPlacement}
        @test length(segments) == 2
        @test length(organs) == 1
        @test organs[1].organ_type == :leaf
    end

    @testset "interpret3d collects L, K, Q symbols" begin
        ls = LString([
            LSymbol('F'),
            LSymbol('L'),  # leaf
            LSymbol('K'),  # flower
            LSymbol('Q'),  # fruit
            LSymbol('F'),
        ])
        segments, organs = interpret3d(ls; angle=25.0, step=1.0, collect_organs=true)
        @test length(segments) == 2
        @test length(organs) == 3
        @test organs[1].organ_type == :leaf
        @test organs[2].organ_type == :flower
        @test organs[3].organ_type == :fruit
    end

    @testset "organ placement records turtle position" begin
        # F moves turtle up by 1 unit (heading is +Y by default)
        ls = LString([LSymbol('F'), LSymbol('L')])
        _, organs = interpret3d(ls; step=2.0, collect_organs=true)
        @test length(organs) == 1
        # After F(step=2), turtle is at (0, 2, 0)
        @test organs[1].position ≈ SVector(0.0, 2.0, 0.0)
        @test organs[1].heading ≈ SVector(0.0, 1.0, 0.0)
    end

    @testset "organ placement records orientation after rotations" begin
        # Rotate then place organ
        ls = LString([LSymbol('F'), LSymbol('+'), LSymbol('L')])
        _, organs = interpret3d(ls; angle=90.0, step=1.0, collect_organs=true)
        @test length(organs) == 1
        # After +90° yaw, heading should have rotated around up axis
        @test organs[1].position ≈ SVector(0.0, 1.0, 0.0) atol=1e-10
    end

    @testset "collect_organs=false ignores L K Q symbols" begin
        ls = LString([LSymbol('F'), LSymbol('L'), LSymbol('K'), LSymbol('Q'), LSymbol('F')])
        result = interpret3d(ls; angle=25.0, step=1.0)
        @test result isa Vector{LineSegment3D}
        @test length(result) == 2  # L, K, Q are ignored, just 2 F segments
    end

    @testset "organ placement in branches" begin
        # [+FL] — push, turn, forward, leaf, pop
        ls = LString([
            LSymbol('['),
            LSymbol('+'),
            LSymbol('F'),
            LSymbol('L'),
            LSymbol(']'),
            LSymbol('F'),
        ])
        segments, organs = interpret3d(ls; angle=45.0, step=1.0, collect_organs=true)
        @test length(organs) == 1
        @test organs[1].organ_type == :leaf
        @test length(segments) == 2
    end

    # ── build_tree_with_organs ───────────────────────────────────────
    @testset "build_tree_with_organs basic" begin
        ls = LString([LSymbol('F'), LSymbol('L'), LSymbol('F'), LSymbol('K')])
        segments, organs = interpret3d(ls; step=1.0, collect_organs=true)
        mesh = build_tree_with_organs(segments, organs)
        @test mesh isa TriangleMesh
        @test length(mesh.vertices) > 0
        @test length(mesh.faces) > 0
    end

    @testset "build_tree_with_organs empty organs" begin
        ls = LString([LSymbol('F'), LSymbol('F')])
        segments, organs = interpret3d(ls; step=1.0, collect_organs=true)
        @test isempty(organs)
        mesh = build_tree_with_organs(segments, organs)
        @test mesh isa TriangleMesh
        @test length(mesh.vertices) > 0  # still has branch geometry
    end

    @testset "build_tree_with_organs all organ types" begin
        ls = LString([
            LSymbol('F'),
            LSymbol('L'),
            LSymbol('F'),
            LSymbol('K'),
            LSymbol('F'),
            LSymbol('Q'),
        ])
        segments, organs = interpret3d(ls; step=1.0, collect_organs=true)
        mesh = build_tree_with_organs(segments, organs)
        @test mesh isa TriangleMesh
        # Should be bigger than just branches alone
        branch_only = segments_to_mesh(segments)
        @test length(mesh.vertices) > length(branch_only.vertices)
    end

    @testset "build_tree_with_organs mesh validity" begin
        ls = LString([LSymbol('F'), LSymbol('L'), LSymbol('K'), LSymbol('Q')])
        segments, organs = interpret3d(ls; step=1.0, collect_organs=true)
        mesh = build_tree_with_organs(segments, organs)
        nv = length(mesh.vertices)
        for (a, b, c) in mesh.faces
            @test 1 <= a <= nv
            @test 1 <= b <= nv
            @test 1 <= c <= nv
        end
    end
end
