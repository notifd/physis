@testset "Vine Species" begin
    vines = list_species(; category=:vines)
    @test length(vines) == 5

    for def in vines
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    @test get_species("Ivy") !== nothing
    @test get_species("Grape Vine") !== nothing
    @test get_species("Wisteria") !== nothing
    @test get_species("Morning Glory") !== nothing
    @test get_species("Clematis") !== nothing

    # Verify category
    for def in vines
        @test def.category == :vines
    end
end
