using CairoMakie
using StaticArrays

@testset "CairoMakie Extension" begin
    # Helper: simple segments for testing
    simple_segments() = [
        LineSegment2D(SVector(0.0, 0.0), SVector(0.0, 1.0)),
        LineSegment2D(SVector(0.0, 1.0), SVector(1.0, 1.0)),
    ]

    @testset "render2d returns a Makie Figure" begin
        fig = render2d(simple_segments())
        @test fig isa CairoMakie.Makie.Figure
    end

    @testset "render2d keyword arguments" begin
        fig = render2d(simple_segments();
                       linecolor=:red, linewidth=2.0,
                       backgroundcolor=:black, figsize=(600, 400), margin=0.2)
        @test fig isa CairoMakie.Makie.Figure
    end

    @testset "save_render produces PNG file" begin
        path = tempname() * ".png"
        try
            fig = save_render(path, simple_segments())
            @test fig isa CairoMakie.Makie.Figure
            @test isfile(path)
            @test filesize(path) > 0
        finally
            isfile(path) && rm(path)
        end
    end

    @testset "save_render produces SVG file" begin
        path = tempname() * ".svg"
        try
            fig = save_render(path, simple_segments())
            @test fig isa CairoMakie.Makie.Figure
            @test isfile(path)
            @test filesize(path) > 0
            # SVG files are text/XML
            content = read(path, String)
            @test contains(content, "<svg") || contains(content, "<?xml")
        finally
            isfile(path) && rm(path)
        end
    end

    @testset "render_lsystem end-to-end" begin
        # Koch curve: F → F+F-F-F+F
        r = Rule(LSymbol('F'), LString("F+F-F-F+F"))
        rs = RuleSet([r])
        axiom = LString("F")
        fig = render_lsystem(axiom, rs, 2; angle=90.0)
        @test fig isa CairoMakie.Makie.Figure
    end

    @testset "render_lsystem with save" begin
        path = tempname() * ".png"
        try
            r = Rule(LSymbol('F'), LString("F[+F]F[-F]F"))
            rs = RuleSet([r])
            axiom = LString("F")

            # Derive, interpret, then save
            derived = derive(axiom, rs, 3)
            segments = interpret2d(derived; angle=25.7)
            fig = save_render(path, segments)
            @test isfile(path)
            @test filesize(path) > 0
        finally
            isfile(path) && rm(path)
        end
    end

    @testset "render_lsystem ArgumentError on no segments" begin
        axiom = LString("A")
        r = Rule(LSymbol('A'), LString("A"))
        rs = RuleSet([r])
        @test_throws ArgumentError render_lsystem(axiom, rs, 3)
    end
end
