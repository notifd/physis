@testset "Grass Species" begin
    grasses = list_species(; category=:grasses)
    @test length(grasses) == 5

    for def in grasses
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    @test get_species("Wheat") !== nothing
    @test get_species("Bamboo") !== nothing
    @test get_species("Pampas Grass") !== nothing
    @test get_species("Fountain Grass") !== nothing
    @test get_species("Blue Fescue") !== nothing

    # Verify category
    for def in grasses
        @test def.category == :grasses
    end

    # Verify grass-specific metadata
    wheat = get_species("Wheat")
    @test get(wheat.metadata, :tropism, nothing) == :gravitropism

    fountain = get_species("Fountain Grass")
    @test get(fountain.metadata, :tropism, nothing) == :gravitropism
end
