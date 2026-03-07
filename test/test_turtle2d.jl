using StaticArrays

@testset "Turtle2D" begin
    @testset "LineSegment2D" begin
        @testset "Construction and equality" begin
            p1 = SVector(0.0, 0.0)
            p2 = SVector(1.0, 0.0)
            seg = LineSegment2D(p1, p2)
            @test seg.start == p1
            @test seg.stop == p2
            @test seg == LineSegment2D(p1, p2)
        end
    end

    @testset "interpret2d basics" begin
        @testset "Empty LString → no segments" begin
            result = interpret2d(LString(AbstractSymbol[]))
            @test isempty(result)
        end

        @testset "No F symbols → no segments" begin
            result = interpret2d(LString("+-+-"))
            @test isempty(result)
        end

        @testset "Single F draws one segment upward" begin
            segs = interpret2d(LString("F"); angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 1.0)
        end

        @testset "Two F's draw two connected segments" begin
            segs = interpret2d(LString("FF"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[1].start ≈ SVector(0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 1.0)
            @test segs[2].start ≈ SVector(0.0, 1.0)
            @test segs[2].stop ≈ SVector(0.0, 2.0)
        end
    end

    @testset "Turning" begin
        @testset "F+F with 90° angle turns left" begin
            # Start heading up (90°), + turns left → heading 180° (left)
            segs = interpret2d(LString("F+F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0)
            @test segs[2].stop ≈ SVector(-1.0, 1.0) atol=1e-12
        end

        @testset "F-F with 90° angle turns right" begin
            # Start heading up (90°), - turns right → heading 0° (right)
            segs = interpret2d(LString("F-F"); angle=90.0, step=1.0)
            @test length(segs) == 2
            @test segs[2].start ≈ SVector(0.0, 1.0)
            @test segs[2].stop ≈ SVector(1.0, 1.0) atol=1e-12
        end

        @testset "Custom angle" begin
            # 60° turn: heading starts at 90°, + turns to 150°
            segs = interpret2d(LString("F+F"); angle=60.0, step=1.0)
            @test length(segs) == 2
            expected_x = cos(deg2rad(150.0))
            expected_y = 1.0 + sin(deg2rad(150.0))
            @test segs[2].stop ≈ SVector(expected_x, expected_y) atol=1e-12
        end
    end

    @testset "Move without drawing (f)" begin
        @testset "f moves position but produces no segment" begin
            segs = interpret2d(LString("fF"); angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 1.0)
            @test segs[1].stop ≈ SVector(0.0, 2.0)
        end
    end

    @testset "Branching" begin
        @testset "Push/pop preserves state" begin
            # F[+F]F — branch left then continue straight
            segs = interpret2d(LString("F[+F]F"); angle=90.0, step=1.0)
            @test length(segs) == 3
            # First F: (0,0)→(0,1)
            @test segs[1].start ≈ SVector(0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 1.0)
            # Branch F: from (0,1) heading left → (-1,1)
            @test segs[2].start ≈ SVector(0.0, 1.0)
            @test segs[2].stop ≈ SVector(-1.0, 1.0) atol=1e-12
            # After pop, continue from (0,1) heading up → (0,2)
            @test segs[3].start ≈ SVector(0.0, 1.0)
            @test segs[3].stop ≈ SVector(0.0, 2.0)
        end

        @testset "Nested branches" begin
            # F[+F[-F]]F
            segs = interpret2d(LString("F[+F[-F]]F"); angle=90.0, step=1.0)
            @test length(segs) == 4
            # After all pops, last F continues from (0,1) heading up
            @test segs[4].start ≈ SVector(0.0, 1.0)
            @test segs[4].stop ≈ SVector(0.0, 2.0)
        end

        @testset "Mismatched ] throws ArgumentError" begin
            @test_throws ArgumentError interpret2d(LString("]F"))
        end

        @testset "Unclosed [ is allowed" begin
            # No error — stack simply not fully popped
            segs = interpret2d(LString("[F"))
            @test length(segs) == 1
        end
    end

    @testset "Parametric symbols" begin
        @testset "F(d) uses custom step" begin
            ls = LString([ParametricSymbol('F', (3.0,))])
            segs = interpret2d(ls; angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 0.0)
            @test segs[1].stop ≈ SVector(0.0, 3.0)
        end

        @testset "+(a) and -(a) use custom angle" begin
            # F +(45) F — turn left 45° from heading 90° → heading 135°
            ls = LString([LSymbol('F'), ParametricSymbol('+', (45.0,)), LSymbol('F')])
            segs = interpret2d(ls; angle=90.0, step=1.0)
            @test length(segs) == 2
            expected = SVector(cos(deg2rad(135.0)), 1.0 + sin(deg2rad(135.0)))
            @test segs[2].stop ≈ expected atol=1e-12
        end

        @testset "f(d) moves without drawing by custom distance" begin
            ls = LString([ParametricSymbol('f', (5.0,)), LSymbol('F')])
            segs = interpret2d(ls; angle=90.0, step=1.0)
            @test length(segs) == 1
            @test segs[1].start ≈ SVector(0.0, 5.0)
            @test segs[1].stop ≈ SVector(0.0, 6.0)
        end
    end

    @testset "Unknown symbols are no-ops" begin
        segs = interpret2d(LString("XFYF"); angle=90.0, step=1.0)
        @test length(segs) == 2
        @test segs[1].start ≈ SVector(0.0, 0.0)
    end

    @testset "Zero step and zero angle" begin
        segs = interpret2d(LString("F"); angle=0.0, step=0.0)
        @test length(segs) == 1
        @test segs[1].start ≈ segs[1].stop
    end

    @testset "Integration with derive" begin
        @testset "Koch curve segment count" begin
            # Koch curve: F → F+F-F-F+F, angle 90°
            # RHS has 5 F's, so segment count = 5^n
            # Gen 0: 1, Gen 1: 5, Gen 2: 25
            r = Rule(LSymbol('F'), LString("F+F-F-F+F"))
            rs = RuleSet([r])
            axiom = LString("F")

            gen0 = axiom
            @test length(interpret2d(gen0; angle=90.0)) == 1

            gen1 = derive(axiom, rs, 1)
            @test length(interpret2d(gen1; angle=90.0)) == 5

            gen2 = derive(axiom, rs, 2)
            @test length(interpret2d(gen2; angle=90.0)) == 25
        end

        @testset "Koch snowflake (ABOP §1.5)" begin
            # Axiom: F--F--F (equilateral triangle)
            # Rule: F → F+F--F+F, angle 60°
            # Gen 0: 3 segments, Gen 1: 12 segments
            r = Rule(LSymbol('F'), LString("F+F--F+F"))
            rs = RuleSet([r])
            axiom = LString("F--F--F")

            gen0_segs = interpret2d(axiom; angle=60.0)
            @test length(gen0_segs) == 3

            gen1 = derive(axiom, rs, 1)
            gen1_segs = interpret2d(gen1; angle=60.0)
            @test length(gen1_segs) == 12  # 3 * 4
        end
    end
end
