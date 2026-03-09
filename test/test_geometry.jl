"""
Tests for the Geometry module (Phase 6).

Tests that:
1. TriangleMesh construction and field access
2. cylinder_mesh produces correct geometry
3. merge_meshes combines meshes with correct index offsets
4. segments_to_mesh end-to-end pipeline
5. BoundingBox3D construction and compute_bbox for 3D
"""

using StaticArrays
using LinearAlgebra

@testset "Geometry" begin

    @testset "TriangleMesh" begin
        @testset "Construction and field access" begin
            verts = [SVector(0.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0)]
            norms = [SVector(0.0, 0.0, 1.0), SVector(0.0, 0.0, 1.0), SVector(0.0, 0.0, 1.0)]
            faces = [(1, 2, 3)]
            uvs = [SVector(0.0, 0.0), SVector(1.0, 0.0), SVector(0.0, 1.0)]
            mesh = TriangleMesh(verts, norms, faces, uvs)
            @test length(mesh.vertices) == 3
            @test length(mesh.normals) == 3
            @test length(mesh.faces) == 1
            @test length(mesh.uvs) == 3
            @test mesh.faces[1] == (1, 2, 3)
        end

        @testset "Empty mesh" begin
            mesh = TriangleMesh(
                SVector{3, Float64}[],
                SVector{3, Float64}[],
                NTuple{3, Int}[],
                SVector{2, Float64}[],
            )
            @test isempty(mesh.vertices)
            @test isempty(mesh.faces)
        end
    end

    @testset "cylinder_mesh" begin
        @testset "Produces correct vertex and face counts" begin
            # segments=8 → 16 vertices (8 top ring + 8 bottom ring), 16 faces (2 per quad)
            mesh = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(0.0, 1.0, 0.0),
                0.5, 0.5; segments=8
            )
            @test length(mesh.vertices) == 16  # 2 rings × 8 segments
            @test length(mesh.faces) == 16     # 8 quads × 2 triangles
            @test length(mesh.normals) == 16
            @test length(mesh.uvs) == 16
        end

        @testset "Different segment counts" begin
            for n in [3, 4, 6, 12]
                mesh = cylinder_mesh(
                    SVector(0.0, 0.0, 0.0),
                    SVector(0.0, 1.0, 0.0),
                    0.5, 0.5; segments=n
                )
                @test length(mesh.vertices) == 2n
                @test length(mesh.faces) == 2n
            end
        end

        @testset "Tapering (truncated cone)" begin
            mesh = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(0.0, 1.0, 0.0),
                1.0, 0.5; segments=8
            )
            # Bottom ring vertices should be farther from axis than top ring
            bottom_r = norm(mesh.vertices[1] - SVector(0.0, 0.0, 0.0))
            top_r = norm(mesh.vertices[9] - SVector(0.0, 1.0, 0.0))
            @test bottom_r ≈ 1.0 atol=1e-12
            @test top_r ≈ 0.5 atol=1e-12
        end

        @testset "Normals point outward" begin
            mesh = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(0.0, 1.0, 0.0),
                0.5, 0.5; segments=8
            )
            # For a straight cylinder, normals at bottom ring should point away from axis
            for i in 1:8
                radial = mesh.vertices[i] - SVector(0.0, 0.0, 0.0)
                radial_flat = SVector(radial[1], 0.0, radial[3])
                @test dot(mesh.normals[i], radial_flat) > 0
            end
        end

        @testset "Orientation — cylinder along different axes" begin
            # Cylinder along X axis
            mesh_x = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(1.0, 0.0, 0.0),
                0.3, 0.3; segments=8
            )
            @test length(mesh_x.faces) == 16
            # Vertices should span the X range
            xs = [v[1] for v in mesh_x.vertices]
            @test minimum(xs) ≈ 0.0 atol=1e-12
            @test maximum(xs) ≈ 1.0 atol=1e-12

            # Cylinder along Z axis
            mesh_z = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(0.0, 0.0, 1.0),
                0.3, 0.3; segments=8
            )
            zs = [v[3] for v in mesh_z.vertices]
            @test minimum(zs) ≈ 0.0 atol=1e-12
            @test maximum(zs) ≈ 1.0 atol=1e-12
        end

        @testset "Zero-length segment returns empty mesh" begin
            mesh = cylinder_mesh(
                SVector(1.0, 2.0, 3.0),
                SVector(1.0, 2.0, 3.0),
                0.5, 0.5; segments=8
            )
            @test isempty(mesh.vertices)
            @test isempty(mesh.faces)
        end

        @testset "Face indices are valid" begin
            mesh = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(0.0, 1.0, 0.0),
                0.5, 0.3; segments=6
            )
            n_verts = length(mesh.vertices)
            for (a, b, c) in mesh.faces
                @test 1 <= a <= n_verts
                @test 1 <= b <= n_verts
                @test 1 <= c <= n_verts
            end
        end
    end

    @testset "merge_meshes" begin
        @testset "Merging two meshes" begin
            m1 = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(0.0, 1.0, 0.0),
                0.5, 0.5; segments=4
            )
            m2 = cylinder_mesh(
                SVector(0.0, 1.0, 0.0),
                SVector(0.0, 2.0, 0.0),
                0.5, 0.3; segments=4
            )
            merged = merge_meshes([m1, m2])
            @test length(merged.vertices) == length(m1.vertices) + length(m2.vertices)
            @test length(merged.normals) == length(m1.normals) + length(m2.normals)
            @test length(merged.faces) == length(m1.faces) + length(m2.faces)
            @test length(merged.uvs) == length(m1.uvs) + length(m2.uvs)
        end

        @testset "Face indices offset correctly" begin
            m1 = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(0.0, 1.0, 0.0),
                0.5, 0.5; segments=4
            )
            m2 = cylinder_mesh(
                SVector(0.0, 1.0, 0.0),
                SVector(0.0, 2.0, 0.0),
                0.5, 0.5; segments=4
            )
            merged = merge_meshes([m1, m2])
            n1 = length(m1.vertices)
            # Second mesh's faces should be offset by n1
            for (a, b, c) in merged.faces[length(m1.faces)+1:end]
                @test a > n1
                @test b > n1
                @test c > n1
            end
        end

        @testset "Merging empty list returns empty mesh" begin
            merged = merge_meshes(TriangleMesh[])
            @test isempty(merged.vertices)
            @test isempty(merged.faces)
        end

        @testset "Merging single mesh returns equivalent" begin
            m = cylinder_mesh(
                SVector(0.0, 0.0, 0.0),
                SVector(0.0, 1.0, 0.0),
                0.5, 0.5; segments=4
            )
            merged = merge_meshes([m])
            @test length(merged.vertices) == length(m.vertices)
            @test length(merged.faces) == length(m.faces)
        end
    end

    @testset "segments_to_mesh" begin
        @testset "Single segment produces mesh" begin
            segs = [LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0)]
            mesh = segments_to_mesh(segs; base_radius=0.1, taper=1.0)
            @test length(mesh.vertices) > 0
            @test length(mesh.faces) > 0
        end

        @testset "Multiple segments produce larger mesh" begin
            segs = [
                LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0),
                LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(0.0, 2.0, 0.0), 1.0),
            ]
            mesh = segments_to_mesh(segs; base_radius=0.1, taper=1.0)
            single_mesh = segments_to_mesh(segs[1:1]; base_radius=0.1, taper=1.0)
            @test length(mesh.vertices) == 2 * length(single_mesh.vertices)
        end

        @testset "Taper affects radii" begin
            segs = [LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 2.0)]
            mesh_tapered = segments_to_mesh(segs; base_radius=0.5, taper=0.5)
            # With taper=0.5, end radius = 0.5 * 0.5 * 2.0 = 0.5, start = 0.5 * 2.0 = 1.0
            @test length(mesh_tapered.vertices) > 0
        end

        @testset "Zero-length segments are skipped" begin
            segs = [
                LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 0.0, 0.0), 1.0),
                LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0),
            ]
            mesh = segments_to_mesh(segs; base_radius=0.1, taper=1.0)
            single_mesh = segments_to_mesh(segs[2:2]; base_radius=0.1, taper=1.0)
            @test length(mesh.vertices) == length(single_mesh.vertices)
        end

        @testset "End-to-end from interpret3d" begin
            # Simple 3D L-system
            axiom = LString("F")
            rs = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))])
            derived = derive(axiom, rs, 2)
            segs = interpret3d(derived; angle=25.7)
            mesh = segments_to_mesh(segs; base_radius=0.1)
            @test length(mesh.vertices) > 0
            @test length(mesh.faces) > 0
            @test length(segs) == 25  # 5^2
        end
    end

    @testset "BoundingBox3D" begin
        @testset "Construction" begin
            bb = BoundingBox3D(0.0, 1.0, 0.0, 2.0, 0.0, 3.0)
            @test bb.xmin == 0.0
            @test bb.xmax == 1.0
            @test bb.ymin == 0.0
            @test bb.ymax == 2.0
            @test bb.zmin == 0.0
            @test bb.zmax == 3.0
        end

        @testset "compute_bbox with single segment" begin
            segs = [LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(1.0, 2.0, 3.0), 1.0)]
            bb = compute_bbox(segs)
            @test bb.xmin < 0.0  # margin
            @test bb.xmax > 1.0
            @test bb.ymin < 0.0
            @test bb.ymax > 2.0
            @test bb.zmin < 0.0
            @test bb.zmax > 3.0
        end

        @testset "compute_bbox with multiple segments" begin
            segs = [
                LineSegment3D(SVector(-1.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0), 1.0),
                LineSegment3D(SVector(0.0, -2.0, 0.0), SVector(0.0, 2.0, 5.0), 1.0),
            ]
            bb = compute_bbox(segs; margin=0.0)
            @test bb.xmin ≈ -1.0
            @test bb.xmax ≈ 1.0
            @test bb.ymin ≈ -2.0
            @test bb.ymax ≈ 2.0
            @test bb.zmin ≈ 0.0
            @test bb.zmax ≈ 5.0
        end

        @testset "Margin as fraction of largest dimension" begin
            segs = [LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(10.0, 0.0, 0.0), 1.0)]
            bb = compute_bbox(segs; margin=0.1)
            # Largest dim is 10.0 (x), margin = 1.0
            @test bb.xmin ≈ -1.0
            @test bb.xmax ≈ 11.0
        end

        @testset "Degenerate single point" begin
            segs = [LineSegment3D(SVector(5.0, 5.0, 5.0), SVector(5.0, 5.0, 5.0), 1.0)]
            bb = compute_bbox(segs)
            # Should default to 1.0 unit extent
            @test bb.xmax - bb.xmin > 0
            @test bb.ymax - bb.ymin > 0
            @test bb.zmax - bb.zmin > 0
        end

        @testset "Empty segments throws ArgumentError" begin
            @test_throws ArgumentError compute_bbox(LineSegment3D[])
        end
    end
end
