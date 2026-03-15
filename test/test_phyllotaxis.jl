"""
Tests for Phyllotaxis (Phase 2).

Tests that:
1. phyllotaxis_positions returns correct number of positions
2. Golden angle spacing is correct
3. Positions are in 3D (SVector{3,Float64})
4. Custom divergence angle works
5. Radius grows as sqrt(k/n)
6. Deterministic output
7. GOLDEN_ANGLE constant is correct

Reference: Vogel 1979
"""

using StaticArrays
using LinearAlgebra

@testset "Phyllotaxis" begin

    @testset "Returns correct count" begin
        for n in [1, 5, 10, 50]
            positions = phyllotaxis_positions(n)
            @test length(positions) == n
        end
    end

    @testset "Empty for n=0" begin
        @test isempty(phyllotaxis_positions(0))
    end

    @testset "Empty for negative n" begin
        @test isempty(phyllotaxis_positions(-1))
    end

    @testset "Correct element type" begin
        positions = phyllotaxis_positions(5)
        @test eltype(positions) == SVector{3, Float64}
    end

    @testset "Golden angle spacing" begin
        n = 100
        positions = phyllotaxis_positions(n)
        # Check angular spacing between consecutive points
        for k in 2:min(10, n)
            θ_prev = atan(positions[k-1][3], positions[k-1][1])
            θ_curr = atan(positions[k][3], positions[k][1])
            # The raw angle difference should correspond to the golden angle
            expected_diff = deg2rad(GOLDEN_ANGLE)
            # Due to wrapping, we check mod 2π
            actual_diff = mod(θ_curr - θ_prev, 2π)
            expected_mod = mod(expected_diff, 2π)
            @test isapprox(actual_diff, expected_mod; atol=1e-10)
        end
    end

    @testset "Points in XZ plane" begin
        positions = phyllotaxis_positions(20)
        for p in positions
            @test p[2] ≈ 0.0  # Y coordinate is zero
        end
    end

    @testset "Radius grows as sqrt(k/n)" begin
        n = 50
        radius = 2.0
        positions = phyllotaxis_positions(n; radius=radius)

        for k in [1, 10, 25, 50]
            expected_r = radius * sqrt(k / n)
            actual_r = norm(positions[k])
            @test isapprox(actual_r, expected_r; atol=1e-10)
        end

        # Last point should be at the specified radius
        @test isapprox(norm(positions[end]), radius; atol=1e-10)
    end

    @testset "Custom divergence angle" begin
        n = 10
        positions_golden = phyllotaxis_positions(n)
        positions_custom = phyllotaxis_positions(n; divergence_angle=90.0)
        # Different angles → different positions
        @test !isapprox(positions_golden[5], positions_custom[5]; atol=1e-6)
    end

    @testset "Deterministic output" begin
        pos1 = phyllotaxis_positions(20; radius=1.0)
        pos2 = phyllotaxis_positions(20; radius=1.0)
        @test pos1 == pos2
    end

    @testset "GOLDEN_ANGLE constant" begin
        # Golden angle = 360 * (1 - 1/φ) where φ = (1+√5)/2
        φ = (1 + √5) / 2
        expected = 360.0 * (1.0 - 1.0 / φ)
        @test isapprox(GOLDEN_ANGLE, expected; atol=1e-8)
    end
end
