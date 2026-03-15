"""
Tests for the Species Catalog (Phase 5).

Tests that:
1. LSystemDef can be constructed with all fields
2. species_slug converts names to URL-safe slugs
3. substitute_draw_symbols replaces non-F drawing symbols
4. Registry operations (register, get, list, categories)
5. All 100 species are registered
6. All species produce non-empty segments when derived + interpreted
7. Category coverage matches expected 6 categories
"""

@testset "Species Catalog" begin

    @testset "LSystemDef construction" begin
        def = LSystemDef(
            name = "Test Species",
            category = :fractal_curves,
            axiom = LString("F"),
            rules = RuleSet([Rule(LSymbol('F'), LString("F+F"))]),
            generations = 3,
            angle = 90.0,
            step = 1.0,
            draw_chars = Set(['F']),
            metadata = Dict{Symbol, Any}(:reference => "test"),
        )
        @test def.name == "Test Species"
        @test def.category == :fractal_curves
        @test def.generations == 3
        @test def.angle == 90.0
        @test def.step == 1.0
        @test def.draw_chars == Set(['F'])
        @test def.metadata[:reference] == "test"
    end

    @testset "LSystemDef defaults" begin
        def = LSystemDef(
            name = "Defaults Test",
            category = :fractal_curves,
            axiom = LString("F"),
            rules = RuleSet([Rule(LSymbol('F'), LString("F+F"))]),
            generations = 1,
            angle = 90.0,
        )
        @test def.step == 1.0
        @test def.draw_chars == Set(['F'])
        @test isempty(def.metadata)
    end

    @testset "species_slug" begin
        @test species_slug("Koch Curve") == "koch-curve"
        @test species_slug("Plant 1 (ABOP 1.24a)") == "plant-1-abop-1-24a"
        @test species_slug("Sierpinski Triangle") == "sierpinski-triangle"
        @test species_slug("32-Segment Curve") == "32-segment-curve"
        @test species_slug("Hilbert II") == "hilbert-ii"
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

    @testset "Registry operations" begin
        # Save and restore registry state
        saved = copy(Physis.SPECIES_REGISTRY)
        try
            empty!(Physis.SPECIES_REGISTRY)

            def1 = LSystemDef(
                name = "Registry Test 1",
                category = :fractal_curves,
                axiom = LString("F"),
                rules = RuleSet([Rule(LSymbol('F'), LString("F+F"))]),
                generations = 1,
                angle = 90.0,
            )
            def2 = LSystemDef(
                name = "Registry Test 2",
                category = :plants_trees,
                axiom = LString("F"),
                rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F"))]),
                generations = 2,
                angle = 25.0,
            )

            register_species!(def1)
            register_species!(def2)

            # get_species
            @test get_species("Registry Test 1") === def1
            @test get_species("Registry Test 2") === def2
            @test get_species("Nonexistent") === nothing

            # list_species
            all_species = list_species()
            @test length(all_species) == 2
            @test all_species[1].name == "Registry Test 1"  # sorted by name
            @test all_species[2].name == "Registry Test 2"

            # list_species with category filter
            fractals = list_species(; category=:fractal_curves)
            @test length(fractals) == 1
            @test fractals[1].name == "Registry Test 1"

            plants = list_species(; category=:plants_trees)
            @test length(plants) == 1
            @test plants[1].name == "Registry Test 2"

            empty_cat = list_species(; category=:nonexistent)
            @test isempty(empty_cat)

            # list_categories
            cats = list_categories()
            @test length(cats) == 2
            @test :fractal_curves in cats
            @test :plants_trees in cats

            # Duplicate registration warning
            @test_logs (:warn, r"Overwriting") register_species!(def1)
        finally
            # Restore registry
            empty!(Physis.SPECIES_REGISTRY)
            merge!(Physis.SPECIES_REGISTRY, saved)
        end
    end

    @testset "All 112 species registered" begin
        @test length(list_species()) == 112
        # All names unique
        names = [s.name for s in list_species()]
        @test length(unique(names)) == 112
    end

    @testset "All species produce segments" begin
        for def in list_species()
            @testset "$(def.name)" begin
                derived = derive(def.axiom, def.rules, def.generations)
                processed = substitute_draw_symbols(derived, def.draw_chars)
                segs = interpret2d(processed; angle=def.angle)
                @test length(segs) > 0
            end
        end
    end

    @testset "Category coverage" begin
        cats = list_categories()
        @test length(cats) == 12
        @test :fractal_curves in cats
        @test :dragon_family in cats
        @test :sierpinski_family in cats
        @test :space_filling in cats
        @test :plants_trees in cats
        @test :artistic_patterns in cats
        @test :coniferous in cats
        @test :ferns in cats
        @test :tropical in cats
        @test :flowers in cats
        @test :grasses in cats
        @test :succulents in cats
    end
end
