# Algorithms

Physis implements several algorithms for procedural plant and fractal generation, drawn from the computational botany literature.

## L-System Rewriting

### D0L Systems (Deterministic, Context-Free)

The simplest L-system: each symbol is replaced in parallel according to deterministic, context-free rules.

```julia
rules = RuleSet([Rule(LSymbol('F'), LString("F+F--F+F"))])
result = derive(LString("F"), rules, 3)
```

**Reference:** ABOP Section 1.2

### Parametric L-Systems

Symbols carry numerical parameters that influence rule application via guard conditions and production functions.

```julia
# A(x) : x > 0 -> F A(x-1)
rule = ParametricRule(
    ParametricSymbol('A', (0.0,)),
    (x,) -> x > 0,
    (x,) -> AbstractSymbol[LSymbol('F'), ParametricSymbol('A', (x - 1,))]
)
```

**Reference:** ABOP Section 1.10

### Stochastic L-Systems

Rules with weighted random alternatives, enabling natural variation across derivations.

```julia
rule = StochasticRule(
    LSymbol('F'),
    [0.5, 0.5],
    [LString("F+F"), LString("F-F")]
)
```

Requires an `AbstractRNG` for reproducible results (use `StableRNGs.StableRNG`).

**Reference:** ABOP Section 1.7

### Context-Sensitive L-Systems (IL/2L-Systems)

Rules that match based on neighboring symbols, with bracket-transparent scanning. Bracketed sub-strings `[...]` are skipped during neighbor lookup, so `A[+F]B` has `A` as the left context of `B`.

```julia
# A < B -> C  (B becomes C only when preceded by A)
rule = ContextRule('A', LSymbol('B'), nothing, LString("C"))

# B > C -> D  (B becomes D only when followed by C)
rule = ContextRule(nothing, LSymbol('B'), 'C', LString("D"))

# A < B > C -> D  (both contexts required)
rule = ContextRule('A', LSymbol('B'), 'C', LString("D"))
```

**Reference:** ABOP Sections 1.6--1.7

## Tropisms

Environmental forces that deflect the turtle's heading after each forward step. The heading is bent toward a tropism vector with configurable strength:

```
H' = normalize(H + e * (H x T))
```

where `H` is heading, `T` is tropism vector, and `e` is strength. Used for gravitropism (drooping branches) and phototropism (growth toward light).

```julia
new_heading, new_up = apply_tropism(heading, up, tropism_vec, strength)
```

**Reference:** ABOP Chapter 3.3

## Space Colonization

Grows tree structures by iteratively extending buds toward scattered attraction points in a 3D envelope. The algorithm:

1. Generate attraction points within a 3D envelope (sphere, cylinder, cone, or crown)
2. Each bud identifies nearby attraction points within its perception volume
3. Buds grow toward the average direction of their associated points
4. Attraction points are removed when a bud grows close enough

```julia
using StableRNGs
rng = StableRNG(42)
points = generate_envelope(:sphere, 500; rng=rng)
tree_segments = space_colonize(points; max_iterations=100, rng=rng)
```

Envelope shapes: `:sphere`, `:cylinder`, `:cone`, `:crown` (hollow sphere).

**Reference:** Runions, Lane & Prusinkiewicz 2007, "Modeling Trees with a Space Colonization Algorithm"

## Weber-Penn Parametric Trees

A parametric tree model using per-level branching parameters for realistic tree generation. Simplified from the original 80+ parameter set to the most impactful controls.

```julia
params = weber_penn_preset(:quaking_aspen)
tree = generate_weber_penn(params; rng=StableRNG(42))
```

Key parameters (per branching level):
- `n_length` -- relative branch length
- `n_curve` -- curvature angle
- `n_branches` -- branch count
- `down_angle` -- angle from parent axis
- `rotate_angle` -- rotation around parent axis

**Reference:** Weber & Penn 1995, "Creation and Rendering of Realistic Trees", SIGGRAPH 1995

## Self-Organizing Trees

Combines L-system growth with space colonization and light competition. Buds have conical perception volumes and compete for resources based on light availability. Low-vigor buds are pruned, producing natural-looking asymmetric crowns.

```julia
grid = LightGrid(20, 10.0)
cast_shadow!(grid, segments)
light = query_light(grid, position)
result = self_organize_tree(; rng=StableRNG(42))
```

**Reference:** Palubicki et al. 2009, "Self-organizing Tree Models for Image Synthesis"

## Pipe Model

Computes realistic branch radii based on the pipe model theory: each leaf is connected to the base by one "pipe", so cross-sectional area at any branching point equals the sum of child cross-sectional areas.

```
r_parent^2 = sum(r_child^2)
```

```julia
tree_nodes = build_tree(segments)
radii = compute_pipe_radii(segments, 0.1)
```

**Reference:** Shinozaki et al. 1964, "A Quantitative Analysis of Plant Form -- the Pipe Model Theory"

## Phyllotaxis

Generates points arranged in a phyllotactic spiral pattern using the golden angle (137.508 degrees), as observed in sunflower heads, pinecones, and succulent rosettes.

```julia
positions = phyllotaxis_positions(1000)
```

The golden angle constant is exported as `GOLDEN_ANGLE`.

**Reference:** Vogel 1979, "A Better Way to Construct the Sunflower Head"

## Level of Detail (LOD)

Generates progressively simplified meshes by reducing radial subdivisions and pruning branches beyond a depth threshold. Useful for rendering plant ecosystems at varying distances.

```julia
lod_meshes = generate_lod(segments; levels=3, base_radius=0.1)
# lod_meshes[1] = full detail
# lod_meshes[2] = medium detail
# lod_meshes[3] = low detail
```

**Reference:** Deussen et al. 2002, "Interactive Visualization of Complex Plant Ecosystems"
