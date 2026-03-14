"""
Tests for the L-system HTML gallery generation.

Tests that:
1. Gallery has 100 L-system entries across 6 categories
2. substitute_draw_symbols correctly replaces non-F drawing symbols
3. Each L-system produces non-empty line segments when derived + interpreted
4. generate_gallery creates SVG files and HTML index in output directory
5. HTML contains category section headers and navigation
"""

using CairoMakie  # ensure CairoMakie extension is loaded for save_render

include(joinpath(@__DIR__, "..", "scripts", "generate_gallery.jl"))

@testset "Gallery L-Systems" begin

    @testset "Gallery has 82 entries" begin
        @test length(GALLERY) == 82
        @test all(e -> e.name isa String && !isempty(e.name), GALLERY)
        @test all(e -> e.generations > 0, GALLERY)
        @test all(e -> e.angle > 0, GALLERY)
    end

    @testset "All entries have non-empty category" begin
        @test all(e -> e.category isa String && !isempty(e.category), GALLERY)
    end

    @testset "All entry names are unique" begin
        names = [e.name for e in GALLERY]
        @test length(names) == length(unique(names))
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

            # Category section headers in HTML
            categories = unique([e.category for e in GALLERY])
            for cat in categories
                @test occursin(cat, html)
            end

            # Navigation bar with category links
            @test occursin("nav", html)
        end
    end

    @testset "3D Gallery Generation" begin

        @testset "is_3d_species identifies 3D vs 2D entries" begin
            # 3D species have is_3d=true in metadata
            entries_3d = [e for e in GALLERY if is_3d_species(e)]
            entries_2d = [e for e in GALLERY if !is_3d_species(e)]

            @test length(entries_3d) == 7
            @test all(e -> e.category == "Plants & Trees", entries_3d)

            # 2D plants exist but are not 3D
            plants_2d = [e for e in entries_2d if e.category == "Plants & Trees"]
            @test length(plants_2d) == 10

            # Fractals are never 3D
            fractal_entry = first(e for e in GALLERY if e.category == "Fractal Curves")
            @test is_3d_species(fractal_entry) == false
        end

        @testset "render_entry_3d produces valid GLB files" begin
            species_lookup = Dict(def.name => def for def in list_species())
            # Pick two 3D species for testing
            entries_3d = [e for e in GALLERY if is_3d_species(e)]
            test_entries = entries_3d[1:2]

            mktempdir() do tmpdir
                for entry in test_entries
                    def = species_lookup[entry.name]
                    glb_filename = render_entry_3d(entry, def, tmpdir)
                    @test glb_filename !== nothing
                    @test endswith(glb_filename, ".glb")
                    glb_path = joinpath(tmpdir, glb_filename)
                    @test isfile(glb_path)
                    @test filesize(glb_path) > 0
                end
            end
        end

        @testset "render_entry_3d returns nothing on failure" begin
            # Create a dummy entry with an empty axiom that will fail
            bad_entry = (
                name = "Bad Plant",
                category = "Plants & Trees",
                axiom = LString("+"),
                rules = RuleSet(Rule[]),
                generations = 1,
                angle = 25.0,
                draw_chars = Set(['F']),
                linecolor = "#50fa7b",
                linewidth = 1.0,
                reference = "",
                rule_notation = "",
            )
            bad_def = LSystemDef(
                name = "Bad Plant",
                category = :plants_trees,
                axiom = LString("+"),
                rules = RuleSet(Rule[]),
                generations = 1,
                angle = 25.0,
            )

            mktempdir() do tmpdir
                result = render_entry_3d(bad_entry, bad_def, tmpdir)
                @test result === nothing
            end
        end

        @testset "Full gallery integration with 3D" begin
            mktempdir() do tmpdir
                generate_gallery(tmpdir)

                html = read(joinpath(tmpdir, "index.html"), String)

                # model-viewer CDN script present
                @test occursin("model-viewer", html)
                @test occursin("ajax.googleapis.com/ajax/libs/model-viewer", html)

                # toggleView JS present
                @test occursin("toggleView", html)

                # 3D species have GLB files and model-viewer elements
                entries_3d = [e for e in GALLERY if is_3d_species(e)]
                for entry in entries_3d
                    glb_filename = entry_slug(entry.name) * ".glb"
                    glb_path = joinpath(tmpdir, glb_filename)
                    @test isfile(glb_path)
                    @test occursin(glb_filename, html)
                end

                # Non-3D entries do NOT have GLB files
                entries_2d = [e for e in GALLERY if !is_3d_species(e)]
                for entry in entries_2d
                    glb_filename = entry_slug(entry.name) * ".glb"
                    @test !isfile(joinpath(tmpdir, glb_filename))
                end

                # model-viewer tag is in HTML
                @test occursin("<model-viewer", html)

                # Tab CSS is present
                @test occursin("media-tabs", html)
                @test occursin("media-view", html)
            end
        end
    end
end
