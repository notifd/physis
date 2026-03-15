# Adding a Species

This tutorial walks through adding a new species to the Physis catalog.

## Step 1: Create the Species File

Decide which category your species belongs to and create or edit the appropriate file under `src/species/`. For example, to add a new fern:

```
src/species/ferns/ferns.jl
```

If you're creating a new category, create a new directory and file:

```
src/species/mycategory/mycategory.jl
```

## Step 2: Define the LSystemDef

Each species is an [`LSystemDef`](@ref) with these required fields:

```julia
register_species!(LSystemDef(
    name = "My Custom Fern",
    category = :ferns,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Custom design based on ABOP principles",
        :linecolor => "#228B22",
        :linewidth => 1.0,
        :rule_notation => "X -> F[+X][-X]FX; F -> FF",
    ),
))
```

### Field Guide

| Field | Required | Notes |
|-------|----------|-------|
| `name` | Yes | Must be unique across all species |
| `category` | Yes | A `Symbol` like `:ferns`, `:fractal_curves`, etc. |
| `axiom` | Yes | The starting `LString` |
| `rules` | Yes | A `RuleSet` with one or more rules |
| `generations` | Yes | Number of derivation steps |
| `angle` | Yes | Turtle turn angle in degrees |
| `step` | No | Step length (default 1.0) |
| `draw_chars` | No | Characters that draw forward (default `Set(['F'])`) |
| `metadata` | No | Dictionary for reference, colors, etc. |

### Metadata Conventions

The metadata dictionary commonly includes:

- `:reference` -- Literature citation (required by convention)
- `:linecolor` -- Hex color string for 2D rendering
- `:linewidth` -- Line width for 2D rendering
- `:rule_notation` -- Human-readable rule notation

## Step 3: Include in Physis.jl

If you created a new file, add an `include` line in `src/Physis.jl` under the species catalog section:

```julia
# -- Species catalog --
include("species/catalog.jl")
include("species/registry.jl")
# ... existing includes ...
include("species/mycategory/mycategory.jl")  # Add this
```

If you added to an existing file, no changes to `Physis.jl` are needed.

## Step 4: Add Tests

Add a test for your new species in `test/test_species.jl`:

```julia
@testset "My Custom Fern" begin
    species = get_species("My Custom Fern")
    @test species !== nothing
    @test species.category == :ferns
    @test species.generations == 6

    # Verify it derives without error
    result = derive(species.axiom, species.rules, species.generations)
    @test length(result) > 0

    # Verify 2D interpretation works
    ls = substitute_draw_symbols(result, species.draw_chars)
    segments = interpret2d(ls; angle=species.angle)
    @test length(segments) > 0
end
```

## Step 5: Verify

Run the test suite to confirm everything works:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

Check that:
- Your species loads without warnings
- `get_species("My Custom Fern")` returns the definition
- `list_species(category=:ferns)` includes it
- Derivation and interpretation produce non-empty output

## Tips

- **Choose generation count carefully.** L-strings grow exponentially. A generation count that's too high can produce millions of symbols and take a long time to interpret.
- **Test visually.** Numbers alone don't tell you if the plant looks right. Render it and check.
- **Use `draw_chars` for multi-character grammars.** If your grammar uses characters other than `F` to draw (e.g., `G`, `X`), include them in `draw_chars` so the turtle interprets them as forward movement.
- **Cite your sources.** Every species in Physis has a literature reference. Include one in the metadata.
