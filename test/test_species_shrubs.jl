@testset "Shrub Species" begin
    shrubs = list_species(; category=:shrubs)
    @test length(shrubs) == 5

    for def in shrubs
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    @test get_species("Boxwood") !== nothing
    @test get_species("Lilac") !== nothing
    @test get_species("Azalea") !== nothing
    @test get_species("Juniper Bush") !== nothing
    @test get_species("Holly") !== nothing

    # Verify category
    for def in shrubs
        @test def.category == :shrubs
    end
end
