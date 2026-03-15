"""
Tests for Fern species (Phase 7B).

Verifies that all 5 fern species are registered, produce non-empty
segments when derived and interpreted, and have proper metadata.
Reference: ABOP Fig 1.24 variants; Barnsley 1988
"""

@testset "Fern Species" begin
    ferns = list_species(; category=:ferns)
    @test length(ferns) == 5

    for def in ferns
        @testset "$(def.name)" begin
            derived = derive(def.axiom, def.rules, def.generations)
            processed = substitute_draw_symbols(derived, def.draw_chars)
            segs = interpret2d(processed; angle=def.angle)
            @test length(segs) > 0
            @test haskey(def.metadata, :reference)
        end
    end

    # Check specific species exist
    @test get_species("Barnsley Fern") !== nothing
    @test get_species("Maidenhair Fern") !== nothing
    @test get_species("Ostrich Fern") !== nothing
    @test get_species("Tree Fern") !== nothing
    @test get_species("Bracken Fern") !== nothing
end
