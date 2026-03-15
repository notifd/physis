using StableRNGs

@testset "Growth Animation" begin

    @testset "animate_growth produces frames" begin
        def = LSystemDef(
            name = "Test Animation",
            category = :plants_trees,
            axiom = LString("F"),
            rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))]),
            generations = 3,
            angle = 25.7,
        )

        output_dir = mktempdir()
        frames = animate_growth(def; output_dir=output_dir)

        # Should produce N+1 frames (gen 0 through gen N)
        @test length(frames) == def.generations + 1

        # Each frame should be a valid file path
        for frame in frames
            @test isfile(frame)
            @test endswith(frame, ".svg")
        end
    end

    @testset "Frame count matches generations" begin
        for gens in [1, 2, 4]
            def = LSystemDef(
                name = "Animation $gens",
                category = :plants_trees,
                axiom = LString("F"),
                rules = RuleSet([Rule(LSymbol('F'), LString("F+F"))]),
                generations = gens,
                angle = 90.0,
            )

            output_dir = mktempdir()
            frames = animate_growth(def; output_dir=output_dir)
            @test length(frames) == gens + 1
        end
    end

    @testset "Custom format" begin
        def = LSystemDef(
            name = "Format Test",
            category = :plants_trees,
            axiom = LString("F"),
            rules = RuleSet([Rule(LSymbol('F'), LString("F+F"))]),
            generations = 2,
            angle = 90.0,
        )

        output_dir = mktempdir()
        frames = animate_growth(def; output_dir=output_dir, format=:svg)
        @test all(f -> endswith(f, ".svg"), frames)
    end

    @testset "Output directory is created" begin
        def = LSystemDef(
            name = "Dir Test",
            category = :plants_trees,
            axiom = LString("F"),
            rules = RuleSet([Rule(LSymbol('F'), LString("FF"))]),
            generations = 2,
            angle = 90.0,
        )

        output_dir = mktempdir()
        frames = animate_growth(def; output_dir=output_dir)
        @test isdir(output_dir)
    end

    @testset "Each frame has increasing complexity" begin
        def = LSystemDef(
            name = "Complexity Test",
            category = :plants_trees,
            axiom = LString("F"),
            rules = RuleSet([Rule(LSymbol('F'), LString("F+F"))]),
            generations = 3,
            angle = 90.0,
        )

        output_dir = mktempdir()
        frames = animate_growth(def; output_dir=output_dir)

        # Each file should be larger than the previous (more complex SVG)
        sizes = [filesize(f) for f in frames]
        for i in 2:length(sizes)
            @test sizes[i] >= sizes[i-1]
        end
    end
end
