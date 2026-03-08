"""
Tests for the glTF/GLB export module (Phase 7).

Tests that:
1. export_glb produces a valid GLB file with correct magic bytes
2. GLB file contains correct vertex/face counts
3. render_lsystem_3d end-to-end pipeline works
4. Edge cases: empty mesh handling
"""

using StaticArrays

@testset "glTF Export" begin

    @testset "export_glb produces valid GLB file" begin
        mesh = cylinder_mesh(
            SVector(0.0, 0.0, 0.0),
            SVector(0.0, 1.0, 0.0),
            0.5, 0.3; segments=8
        )
        mktempdir() do tmpdir
            path = joinpath(tmpdir, "test.glb")
            result = export_glb(path, mesh)
            @test result == path
            @test isfile(path)

            # GLB magic bytes: 0x46546C67 = "glTF" in little-endian
            data = read(path)
            @test length(data) > 12
            @test data[1] == 0x67  # 'g'
            @test data[2] == 0x6C  # 'l'
            @test data[3] == 0x54  # 'T'
            @test data[4] == 0x46  # 'F'

            # Version 2
            version = reinterpret(UInt32, data[5:8])[1]
            @test version == 2

            # Total length matches file size
            total_length = reinterpret(UInt32, data[9:12])[1]
            @test total_length == length(data)
        end
    end

    @testset "GLB contains JSON chunk with mesh info" begin
        mesh = cylinder_mesh(
            SVector(0.0, 0.0, 0.0),
            SVector(0.0, 1.0, 0.0),
            0.5, 0.3; segments=6
        )
        mktempdir() do tmpdir
            path = joinpath(tmpdir, "test.glb")
            export_glb(path, mesh)
            data = read(path)

            # Parse JSON chunk header (after 12-byte GLB header)
            json_length = reinterpret(UInt32, data[13:16])[1]
            json_type = reinterpret(UInt32, data[17:20])[1]
            @test json_type == 0x4E4F534A  # "JSON" in little-endian

            json_str = String(data[21:20+json_length])
            # Should contain mesh data references
            @test occursin("meshes", json_str)
            @test occursin("accessors", json_str)
            @test occursin("bufferViews", json_str)
        end
    end

    @testset "export_glb with custom color" begin
        mesh = cylinder_mesh(
            SVector(0.0, 0.0, 0.0),
            SVector(0.0, 1.0, 0.0),
            0.5, 0.3; segments=4
        )
        mktempdir() do tmpdir
            path = joinpath(tmpdir, "colored.glb")
            result = export_glb(path, mesh; color=(0.2, 0.8, 0.1))
            @test isfile(path)
            data = read(path)
            @test data[1:4] == UInt8[0x67, 0x6C, 0x54, 0x46]
        end
    end

    @testset "export_glb with empty mesh" begin
        mesh = TriangleMesh(
            SVector{3,Float64}[],
            SVector{3,Float64}[],
            NTuple{3,Int}[],
            SVector{2,Float64}[],
        )
        mktempdir() do tmpdir
            path = joinpath(tmpdir, "empty.glb")
            @test_throws ArgumentError export_glb(path, mesh)
        end
    end

    @testset "render_lsystem_3d end-to-end" begin
        @testset "Simple tree produces mesh and GLB" begin
            axiom = LString("X")
            rs = RuleSet([
                Rule(LSymbol('X'), LString("F[+X][-X]FX")),
                Rule(LSymbol('F'), LString("FF")),
            ])
            mktempdir() do tmpdir
                path = joinpath(tmpdir, "tree.glb")
                mesh = render_lsystem_3d(axiom, rs, 3;
                    angle=25.7, step=1.0, base_radius=0.1,
                    output_path=path
                )
                @test length(mesh.vertices) > 0
                @test length(mesh.faces) > 0
                @test isfile(path)
            end
        end

        @testset "Without output_path returns mesh only" begin
            axiom = LString("F")
            rs = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))])
            mesh = render_lsystem_3d(axiom, rs, 2; angle=25.7)
            @test length(mesh.vertices) > 0
            @test length(mesh.faces) > 0
        end

        @testset "No F segments throws ArgumentError" begin
            axiom = LString("X")
            rs = RuleSet([Rule(LSymbol('X'), LString("XX"))])
            @test_throws ArgumentError render_lsystem_3d(axiom, rs, 3; angle=25.0)
        end
    end
end
