using StaticArrays
using LinearAlgebra

@testset "Turtle3D" begin
    @testset "LineSegment3D" begin
        @testset "Construction and equality" begin
            p1 = SVector(0.0, 0.0, 0.0)
            p2 = SVector(1.0, 0.0, 0.0)
            seg = LineSegment3D(p1, p2, 1.0)
            @test seg.start == p1
            @test seg.stop == p2
            @test seg.width == 1.0
            @test seg == LineSegment3D(p1, p2, 1.0)
            @test seg != LineSegment3D(p1, p2, 2.0)
        end

        @testset "hash — usable in Set/Dict" begin
            s1 = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0), 1.0)
            s2 = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0), 1.0)
            s3 = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(0.0, 1.0, 0.0), 1.0)
            @test hash(s1) == hash(s2)
            @test length(Set([s1, s2, s3])) == 2
        end

        @testset "isapprox" begin
            s1 = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(1.0, 0.0, 0.0), 1.0)
            s2 = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(1.0 + 1e-15, 0.0, 0.0), 1.0)
            s3 = LineSegment3D(SVector(0.0, 0.0, 0.0), SVector(2.0, 0.0, 0.0), 1.0)
            @test s1 ≈ s2
            @test !(s1 ≈ s3)
        end

        @testset "show" begin
            seg = LineSegment3D(SVector(0.0, 1.0, 2.0), SVector(3.0, 4.0, 5.0), 1.0)
            @test contains(sprint(show, seg), "→")
        end
    end

    @testset "Default state" begin
        @testset "Default heading is (0,1,0), left=(-1,0,0), up=(0,0,1)" begin
            # A single F should produce a segment along Y axis (heading up)
            segs = interpret3d(LString("F"); angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 1.0, 0.0)
        end
    end

    @testset "interpret3d basics" begin
        @testset "Empty LString → no segments" begin
            result = interpret3d(LString(AbstractSymbol[]))
            @test isempty(result)
        end

        @testset "No F symbols → no segments" begin
            result = interpret3d(LString("+-&^"))
            @test isempty(result)
        end

        @testset "Single F draws one segment along heading" begin
            segs = interpret3d(LString("F"); angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 1.0, 0.0)
        end

        @testset "Two F's draw two connected segments" begin
            segs = interpret3d(LString("FF"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[1].start ≈ SVector(0.0, 0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(0.0, 2.0, 0.0)
        end
    end

    @testset "Yaw (+/-) — rotation around U axis" begin
        @testset "F+F with 90° yaw turns left in XY plane" begin
            # Default heading (0,1,0), yaw left 90° around U=(0,0,1) → heading (-1,0,0)
            segs = interpret3d(LString("F+F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(-1.0, 1.0, 0.0) atol=1e-12
        end

        @testset "F-F with 90° yaw turns right in XY plane" begin
            # Default heading (0,1,0), yaw right 90° around U=(0,0,1) → heading (1,0,0)
            segs = interpret3d(LString("F-F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(1.0, 1.0, 0.0) atol=1e-12
        end
    end

    @testset "Pitch (&/^) — rotation around L axis" begin
        @testset "F&F with 90° pitch tilts down into -Z" begin
            # Heading (0,1,0), pitch down 90° around L=(-1,0,0) → heading (0,0,-1)
            segs = interpret3d(LString("F&F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(0.0, 1.0, -1.0) atol=1e-12
        end

        @testset "F^F with 90° pitch tilts up into +Z" begin
            # Heading (0,1,0), pitch up 90° around L=(-1,0,0) → heading (0,0,1)
            segs = interpret3d(LString("F^F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(0.0, 1.0, 1.0) atol=1e-12
        end
    end

    @testset "Roll (\\/) — rotation around H axis" begin
        @testset "Roll does not change heading direction" begin
            # Roll only rotates L and U around H, heading stays the same
            segs_no_roll = interpret3d(LString("FF"); angle=90.0, step=1.0)
            segs_with_roll = interpret3d(LString("F\\F"); angle=90.0, step=1.0)
            @test length(segs_with_roll) == 2
            # Second segment should be identical — heading unchanged by roll
            @test segs_with_roll[2].stop ≈ segs_no_roll[2].stop atol=1e-12
        end

        @testset "Roll changes subsequent yaw plane" begin
            # Roll left 90° then yaw left 90°
            # Default: H=(0,1,0), L=(-1,0,0), U=(0,0,1)
            # After roll left (\) 90° around H=(0,1,0): L=(0,0,1), U=(1,0,0)
            # After yaw left (+) 90° around new U=(1,0,0):
            # H=(0,1,0) rotated +90° around (1,0,0) → H=(0,0,1)
            segs = interpret3d(LString("F\\+F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(0.0, 1.0, 1.0) atol=1e-12
        end

        @testset "/ is roll right" begin
            # Roll right 90° then yaw left 90°
            # Default: H=(0,1,0), L=(-1,0,0), U=(0,0,1)
            # After roll right (/) 90° around H=(0,1,0): L=(0,0,-1), U=(-1,0,0)
            # After yaw left (+) 90° around new U=(-1,0,0):
            # H=(0,1,0) rotated +90° around (-1,0,0) → H=(0,0,-1)
            segs = interpret3d(LString("F/+F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(0.0, 1.0, -1.0) atol=1e-12
        end
    end

    @testset "Turn around (|)" begin
        @testset "| reverses direction (180° yaw)" begin
            segs = interpret3d(LString("F|F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(0.0, 0.0, 0.0) atol=1e-12
        end
    end

    @testset "Branching [/]" begin
        @testset "Push/pop preserves full 3D state" begin
            # F[+F]F — branch left then continue straight
            segs = interpret3d(LString("F[+F]F"); angle=90.0, step=1.0)
            @test length(segs) == 3
            # First F: (0,0,0)→(0,1,0)
            @test segs[1].start ≈ SVector(0.0, 0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 1.0, 0.0)
            # Branch F: from (0,1,0) heading left (-1,0,0)
            @test segs[2].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[2].stop ≈ SVector(-1.0, 1.0, 0.0) atol=1e-12
            # After pop, continue from (0,1,0) heading up (0,1,0)
            @test segs[3].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[3].stop ≈ SVector(0.0, 2.0, 0.0)
        end

        @testset "Nested branches" begin
            segs = interpret3d(LString("F[+F[-F]]F"); angle=90.0, step=1.0)
            @test length(segs) == 4
            # After all pops, last F continues from (0,1,0) heading up
            @test segs[4].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[4].stop ≈ SVector(0.0, 2.0, 0.0)
        end

        @testset "Branch with pitch preserves 3D frame" begin
            # F[&F]F — branch pitching down, then continue straight
            segs = interpret3d(LString("F[&F]F"); angle=90.0, step=1.0)
            @test length(segs) == 3
            # Branch F goes into -Z
            @test segs[2].stop ≈ SVector(0.0, 1.0, -1.0) atol=1e-12
            # After pop, continues along Y
            @test segs[3].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[3].stop ≈ SVector(0.0, 2.0, 0.0)
        end

        @testset "Mismatched ] throws ArgumentError" begin
            @test_throws ArgumentError interpret3d(LString("]F"))
        end

        @testset "Unclosed [ is allowed" begin
            segs = interpret3d(LString("[F"))
            @test length(segs) == 1
        end
    end

    @testset "Parametric symbols" begin
        @testset "F(d) uses custom step" begin
            ls = LString([ParametricSymbol('F', (3.0,))])
            segs = interpret3d(ls; angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 3.0, 0.0)
        end

        @testset "+(a) uses custom angle" begin
            # F +(45) F — turn left 45° from heading (0,1,0)
            ls = LString([LSymbol('F'), ParametricSymbol('+', (45.0,)), LSymbol('F')])
            segs = interpret3d(ls; angle=90.0, step=1.0)
            @test length(segs) == 2
            expected_stop = SVector(0.0, 1.0, 0.0) + SVector(cos(deg2rad(90.0 + 45.0)), sin(deg2rad(90.0 + 45.0)), 0.0)
            @test segs[2].stop ≈ expected_stop atol=1e-12
        end

        @testset "f(d) moves without drawing by custom distance" begin
            ls = LString([ParametricSymbol('f', (5.0,)), LSymbol('F')])
            segs = interpret3d(ls; angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 5.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 6.0, 0.0)
        end
    end

    @testset "Move without drawing (f)" begin
        @testset "f moves position but produces no segment" begin
            segs = interpret3d(LString("fF"); angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 1.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 2.0, 0.0)
        end
    end

    @testset "Unknown symbols are no-ops" begin
        segs = interpret3d(LString("XFYF"); angle=90.0, step=1.0)
        @test length(segs) == 2
        @test segs[1].start ≈ SVector(0.0, 0.0, 0.0)
    end

    @testset "Width tracking" begin
        @testset "Default width is applied to segments" begin
            segs = interpret3d(LString("F"); angle=90.0, step=1.0, width=2.5)
            @test length(segs) == 1
            @test segs[1].width == 2.5
        end
    end

    @testset "Orthonormality preservation" begin
        @testset "Frame stays orthonormal after many rotations" begin
            # Build a string with many mixed rotations then F
            symbols = AbstractSymbol[]
            for _ in 1:150
                push!(symbols, LSymbol('+'))
                push!(symbols, LSymbol('&'))
                push!(symbols, LSymbol('\\'))
            end
            push!(symbols, LSymbol('F'))
            ls = LString(symbols)
            segs = interpret3d(ls; angle=17.0, step=1.0)
            @test length(segs) == 1
            # The segment should have length ≈ 1.0 (step), verifying frame integrity
            seg_vec = segs[1].stop - segs[1].start
            @test norm(seg_vec) ≈ 1.0 atol=1e-10
        end
    end

    @testset "Integration with derive" begin
        @testset "3D bush segment count" begin
            # Simple branching rule: F → F[+F]F[-F]F
            # RHS has 5 F's, so segment count = 5^n
            r = Rule(LSymbol('F'), LString("F[+F]F[-F]F"))
            rs = RuleSet([r])
            axiom = LString("F")

            gen0 = axiom
            @test length(interpret3d(gen0; angle=25.7)) == 1

            gen1 = derive(axiom, rs, 1)
            @test length(interpret3d(gen1; angle=25.7)) == 5

            gen2 = derive(axiom, rs, 2)
            @test length(interpret3d(gen2; angle=25.7)) == 25
        end
    end

    @testset "Step scale (\" command)" begin
        @testset "\" reduces step length by scale factor" begin
            ls = LString("F\"F")
            segs = interpret3d(ls; angle=90.0, step=1.0, step_scale=0.5)
            @test length(segs) == 2
            len1 = norm(segs[1].stop - segs[1].start)
            len2 = norm(segs[2].stop - segs[2].start)
            @test len1 ≈ 1.0
            @test len2 ≈ 0.5
        end

        @testset "\" inside branch is restored on pop" begin
            ls = LString("F[\"F]F")
            segs = interpret3d(ls; angle=90.0, step=1.0, step_scale=0.5)
            @test length(segs) == 3
            len1 = norm(segs[1].stop - segs[1].start)
            len2 = norm(segs[2].stop - segs[2].start)
            len3 = norm(segs[3].stop - segs[3].start)
            @test len1 ≈ 1.0
            @test len2 ≈ 0.5
            @test len3 ≈ 1.0
        end

        @testset "Houdini ternary tree produces tapering branches" begin
            axiom = LString("FFFA")
            rules = RuleSet([
                Rule(LSymbol('A'), LString("\"[&FFFA]////[&FFFA]////[&FFFA]")),
            ])
            derived = derive(axiom, rules, 2)
            segs = interpret3d(derived; angle=22.5, step=1.0, step_scale=0.7)
            # Gen 0 trunk segments should be length 1.0
            @test norm(segs[1].stop - segs[1].start) ≈ 1.0
            # After first \", gen 1 branches should be 0.7
            gen1_branch = segs[4]  # first segment after first "
            @test norm(gen1_branch.stop - gen1_branch.start) ≈ 0.7 atol=1e-10
        end
    end
end
