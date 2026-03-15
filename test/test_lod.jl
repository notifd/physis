using StaticArrays

@testset "Level of Detail (LOD)" begin

    # Helper: create some test segments
    function _make_test_segments()
        # Simple tree: trunk + 2 branches + 4 sub-branches
        segs = LineSegment3D[]
        # Trunk (depth 0)
        push!(segs, LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0, 0))
        push!(segs, LineSegment3D(SVector(0.0, 1.0, 0.0), SVector(0.0, 2.0, 0.0), 1.0, 0))
        # Branch L (depth 1)
        push!(segs, LineSegment3D(SVector(0.0, 2.0, 0.0), SVector(-1.0, 3.0, 0.0), 0.7, 1))
        # Branch R (depth 1)
        push!(segs, LineSegment3D(SVector(0.0, 2.0, 0.0), SVector(1.0, 3.0, 0.0), 0.7, 1))
        # Sub-branches (depth 2)
        push!(segs, LineSegment3D(SVector(-1.0, 3.0, 0.0), SVector(-1.5, 4.0, 0.0), 0.5, 2))
        push!(segs, LineSegment3D(SVector(-1.0, 3.0, 0.0), SVector(-0.5, 4.0, 0.0), 0.5, 2))
        push!(segs, LineSegment3D(SVector(1.0, 3.0, 0.0), SVector(1.5, 4.0, 0.0), 0.5, 2))
        push!(segs, LineSegment3D(SVector(1.0, 3.0, 0.0), SVector(0.5, 4.0, 0.0), 0.5, 2))
        segs
    end

    @testset "generate_lod returns correct number of levels" begin
        segs = _make_test_segments()
        lods = generate_lod(segs; levels=3)
        @test length(lods) == 3
    end

    @testset "LOD 0 (full detail) matches segments_to_mesh" begin
        segs = _make_test_segments()
        lods = generate_lod(segs; levels=3)
        full = segments_to_mesh(segs)
        # LOD 0 should have the same number of vertices as full mesh
        @test length(lods[1].vertices) == length(full.vertices)
    end

    @testset "Each LOD has fewer or equal vertices than previous" begin
        segs = _make_test_segments()
        lods = generate_lod(segs; levels=3)
        for i in 2:length(lods)
            @test length(lods[i].vertices) <= length(lods[i-1].vertices)
        end
    end

    @testset "Lowest LOD has fewest vertices" begin
        segs = _make_test_segments()
        lods = generate_lod(segs; levels=3)
        @test length(lods[end].vertices) <= length(lods[1].vertices)
    end

    @testset "All LODs are valid meshes" begin
        segs = _make_test_segments()
        lods = generate_lod(segs; levels=3)
        for (i, mesh) in enumerate(lods)
            @testset "LOD $i" begin
                @test !isempty(mesh.vertices)
                @test !isempty(mesh.faces)
                nv = length(mesh.vertices)
                for (a, b, c) in mesh.faces
                    @test 1 <= a <= nv
                    @test 1 <= b <= nv
                    @test 1 <= c <= nv
                end
            end
        end
    end

    @testset "Single level LOD" begin
        segs = _make_test_segments()
        lods = generate_lod(segs; levels=1)
        @test length(lods) == 1
        @test !isempty(lods[1].vertices)
    end

    @testset "Empty segments" begin
        lods = generate_lod(LineSegment3D[]; levels=3)
        @test length(lods) == 3
        for mesh in lods
            @test isempty(mesh.vertices)
        end
    end

    @testset "Depth pruning reduces segments" begin
        segs = _make_test_segments()
        # At full detail: 8 segments
        # At max depth 1: 4 segments (only depth 0 and 1)
        # At max depth 0: 2 segments (only trunk)
        lods = generate_lod(segs; levels=3)
        @test length(lods[end].vertices) < length(lods[1].vertices)
    end
end
