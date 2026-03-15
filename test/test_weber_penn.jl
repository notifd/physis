using StableRNGs
using StaticArrays
using LinearAlgebra

@testset "Weber-Penn Trees" begin

    @testset "WeberPennParams construction" begin
        params = WeberPennParams()  # defaults
        @test params.shape >= 0
        @test params.levels >= 1
        @test params.base_size > 0
        @test params.scale > 0
    end

    @testset "Presets exist" begin
        for preset in [:quaking_aspen, :black_tupelo, :weeping_willow, :palm]
            params = weber_penn_preset(preset)
            @test params isa WeberPennParams
            @test params.scale > 0
        end
    end

    @testset "Unknown preset throws" begin
        @test_throws ArgumentError weber_penn_preset(:nonexistent)
    end

    @testset "Generate returns segments" begin
        rng = StableRNG(42)
        params = weber_penn_preset(:quaking_aspen)
        segments = generate_weber_penn(params; rng=rng)
        @test !isempty(segments)
        @test eltype(segments) == LineSegment3D
    end

    @testset "Trunk is longest segment chain" begin
        rng = StableRNG(42)
        params = weber_penn_preset(:quaking_aspen)
        segments = generate_weber_penn(params; rng=rng)
        # At least one segment at depth 0 (trunk)
        trunk_segs = filter(s -> s.depth == 0, segments)
        @test !isempty(trunk_segs)
    end

    @testset "Branch count scales with levels" begin
        rng1 = StableRNG(42)
        params1 = WeberPennParams(; levels=1)
        segs1 = generate_weber_penn(params1; rng=rng1)

        rng2 = StableRNG(42)
        params2 = WeberPennParams(; levels=2)
        segs2 = generate_weber_penn(params2; rng=rng2)

        @test length(segs2) > length(segs1)
    end

    @testset "Deterministic with StableRNG" begin
        params = weber_penn_preset(:black_tupelo)
        s1 = generate_weber_penn(params; rng=StableRNG(99))
        s2 = generate_weber_penn(params; rng=StableRNG(99))
        @test length(s1) == length(s2)
        for i in eachindex(s1)
            @test s1[i] ≈ s2[i]
        end
    end

    @testset "All presets produce non-empty segments" begin
        for preset in [:quaking_aspen, :black_tupelo, :weeping_willow, :palm]
            rng = StableRNG(42)
            params = weber_penn_preset(preset)
            segments = generate_weber_penn(params; rng=rng)
            @test !isempty(segments)
        end
    end

    @testset "Segments have valid coordinates" begin
        rng = StableRNG(42)
        params = weber_penn_preset(:quaking_aspen)
        segments = generate_weber_penn(params; rng=rng)
        for seg in segments
            @test all(isfinite, seg.start)
            @test all(isfinite, seg.stop)
            @test isfinite(seg.width)
            @test seg.width > 0
        end
    end

    @testset "Tree grows upward from origin" begin
        rng = StableRNG(42)
        params = weber_penn_preset(:quaking_aspen)
        segments = generate_weber_penn(params; rng=rng)
        # Root segment should start near origin
        trunk_segs = filter(s -> s.depth == 0, segments)
        @test any(s -> norm(s.start) < 0.1, trunk_segs)
        # Tree should extend upward
        max_y = maximum(max(s.start[2], s.stop[2]) for s in segments)
        @test max_y > 1.0
    end
end
