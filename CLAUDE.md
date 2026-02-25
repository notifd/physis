# Physis — L-System Plant Generation Engine

## What Is This?

A Julia package that implements L-systems (Lindenmayer systems) for procedural plant generation, producing a gallery of 56+ species with 2D SVG, interactive 3D, and photorealistic renders.

## Architecture

- **Core engine** (`src/core/`): Symbol types, rewriting rules (D0L, parametric, stochastic, context-sensitive), string rewriting
- **Turtle** (`src/turtle/`): 2D and 3D turtle interpreters that convert L-strings into geometric structures
- **Geometry** (`src/geometry/`): Mesh generation — cylinders, leaves, flowers, phyllotaxis, pipe model
- **Species** (`src/species/`): 56 species definitions organized by category (deciduous, coniferous, tropical, etc.)
- **Algorithms** (`src/algorithms/`): Advanced generation (space colonization, self-organizing trees, Weber-Penn)
- **Render** (`src/render/`): CairoMakie 2D, GLMakie 3D, glTF export, materials
- **Gallery** (`src/gallery/`): Static web gallery generation for GitHub Pages
- **Blender** (`src/blender/`): Blender Cycles integration for photorealistic renders

## Key Design: Julia Multiple Dispatch

Rule types are structs under `AbstractRule`; `rewrite_step()` dispatches on rule type. Symbol types are structs under `AbstractSymbol`. This is idiomatic Julia — use dispatch, not if/else chains.

## Development

```bash
# Run tests
julia --project=. -e 'using Pkg; Pkg.test()'

# REPL workflow
julia --project=.
julia> using Physis
julia> # explore interactively
```

## Conventions

- **TDD mandatory**: Write tests first in `test/`, then implement in `src/`
- **One file per concept**: Each file should have a clear, single responsibility
- **Export public API from Physis.jl**: All public types and functions must be exported from the top-level module
- **Reference ABOP**: Cite Prusinkiewicz & Lindenmayer section numbers in docstrings where applicable
- **StaticArrays for vectors**: Use `SVector{3, Float64}` for positions/directions, not `Vector{Float64}`
- **StableRNGs for reproducibility**: All stochastic operations must accept an `AbstractRNG` parameter

## Testing

```
test/
├── runtests.jl         # Entry point, includes all test files
├── test_symbols.jl     # Symbol and LString tests
├── test_rules.jl       # Rule type tests (future)
├── test_rewriter.jl    # Rewriting tests (future)
├── test_turtle2d.jl    # 2D turtle tests (future)
├── test_turtle3d.jl    # 3D turtle tests (future)
└── test_species.jl     # Species catalog tests (future)
```

## References

- Prusinkiewicz & Lindenmayer, *The Algorithmic Beauty of Plants* (ABOP)
- Runions et al. (2007), "Modeling Trees with a Space Colonization Algorithm"
- Palubicki et al. (2009), "Self-organizing Tree Models for Image Synthesis"
- Weber & Penn (1995), "Creation and Rendering of Realistic Trees"
