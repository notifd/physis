"""
Tests for the L-system HTML gallery generation.

Tests that:
1. Gallery has 10 classic ABOP L-system entries
2. substitute_draw_symbols correctly replaces non-F drawing symbols
3. Each L-system produces non-empty line segments when derived + interpreted
4. generate_gallery creates SVG files and HTML index in output directory
"""

using CairoMakie  # ensure CairoMakie extension is loaded for save_render

include(joinpath(@__DIR__, "..", "scripts", "generate_gallery.jl"))

@testset "Gallery L-Systems" begin

    @testset "Gallery has 10 entries" begin
        @test length(GALLERY) == 10
        @test all(e -> e.name isa String && !isempty(e.name), GALLERY)
        @test all(e -> e.generations > 0, GALLERY)
        @test all(e -> e.angle > 0, GALLERY)
    end

    @testset "substitute_draw_symbols" begin
        # Replaces G with F when G is a draw char
        ls = LString("FGF")
        result = substitute_draw_symbols(ls, Set(['F', 'G']))
        @test length(result) == 3
        @test all(s -> name(s) == 'F', result)

        # Preserves non-draw symbols
        ls2 = LString("F+G-F")
        result2 = substitute_draw_symbols(ls2, Set(['F', 'G']))
        @test length(result2) == 5
        @test name(result2[1]) == 'F'
        @test name(result2[2]) == '+'
        @test name(result2[3]) == 'F'  # G replaced with F
        @test name(result2[4]) == '-'
        @test name(result2[5]) == 'F'

        # No-op when only F draws (returns same object)
        ls3 = LString("F+F")
        result3 = substitute_draw_symbols(ls3, Set(['F']))
        @test result3 === ls3
    end

    @testset "entry_slug" begin
        @test entry_slug("Koch Curve") == "koch-curve"
        @test entry_slug("Plant 1") == "plant-1"
        @test entry_slug("Sierpinski Triangle") == "sierpinski-triangle"
    end

    @testset "Each L-system produces segments" begin
        for entry in GALLERY
            @testset "$(entry.name)" begin
                derived = derive(entry.axiom, entry.rules, entry.generations)
                @test length(derived) > 0

                processed = substitute_draw_symbols(derived, entry.draw_chars)
                segments = interpret2d(processed; angle=entry.angle)
                @test length(segments) > 0
            end
        end
    end

    @testset "Gallery generation" begin
        mktempdir() do tmpdir
            generate_gallery(tmpdir)

            # HTML index exists
            @test isfile(joinpath(tmpdir, "index.html"))

            # SVGs exist for each entry
            for entry in GALLERY
                svgfile = entry_slug(entry.name) * ".svg"
                @test isfile(joinpath(tmpdir, svgfile))
            end

            # HTML content checks
            html = read(joinpath(tmpdir, "index.html"), String)
            @test occursin("<html", html)
            @test occursin("Physis", html)
            @test occursin("L-System Gallery", html)
            for entry in GALLERY
                @test occursin(entry.name, html)
                @test occursin(entry.rule_notation, html)
            end
        end
    end
end
