# Species Catalog

Physis ships with **127 species** organized into **15 categories**, all with literature citations. Every species is defined as an [`LSystemDef`](@ref) and registered at module load time.

## Categories

| Category | Count | Description |
|----------|-------|-------------|
| `:fractal_curves` | 20 | Classic fractal curves (Koch, Hilbert, Peano, etc.) |
| `:plants_trees` | 17 | 2D/3D plant and tree models from ABOP and literature |
| `:artistic_patterns` | 17 | Decorative and artistic L-system patterns |
| `:space_filling` | 12 | Space-filling curves (Hilbert, Peano variants, Gosper) |
| `:sierpinski_family` | 8 | Sierpinski triangle, carpet, and variants |
| `:dragon_family` | 8 | Dragon curve and related fractals |
| `:coniferous` | 5 | Coniferous tree species |
| `:ferns` | 5 | Fern species |
| `:tropical` | 5 | Tropical plant species |
| `:flowers` | 5 | Flowering plant species |
| `:grasses` | 5 | Grass species |
| `:succulents` | 5 | Succulent species |
| `:aquatic` | 5 | Aquatic plant species |
| `:vines` | 5 | Vine and climbing plant species |
| `:shrubs` | 5 | Shrub species |

## Working with Species

### List all species

```julia
using Physis

# All species, sorted by name
all = list_species()
println("Total species: ", length(all))

# Filter by category
ferns = list_species(category=:ferns)
for f in ferns
    println(f.name)
end
```

### List categories

```julia
categories = list_categories()
# [:aquatic, :artistic_patterns, :coniferous, ...]
```

### Get a specific species

```julia
species = get_species("Koch Curve")
# Returns LSystemDef or nothing
```

### Derive and render a species

```julia
species = get_species("Plant 1 (ABOP 1.24a)")
result = derive(species.axiom, species.rules, species.generations)
segments = interpret2d(result; angle=species.angle)
```

## Example Species Definition

Each species is an [`LSystemDef`](@ref) registered via [`register_species!`](@ref):

```julia
register_species!(LSystemDef(
    name = "Plant 1 (ABOP 1.24a)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))]),
    generations = 5,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24a, p.25",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F -> F[+F]F[-F]F",
    ),
))
```

### LSystemDef Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Human-readable species name |
| `category` | `Symbol` | Category tag (e.g. `:fractal_curves`) |
| `axiom` | `LString` | Initial string (generation 0) |
| `rules` | `RuleSet` | Production rules |
| `generations` | `Int` | Number of derivation steps |
| `angle` | `Float64` | Turtle turn angle in degrees |
| `step` | `Float64` | Turtle step length (default 1.0) |
| `draw_chars` | `Set{Char}` | Characters that produce forward movement |
| `metadata` | `Dict{Symbol, Any}` | Additional metadata (reference, linecolor, etc.) |

## Species File Organization

Species are organized in `src/species/` by category:

```
src/species/
  catalog.jl           # LSystemDef type definition
  registry.jl          # Global registry (register_species!, get_species, etc.)
  fractals/
    fractal_curves.jl  # 20 classic fractal curves
    dragon_family.jl   #  8 dragon curve variants
    sierpinski_family.jl # 8 Sierpinski variants
    space_filling.jl   # 12 space-filling curves
    artistic_patterns.jl # 17 artistic patterns
  deciduous/
    plants_trees.jl    # 17 plant and tree models
  coniferous/
    coniferous.jl      #  5 coniferous species
  ferns/
    ferns.jl           #  5 fern species
  tropical/
    tropical.jl        #  5 tropical species
  flowers/
    flowers.jl         #  5 flower species
  grasses/
    grasses.jl         #  5 grass species
  succulents/
    succulents.jl      #  5 succulent species
  aquatic/
    aquatic.jl         #  5 aquatic species
  vines/
    vines.jl           #  5 vine species
  shrubs/
    shrubs.jl          #  5 shrub species
```
