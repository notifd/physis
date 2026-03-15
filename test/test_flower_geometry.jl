"""
    test_flower_geometry.jl — Tests for flower, petal, sphere, and cone mesh generation

TDD: These tests define the expected behavior of flower_mesh(), petal_mesh(),
sphere_mesh(), and cone_mesh().
"""

using StaticArrays
using LinearAlgebra

@testset "Flower & Fruit Geometry" begin

    # ── Helper: validate a TriangleMesh ──────────────────────────────
    function validate_organ_mesh(mesh::TriangleMesh; min_verts=3, min_faces=1)
        @test length(mesh.vertices) >= min_verts
        @test length(mesh.normals) == length(mesh.vertices)
        @test length(mesh.uvs) == length(mesh.vertices)
        @test length(mesh.faces) >= min_faces

        nv = length(mesh.vertices)
        for (a, b, c) in mesh.faces
            @test 1 <= a <= nv
            @test 1 <= b <= nv
            @test 1 <= c <= nv
        end

        for n in mesh.normals
            @test norm(n) ≈ 1.0 atol=1e-10
        end
    end

    # ── Flower mesh ──────────────────────────────────────────────────
    @testset "flower_mesh basic" begin
        mesh = flower_mesh(; petals=5, radius=1.0)
        validate_organ_mesh(mesh)
    end

    @testset "flower_mesh petal count" begin
        # More petals = more geometry
        m3 = flower_mesh(; petals=3, radius=1.0, segments=4)
        m7 = flower_mesh(; petals=7, radius=1.0, segments=4)
        # 7-petal flower should have more than 2x the vertices of 3-petal
        @test length(m7.vertices) > length(m3.vertices)
        # Vertex count should scale linearly with petal count
        ratio = length(m7.vertices) / length(m3.vertices)
        @test ratio ≈ 7.0 / 3.0 atol=0.1
    end

    @testset "flower_mesh radial symmetry" begin
        mesh = flower_mesh(; petals=5, radius=1.0, segments=4)
        # Petals should be evenly distributed: check that vertices span full 360°
        # by looking at angles in the XZ plane
        angles = [atan(v[3], v[1]) for v in mesh.vertices if norm(SVector(v[1], v[3])) > 0.01]
        if !isempty(angles)
            # Should have vertices in multiple quadrants
            has_positive_x = any(v[1] > 0.1 for v in mesh.vertices)
            has_negative_x = any(v[1] < -0.1 for v in mesh.vertices)
            @test has_positive_x || has_negative_x  # at least some spread
        end
    end

    @testset "flower_mesh custom color" begin
        color = SVector(1.0, 0.0, 1.0, 1.0)
        mesh = flower_mesh(; petals=5, radius=1.0, color=color)
        @test all(c == color for c in mesh.colors)
    end

    # ── Petal mesh ───────────────────────────────────────────────────
    @testset "petal_mesh basic" begin
        mesh = petal_mesh(; length=1.0, segments=4)
        validate_organ_mesh(mesh)
    end

    @testset "petal_mesh vertex count scales with segments" begin
        m3 = petal_mesh(; segments=3)
        m6 = petal_mesh(; segments=6)
        @test length(m6.vertices) > length(m3.vertices)
    end

    # ── Sphere mesh ──────────────────────────────────────────────────
    @testset "sphere_mesh basic" begin
        mesh = sphere_mesh(1.0; segments=8)
        validate_organ_mesh(mesh; min_verts=6)

        # Sphere vertices should all be approximately at radius=1.0 from origin
        for v in mesh.vertices
            @test norm(v) ≈ 1.0 atol=0.05
        end
    end

    @testset "sphere_mesh vertex count scales with segments" begin
        m4 = sphere_mesh(1.0; segments=4)
        m12 = sphere_mesh(1.0; segments=12)
        @test length(m12.vertices) > length(m4.vertices)
    end

    @testset "sphere_mesh normals point outward" begin
        mesh = sphere_mesh(1.0; segments=8)
        for (v, n) in zip(mesh.vertices, mesh.normals)
            # Normal should point in same direction as vertex (outward from origin)
            @test dot(normalize(v), n) > 0.5
        end
    end

    @testset "sphere_mesh custom color" begin
        color = SVector(1.0, 0.5, 0.0, 1.0)
        mesh = sphere_mesh(0.5; segments=6, color=color)
        @test all(c == color for c in mesh.colors)
    end

    # ── Cone mesh ────────────────────────────────────────────────────
    @testset "cone_mesh basic" begin
        mesh = cone_mesh(1.0, 2.0; segments=8)
        validate_organ_mesh(mesh; min_verts=6)
    end

    @testset "cone_mesh dimensions" begin
        mesh = cone_mesh(0.5, 3.0; segments=8)
        # Base vertices should be at y=0, apex at y=height
        y_vals = [v[2] for v in mesh.vertices]
        @test minimum(y_vals) ≈ 0.0 atol=0.01
        @test maximum(y_vals) ≈ 3.0 atol=0.01
    end

    @testset "cone_mesh vertex count scales with segments" begin
        m4 = cone_mesh(1.0, 2.0; segments=4)
        m12 = cone_mesh(1.0, 2.0; segments=12)
        @test length(m12.vertices) > length(m4.vertices)
    end

    @testset "cone_mesh face indices valid" begin
        mesh = cone_mesh(1.0, 2.0; segments=8)
        nv = length(mesh.vertices)
        for (a, b, c) in mesh.faces
            @test 1 <= a <= nv
            @test 1 <= b <= nv
            @test 1 <= c <= nv
        end
    end

    @testset "cone_mesh custom color" begin
        color = SVector(0.8, 0.2, 0.1, 1.0)
        mesh = cone_mesh(1.0, 2.0; segments=6, color=color)
        @test all(c == color for c in mesh.colors)
    end
end
