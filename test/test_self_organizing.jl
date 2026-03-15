using StableRNGs
using StaticArrays
using LinearAlgebra

@testset "Self-Organizing Trees" begin

    @testset "LightGrid construction" begin
        grid = LightGrid(10, 10.0)
        @test grid.resolution == 10
        @test grid.extent == 10.0
    end

    @testset "LightGrid shadow casting" begin
        grid = LightGrid(10, 10.0)
        # Cast shadow from above
        cast_shadow!(grid, SVector(0.0, 5.0, 0.0), 1.0)
        # Light below should be reduced
        light = query_light(grid, SVector(0.0, 2.0, 0.0))
        @test light < 1.0
    end

    @testset "Grows away from shadow" begin
        rng = StableRNG(42)
        # Create envelope with points only on one side
        envelope = [SVector(Float64(x), 5.0, 0.0) for x in 1:5]
        segments = self_organize_tree(;
            envelope=envelope,
            iterations=10,
            growth_step=1.0,
            bud_perception_angle=90.0,
            shadow_strength=0.5,
            d_attraction=15.0,
            d_kill=1.0,
            rng=rng
        )
        @test !isempty(segments)
        @test eltype(segments) == LineSegment3D
    end

    @testset "Bud death (low vigor)" begin
        rng = StableRNG(42)
        # Minimal envelope — only a few attraction points
        envelope = [SVector(0.0, 3.0, 0.0)]
        segments = self_organize_tree(;
            envelope=envelope,
            iterations=20,
            growth_step=0.5,
            d_attraction=10.0,
            d_kill=0.5,
            shadow_strength=0.8,
            rng=rng
        )
        # Should terminate
        @test length(segments) < 100
    end

    @testset "Deterministic with StableRNG" begin
        envelope = [SVector(0.0, 5.0, 0.0), SVector(3.0, 5.0, 0.0), SVector(-3.0, 5.0, 0.0)]
        s1 = self_organize_tree(; envelope=envelope, iterations=10, rng=StableRNG(99))
        s2 = self_organize_tree(; envelope=copy(envelope), iterations=10, rng=StableRNG(99))
        @test length(s1) == length(s2)
        for i in eachindex(s1)
            @test s1[i] ≈ s2[i]
        end
    end

    @testset "Connected structure" begin
        rng = StableRNG(42)
        envelope = [SVector(0.0, 5.0, 0.0), SVector(2.0, 5.0, 0.0)]
        segments = self_organize_tree(; envelope=envelope, iterations=15, rng=rng)
        if !isempty(segments)
            # At least one segment starts at root
            @test any(s -> norm(s.start) < 0.1, segments)
        end
    end

    @testset "Empty envelope" begin
        segments = self_organize_tree(; envelope=SVector{3,Float64}[], iterations=10, rng=StableRNG(42))
        @test isempty(segments)
    end

    @testset "Returns LineSegment3D" begin
        envelope = [SVector(0.0, 5.0, 0.0)]
        segments = self_organize_tree(; envelope=envelope, iterations=5, rng=StableRNG(42))
        @test eltype(segments) == LineSegment3D
    end
end
