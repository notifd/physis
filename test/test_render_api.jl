using StaticArrays

@testset "Render API" begin
    @testset "BoundingBox2D" begin
        @testset "Construction and fields" begin
            bb = BoundingBox2D(0.0, 1.0, 0.0, 1.0)
            @test bb.xmin == 0.0
            @test bb.xmax == 1.0
            @test bb.ymin == 0.0
            @test bb.ymax == 1.0
        end

        @testset "Width and height" begin
            bb = BoundingBox2D(-1.0, 3.0, -2.0, 5.0)
            @test bb.xmax - bb.xmin == 4.0
            @test bb.ymax - bb.ymin == 7.0
        end
    end

    @testset "compute_bbox" begin
        @testset "Single horizontal segment" begin
            seg = LineSegment2D(SVector(0.0, 0.0), SVector(3.0, 0.0))
            bb = compute_bbox([seg]; margin=0.0)
            @test bb.xmin ≈ 0.0
            @test bb.xmax ≈ 3.0
            @test bb.ymin ≈ 0.0
            @test bb.ymax ≈ 0.0
        end

        @testset "Multiple segments" begin
            segs = [
                LineSegment2D(SVector(-1.0, -2.0), SVector(3.0, 0.0)),
                LineSegment2D(SVector(0.0, 0.0), SVector(1.0, 5.0)),
            ]
            bb = compute_bbox(segs; margin=0.0)
            @test bb.xmin ≈ -1.0
            @test bb.xmax ≈ 3.0
            @test bb.ymin ≈ -2.0
            @test bb.ymax ≈ 5.0
        end

        @testset "Margin as fraction of larger dimension" begin
            # Rectangle: x from 0→10, y from 0→4. Larger dim = 10.
            # margin=0.1 → pad = 0.1 * 10 = 1.0
            segs = [LineSegment2D(SVector(0.0, 0.0), SVector(10.0, 4.0))]
            bb = compute_bbox(segs; margin=0.1)
            @test bb.xmin ≈ -1.0
            @test bb.xmax ≈ 11.0
            @test bb.ymin ≈ -1.0
            @test bb.ymax ≈ 5.0
        end

        @testset "Degenerate single-point defaults to 1.0 unit extent" begin
            # All endpoints are the same point
            seg = LineSegment2D(SVector(5.0, 5.0), SVector(5.0, 5.0))
            bb = compute_bbox([seg]; margin=0.0)
            @test bb.xmin ≈ 4.5
            @test bb.xmax ≈ 5.5
            @test bb.ymin ≈ 4.5
            @test bb.ymax ≈ 5.5
        end

        @testset "Degenerate single-point with margin" begin
            seg = LineSegment2D(SVector(0.0, 0.0), SVector(0.0, 0.0))
            bb = compute_bbox([seg]; margin=0.1)
            # extent = 1.0, margin = 0.1 * 1.0 = 0.1
            @test bb.xmin ≈ -0.6
            @test bb.xmax ≈ 0.6
            @test bb.ymin ≈ -0.6
            @test bb.ymax ≈ 0.6
        end

        @testset "Empty segments throws ArgumentError" begin
            @test_throws ArgumentError compute_bbox(LineSegment2D[])
        end

        @testset "Default margin is 0.1" begin
            segs = [LineSegment2D(SVector(0.0, 0.0), SVector(10.0, 10.0))]
            bb = compute_bbox(segs)
            # extent = 10.0, pad = 0.1 * 10 = 1.0
            @test bb.xmin ≈ -1.0
            @test bb.xmax ≈ 11.0
        end
    end

    @testset "render2d and save_render are declared" begin
        # These functions exist as part of the public API
        @test render2d isa Function
        @test save_render isa Function
    end

    @testset "render2d and save_render throw clear error without backend" begin
        # These tests must run BEFORE CairoMakie is loaded (test_cairomakie_ext.jl)
        # to verify the fallback error path works.
        seg = LineSegment2D(SVector(0.0, 0.0), SVector(1.0, 1.0))

        ex1 = try render2d([seg]); nothing catch e; e end
        @test ex1 isa ErrorException
        @test occursin("CairoMakie", ex1.msg)

        ex2 = try save_render("/tmp/test.png", [seg]); nothing catch e; e end
        @test ex2 isa ErrorException
        @test occursin("CairoMakie", ex2.msg)
    end

    @testset "render_lsystem" begin
        @testset "Throws ArgumentError if no F segments produced" begin
            # Axiom with no F, rule that produces no F
            axiom = LString("A")
            r = Rule(LSymbol('A'), LString("A"))
            rs = RuleSet([r])
            @test_throws ArgumentError render_lsystem(axiom, rs, 3)
        end
    end
end
