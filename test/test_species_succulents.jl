@testset "Succulent Species" begin
    succulents = list_species(; category=:succulents)
    @test length(succulents) == 5

    for def in succulents
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    @test get_species("Aloe Vera") !== nothing
    @test get_species("Agave") !== nothing
    @test get_species("Jade Plant") !== nothing
    @test get_species("Echeveria") !== nothing
    @test get_species("Prickly Pear") !== nothing

    # Verify category
    for def in succulents
        @test def.category == :succulents
    end

    # Verify succulent-specific metadata
    aloe = get_species("Aloe Vera")
    @test get(aloe.metadata, :use_phyllotaxis, false) == true

    agave = get_species("Agave")
    @test get(agave.metadata, :use_phyllotaxis, false) == true

    echeveria = get_species("Echeveria")
    @test get(echeveria.metadata, :use_phyllotaxis, false) == true
end
