@testset "Flower Species" begin
    flowers = list_species(; category=:flowers)
    @test length(flowers) == 5

    for def in flowers
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    @test get_species("Sunflower") !== nothing
    @test get_species("Wild Rose") !== nothing
    @test get_species("Dandelion") !== nothing
    @test get_species("Lily") !== nothing
    @test get_species("Orchid") !== nothing

    # Verify category
    for def in flowers
        @test def.category == :flowers
    end

    # Verify flower-specific metadata
    sunflower = get_species("Sunflower")
    @test get(sunflower.metadata, :has_flowers, false) == true
    @test get(sunflower.metadata, :use_phyllotaxis, false) == true

    wild_rose = get_species("Wild Rose")
    @test get(wild_rose.metadata, :has_flowers, false) == true

    lily = get_species("Lily")
    @test get(lily.metadata, :has_flowers, false) == true

    orchid = get_species("Orchid")
    @test get(orchid.metadata, :has_flowers, false) == true
end
