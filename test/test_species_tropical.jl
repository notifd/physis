"""
Tests for Tropical species (Phase 7C).

Verifies that all 5 tropical species are registered, produce non-empty
segments when derived and interpreted, and have proper metadata.
Reference: Tomlinson 1990
"""

@testset "Tropical Species" begin
    tropical = list_species(; category=:tropical)
    @test length(tropical) == 5

    for def in tropical
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    # Check specific species exist
    @test get_species("Coconut Palm") !== nothing
    @test get_species("Traveler's Palm") !== nothing
    @test get_species("Banana Plant") !== nothing
    @test get_species("Bird of Paradise") !== nothing
    @test get_species("Monstera") !== nothing
end
