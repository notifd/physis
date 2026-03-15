# Physis.jl

**Physis** is a Julia package implementing Lindenmayer systems (L-systems) for procedural plant generation. It produces 2D SVG, interactive 3D GLB, and photorealistic Blender Cycles renders of 127 species across 15 botanical and fractal categories.

## Quick Start

```julia
using Physis

# Define a simple plant L-system
axiom = LString("F")
rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))])

# Derive 4 generations
result = derive(axiom, rules, 4)

# Interpret as 2D line segments
segments = interpret2d(result; angle=25.7)

# Or use a predefined species
species = get_species("Plant 1 (ABOP 1.24a)")
```

## Architecture

Physis is organized into layered modules:

| Module | Purpose |
|--------|---------|
| **Core** (`src/core/`) | Symbol types, rewriting rules (D0L, parametric, stochastic, context-sensitive), string rewriting engine |
| **Turtle** (`src/turtle/`) | 2D and 3D turtle interpreters converting L-strings into geometric line segments |
| **Geometry** (`src/geometry/`) | Mesh generation: cylinders, leaves, flowers, fruits, phyllotaxis, pipe model, LOD |
| **Algorithms** (`src/algorithms/`) | Advanced generation: space colonization, Weber-Penn trees, self-organizing models |
| **Species** (`src/species/`) | 127 species definitions organized by category with literature citations |
| **Render** (`src/render/`) | CairoMakie 2D rendering, glTF/GLB export, 3D rendering pipeline, growth animation |
| **Blender** (`src/blender/`) | Blender Cycles integration for photorealistic renders |

## Design Philosophy

Physis uses **Julia's multiple dispatch** idiom throughout. Rule types (`Rule`, `ParametricRule`, `StochasticRule`, `ContextRule`) are structs under `AbstractRule`, and `rewrite_step()` dispatches on rule type. Symbol types (`LSymbol`, `ParametricSymbol`) are structs under `AbstractSymbol`. This avoids if/else chains and makes the system extensible.

Key design decisions:
- **StaticArrays** (`SVector{3, Float64}`) for positions and directions, not `Vector{Float64}`
- **StableRNGs** for reproducible stochastic derivation
- **Package extensions** for optional rendering backends (CairoMakie)
- **Pure Julia glTF export** with no external dependencies

## Installation

Physis is not yet registered in the General registry. Clone and use directly:

```julia
using Pkg
Pkg.develop(path="/path/to/physis")
using Physis
```

## References

- Prusinkiewicz & Lindenmayer, *The Algorithmic Beauty of Plants* (ABOP), 1990
- Runions, Lane & Prusinkiewicz, "Modeling Trees with a Space Colonization Algorithm", 2007
- Palubicki et al., "Self-organizing Tree Models for Image Synthesis", 2009
- Weber & Penn, "Creation and Rendering of Realistic Trees", SIGGRAPH 1995
- Shinozaki et al., "A Quantitative Analysis of Plant Form -- the Pipe Model Theory", 1964
- Vogel, "A Better Way to Construct the Sunflower Head", 1979
