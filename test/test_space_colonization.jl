using StableRNGs
using StaticArrays
using LinearAlgebra

@testset "Space Colonization" begin

    @testset "Envelope generation" begin
        @testset "Sphere envelope" begin
            rng = StableRNG(42)
            points = generate_envelope(:sphere, 100; radius=5.0, center=SVector(0.0, 5.0, 0.0), rng=rng)
            @test length(points) == 100
            @test eltype(points) == SVector{3, Float64}
            # All points within sphere
            for p in points
                @test norm(p - SVector(0.0, 5.0, 0.0)) <= 5.0 + 1e-10
            end
        end

        @testset "Cylinder envelope" begin
            rng = StableRNG(42)
            points = generate_envelope(:cylinder, 100; radius=3.0, height=10.0,
                                       center=SVector(0.0, 5.0, 0.0), rng=rng)
            @test length(points) == 100
            for p in points
                @test sqrt(p[1]^2 + p[3]^2) <= 3.0 + 1e-10
            end
        end

        @testset "Cone envelope" begin
            rng = StableRNG(42)
            points = generate_envelope(:cone, 100; radius=4.0, height=8.0,
                                       center=SVector(0.0, 0.0, 0.0), rng=rng)
            @test length(points) == 100
            for p in points
                # At height y, max radius = radius * (1 - y/height)
                y_frac = (p[2] - 0.0) / 8.0
                max_r = 4.0 * (1.0 - y_frac)
                @test sqrt(p[1]^2 + p[3]^2) <= max_r + 1e-10
            end
        end

        @testset "Crown envelope" begin
            rng = StableRNG(42)
            points = generate_envelope(:crown, 100; radius=5.0, inner_radius=3.0,
                                       center=SVector(0.0, 5.0, 0.0), rng=rng)
            @test length(points) == 100
            for p in points
                d = norm(p - SVector(0.0, 5.0, 0.0))
                @test d <= 5.0 + 1e-10
                @test d >= 3.0 - 1e-10
            end
        end

        @testset "Deterministic with StableRNG" begin
            pts1 = generate_envelope(:sphere, 50; rng=StableRNG(123))
            pts2 = generate_envelope(:sphere, 50; rng=StableRNG(123))
            @test pts1 == pts2
        end
    end

    @testset "Space colonization" begin
        @testset "Collinear attraction - straight growth" begin
            # Place attraction points in a vertical line above root
            points = [SVector(0.0, Float64(i), 0.0) for i in 2:10]
            root = SVector(0.0, 0.0, 0.0)
            rng = StableRNG(42)
            segments = space_colonize(points; root=root, growth_step=1.0,
                                      d_attraction=15.0, d_kill=0.5,
                                      max_iterations=100, rng=rng)
            @test !isempty(segments)
            # Growth should be roughly vertical
            for seg in segments
                @test abs(seg.stop[1] - seg.start[1]) < 0.5  # minimal X deviation
                @test abs(seg.stop[3] - seg.start[3]) < 0.5  # minimal Z deviation
            end
        end

        @testset "Surrounding points - branching" begin
            rng = StableRNG(42)
            # Points in multiple directions from root
            points = [
                SVector(5.0, 5.0, 0.0),
                SVector(-5.0, 5.0, 0.0),
                SVector(0.0, 5.0, 5.0),
                SVector(0.0, 5.0, -5.0),
            ]
            root = SVector(0.0, 0.0, 0.0)
            segments = space_colonize(points; root=root, growth_step=1.0,
                                      d_attraction=20.0, d_kill=1.0,
                                      max_iterations=50, rng=rng)
            @test length(segments) > 1
        end

        @testset "d_kill removes points" begin
            rng = StableRNG(42)
            points = [SVector(0.0, 2.0, 0.0)]
            root = SVector(0.0, 0.0, 0.0)
            segments = space_colonize(points; root=root, growth_step=1.0,
                                      d_attraction=5.0, d_kill=1.5,
                                      max_iterations=100, rng=rng)
            # Should terminate after reaching the point
            @test length(segments) <= 5
        end

        @testset "Deterministic with StableRNG" begin
            rng1 = StableRNG(99)
            rng2 = StableRNG(99)
            points = [SVector(0.0, 5.0, 0.0), SVector(3.0, 5.0, 0.0)]
            root = SVector(0.0, 0.0, 0.0)
            s1 = space_colonize(points; root=root, growth_step=1.0,
                                d_attraction=10.0, d_kill=1.0, max_iterations=20, rng=rng1)
            s2 = space_colonize(copy(points); root=root, growth_step=1.0,
                                d_attraction=10.0, d_kill=1.0, max_iterations=20, rng=rng2)
            @test length(s1) == length(s2)
            for i in eachindex(s1)
                @test s1[i] ≈ s2[i]
            end
        end

        @testset "Returns LineSegment3D" begin
            rng = StableRNG(42)
            points = [SVector(0.0, 5.0, 0.0)]
            segments = space_colonize(points; root=SVector(0.0, 0.0, 0.0),
                                      growth_step=1.0, d_attraction=10.0, d_kill=1.0,
                                      max_iterations=20, rng=rng)
            @test eltype(segments) == LineSegment3D
        end

        @testset "Max iterations respected" begin
            rng = StableRNG(42)
            # Far away point that won't be killed
            points = [SVector(0.0, 1000.0, 0.0)]
            segments = space_colonize(points; root=SVector(0.0, 0.0, 0.0),
                                      growth_step=1.0, d_attraction=2000.0, d_kill=0.1,
                                      max_iterations=5, rng=rng)
            @test length(segments) <= 5
        end

        @testset "Empty attraction points" begin
            segments = space_colonize(SVector{3,Float64}[]; root=SVector(0.0, 0.0, 0.0),
                                      growth_step=1.0, d_attraction=10.0, d_kill=1.0,
                                      max_iterations=10, rng=StableRNG(42))
            @test isempty(segments)
        end
    end
end
