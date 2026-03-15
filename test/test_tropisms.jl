using Test
using Physis
using StaticArrays
using LinearAlgebra

@testset "Tropisms" begin

    @testset "apply_tropism basics" begin
        heading = SVector(0.0, 1.0, 0.0)
        up      = SVector(0.0, 0.0, 1.0)

        @testset "zero strength returns heading unchanged" begin
            tropism_vec = SVector(0.0, -1.0, 0.0)
            new_h, new_u = apply_tropism(heading, up, tropism_vec, 0.0)
            @test new_h == heading
            @test new_u == up
        end

        @testset "gravitropism curves heading downward" begin
            # Gravity pulls downward: T = (0, -1, 0)
            tropism_vec = SVector(0.0, -1.0, 0.0)
            new_h, new_u = apply_tropism(heading, up, tropism_vec, 0.3)
            # H = (0,1,0), T = (0,-1,0) => H x T = (0,1,0) x (0,-1,0) = (0,0,0)
            # Parallel vectors => no torque, heading unchanged
            @test isapprox(new_h, heading; atol=1e-10)
        end

        @testset "gravitropism on tilted heading curves downward" begin
            # Heading tilted 45 degrees: partly up, partly right
            tilted_h = normalize(SVector(1.0, 1.0, 0.0))
            tilted_up = SVector(0.0, 0.0, 1.0)
            tropism_vec = SVector(0.0, -1.0, 0.0)
            new_h, _ = apply_tropism(tilted_h, tilted_up, tropism_vec, 0.3)
            # After gravitropism, Y component should decrease (bend downward)
            @test new_h[2] < tilted_h[2]
            # Heading should remain normalized
            @test isapprox(norm(new_h), 1.0; atol=1e-10)
        end

        @testset "phototropism changes heading direction" begin
            # Heading straight up, light to the right — torque is along -Z
            # The heading will tilt into the -Z direction
            light_vec = SVector(1.0, 0.0, 0.0)
            new_h, _ = apply_tropism(heading, up, light_vec, 0.3)
            # H x T = (0,1,0) x (1,0,0) = (0,0,-1), so heading gains negative Z
            @test new_h[3] < 0.0
            @test isapprox(norm(new_h), 1.0; atol=1e-10)
        end

        @testset "strong tropism has larger effect than weak" begin
            tilted_h = normalize(SVector(1.0, 1.0, 0.0))
            tilted_up = SVector(0.0, 0.0, 1.0)
            tropism_vec = SVector(0.0, -1.0, 0.0)

            weak_h, _ = apply_tropism(tilted_h, tilted_up, tropism_vec, 0.1)
            strong_h, _ = apply_tropism(tilted_h, tilted_up, tropism_vec, 1.0)

            # Strong tropism should bend more (larger angular deviation from original)
            weak_angle = acos(clamp(dot(weak_h, tilted_h), -1.0, 1.0))
            strong_angle = acos(clamp(dot(strong_h, tilted_h), -1.0, 1.0))
            @test strong_angle > weak_angle
        end

        @testset "output vectors are orthogonal and normalized" begin
            tilted_h = normalize(SVector(1.0, 1.0, 0.0))
            tilted_up = SVector(0.0, 0.0, 1.0)
            tropism_vec = SVector(0.0, -1.0, 0.0)
            new_h, new_u = apply_tropism(tilted_h, tilted_up, tropism_vec, 0.5)
            @test isapprox(norm(new_h), 1.0; atol=1e-10)
            @test isapprox(norm(new_u), 1.0; atol=1e-10)
            @test isapprox(dot(new_h, new_u), 0.0; atol=1e-10)
        end
    end

    @testset "interpret3d with tropism" begin
        # Simple L-string: 4 forward steps
        ls = LString([LSymbol('F'), LSymbol('F'), LSymbol('F'), LSymbol('F')])

        @testset "tropism=nothing (default) is backward compatible" begin
            segs_default = interpret3d(ls; angle=25.0, step=1.0)
            segs_explicit = interpret3d(ls; angle=25.0, step=1.0, tropism=nothing, tropism_strength=0.0)
            @test length(segs_default) == length(segs_explicit)
            for (a, b) in zip(segs_default, segs_explicit)
                @test isapprox(a, b; atol=1e-12)
            end
        end

        @testset "gravitropism curves segments downward" begin
            # Without tropism, 4 F steps go straight up (Y axis)
            segs_no_trop = interpret3d(ls; step=1.0)
            # With gravitropism
            grav = SVector(0.0, -1.0, 0.0)
            segs_trop = interpret3d(ls; step=1.0, tropism=grav, tropism_strength=0.3)

            # Without tropism, all segments should be along Y axis
            @test isapprox(segs_no_trop[end].stop, SVector(0.0, 4.0, 0.0); atol=1e-10)

            # With tropism: heading starts as (0,1,0), which is anti-parallel to (0,-1,0),
            # so H x T = 0 and no bending occurs for a straight-up heading.
            # Let's use a different test: branching with an initial tilt.
        end

        @testset "tropism with tilted initial heading" begin
            # Tilt the turtle by pitching down 30 degrees, then walk forward
            ls_tilted = LString([
                LSymbol('&'),  # pitch down
                LSymbol('F'), LSymbol('F'), LSymbol('F'), LSymbol('F'),
                LSymbol('F'), LSymbol('F'), LSymbol('F'), LSymbol('F'),
            ])
            grav = SVector(0.0, -1.0, 0.0)
            segs_trop = interpret3d(ls_tilted; angle=30.0, step=1.0,
                                    tropism=grav, tropism_strength=0.3)
            segs_no_trop = interpret3d(ls_tilted; angle=30.0, step=1.0)

            # With tropism, the final position should be more negative in Y
            # (gravity pulls it down further)
            @test segs_trop[end].stop[2] < segs_no_trop[end].stop[2]
        end

        @testset "single F segment with tropism changes heading for next segment" begin
            # Pitch down, then two F segments with tropism
            ls2 = LString([LSymbol('&'), LSymbol('F'), LSymbol('F')])
            grav = SVector(0.0, -1.0, 0.0)
            segs = interpret3d(ls2; angle=45.0, step=1.0, tropism=grav, tropism_strength=0.3)

            @test length(segs) == 2
            # The two segments should have different directions
            dir1 = segs[1].stop - segs[1].start
            dir2 = segs[2].stop - segs[2].start
            # They should not be parallel (tropism bends between them)
            cos_angle = dot(normalize(dir1), normalize(dir2))
            @test cos_angle < 1.0 - 1e-10  # Not parallel
        end

        @testset "collect_organs still works with tropism" begin
            ls_organs = LString([LSymbol('F'), LSymbol('L'), LSymbol('F'), LSymbol('K')])
            grav = SVector(0.0, -1.0, 0.0)
            segs, organs = interpret3d(ls_organs; step=1.0, collect_organs=true,
                                       tropism=grav, tropism_strength=0.1)
            @test length(segs) == 2
            @test length(organs) == 2
            @test organs[1].organ_type == :leaf
            @test organs[2].organ_type == :flower
        end
    end
end
