@testset "Aquatic Species" begin
    aquatic = list_species(; category=:aquatic)
    @test length(aquatic) == 5

    for def in aquatic
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    @test get_species("Water Lily") !== nothing
    @test get_species("Seaweed") !== nothing
    @test get_species("Kelp") !== nothing
    @test get_species("Duckweed") !== nothing
    @test get_species("Lotus") !== nothing

    # Verify category
    for def in aquatic
        @test def.category == :aquatic
    end

    # Verify aquatic-specific metadata
    water_lily = get_species("Water Lily")
    @test get(water_lily.metadata, :tropism, nothing) == :hydrotropism
end
