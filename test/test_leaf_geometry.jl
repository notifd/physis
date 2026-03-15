"""
    test_leaf_geometry.jl — Tests for leaf mesh generation

TDD: These tests define the expected behavior of leaf_mesh().
"""

using StaticArrays
using LinearAlgebra

@testset "Leaf Geometry" begin

    # ── Helper: validate a TriangleMesh ──────────────────────────────
    function validate_mesh(mesh::TriangleMesh; min_verts=3, min_faces=1)
        @test length(mesh.vertices) >= min_verts
        @test length(mesh.normals) == length(mesh.vertices)
        @test length(mesh.uvs) == length(mesh.vertices)
        @test length(mesh.faces) >= min_faces

        # All face indices must be in [1, nv]
        nv = length(mesh.vertices)
        for (a, b, c) in mesh.faces
            @test 1 <= a <= nv
            @test 1 <= b <= nv
            @test 1 <= c <= nv
        end

        # All normals must be unit vectors
        for n in mesh.normals
            @test norm(n) ≈ 1.0 atol=1e-10
        end
    end

    # ── Elliptic leaf (default) ──────────────────────────────────────
    @testset "elliptic leaf (default)" begin
        mesh = leaf_mesh()
        validate_mesh(mesh)

        # Default shape is elliptic
        mesh2 = leaf_mesh(; shape=:elliptic)
        @test length(mesh.vertices) == length(mesh2.vertices)
        @test length(mesh.faces) == length(mesh2.faces)
    end

    # ── Lanceolate leaf ──────────────────────────────────────────────
    @testset "lanceolate leaf" begin
        mesh = leaf_mesh(; shape=:lanceolate)
        validate_mesh(mesh)

        # Lanceolate should be narrower than elliptic at midpoint
        ell = leaf_mesh(; shape=:elliptic, width=1.0, length=1.0, segments=6)
        lan = leaf_mesh(; shape=:lanceolate, width=1.0, length=1.0, segments=6)
        # Same vertex count for same segments
        @test length(ell.vertices) == length(lan.vertices)
    end

    # ── Cordate leaf ─────────────────────────────────────────────────
    @testset "cordate leaf" begin
        mesh = leaf_mesh(; shape=:cordate)
        validate_mesh(mesh)
    end

    # ── Needle leaf ──────────────────────────────────────────────────
    @testset "needle leaf" begin
        mesh = leaf_mesh(; shape=:needle)
        validate_mesh(mesh)

        # Needle leaf should be very narrow compared to elliptic
        ell = leaf_mesh(; shape=:elliptic, width=1.0, length=1.0, segments=6)
        ndl = leaf_mesh(; shape=:needle, width=1.0, length=1.0, segments=6)

        # Compute max X extent for each
        ell_max_x = maximum(abs(v[1]) for v in ell.vertices)
        ndl_max_x = maximum(abs(v[1]) for v in ndl.vertices)
        @test ndl_max_x < ell_max_x * 0.5  # needle is at least 2x narrower
    end

    # ── Vertex count based on segments parameter ─────────────────────
    @testset "vertex count scales with segments" begin
        m4 = leaf_mesh(; segments=4)
        m8 = leaf_mesh(; segments=8)
        @test length(m8.vertices) > length(m4.vertices)
    end

    # ── All normals are unit vectors ─────────────────────────────────
    @testset "normals are unit vectors for all shapes" begin
        for shape in [:elliptic, :lanceolate, :cordate, :needle]
            mesh = leaf_mesh(; shape=shape)
            for n in mesh.normals
                @test norm(n) ≈ 1.0 atol=1e-10
            end
        end
    end

    # ── Face indices are valid ───────────────────────────────────────
    @testset "face indices are valid for all shapes" begin
        for shape in [:elliptic, :lanceolate, :cordate, :needle]
            mesh = leaf_mesh(; shape=shape, segments=10)
            nv = length(mesh.vertices)
            for (a, b, c) in mesh.faces
                @test 1 <= a <= nv
                @test 1 <= b <= nv
                @test 1 <= c <= nv
            end
        end
    end

    # ── Width and length parameters scale correctly ──────────────────
    @testset "width and length scaling" begin
        small = leaf_mesh(; width=0.5, length=1.0, segments=6)
        large = leaf_mesh(; width=1.0, length=2.0, segments=6)

        # Large leaf should span more in X (width) direction
        small_max_x = maximum(abs(v[1]) for v in small.vertices)
        large_max_x = maximum(abs(v[1]) for v in large.vertices)
        @test large_max_x > small_max_x

        # Large leaf should span more in Z (length) direction
        small_max_z = maximum(v[3] for v in small.vertices)
        large_max_z = maximum(v[3] for v in large.vertices)
        @test large_max_z > small_max_z
    end

    # ── Default parameters produce reasonable mesh ───────────────────
    @testset "default parameters are reasonable" begin
        mesh = leaf_mesh()
        # Should have more than just a triangle
        @test length(mesh.vertices) >= 6
        @test length(mesh.faces) >= 4

        # Leaf lies primarily in XZ plane (normals should point in Y direction)
        avg_normal = sum(mesh.normals) / length(mesh.normals)
        @test abs(avg_normal[2]) > 0.5  # Y component dominates

        # Colors should be present
        @test length(mesh.colors) == length(mesh.vertices)
    end

    # ── Color parameter ──────────────────────────────────────────────
    @testset "custom color" begin
        color = SVector(1.0, 0.0, 0.0, 1.0)
        mesh = leaf_mesh(; color=color)
        @test all(c == color for c in mesh.colors)
    end

    # ── Leaf is in XZ plane, extends along Z ─────────────────────────
    @testset "leaf geometry orientation" begin
        mesh = leaf_mesh(; length=2.0, segments=6)
        # Leaf should extend along Z (forward direction)
        z_extent = maximum(v[3] for v in mesh.vertices) - minimum(v[3] for v in mesh.vertices)
        @test z_extent ≈ 2.0 atol=0.1
        # Base should be near z=0
        @test minimum(v[3] for v in mesh.vertices) ≈ 0.0 atol=0.01
    end
end
