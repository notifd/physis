"""
Tests for Coniferous species (Phase 7A).

Verifies that all 5 coniferous species are registered, produce non-empty
segments when derived and interpreted, and have proper metadata.
Reference: ABOP Fig 2.6–2.8; Honda 1971
"""

@testset "Coniferous Species" begin
    coniferous = list_species(; category=:coniferous)
    @test length(coniferous) == 5

    for def in coniferous
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    # Check specific species exist
    @test get_species("Norway Spruce") !== nothing
    @test get_species("Scots Pine") !== nothing
    @test get_species("Blue Spruce") !== nothing
    @test get_species("Eastern Red Cedar") !== nothing
    @test get_species("Balsam Fir") !== nothing
end
