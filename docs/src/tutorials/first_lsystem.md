# Your First L-System

This tutorial walks through building a Koch curve L-system from scratch, deriving it, and interpreting the result with the turtle.

## What is an L-System?

An L-system (Lindenmayer system) is a parallel string rewriting system. You start with an initial string (the **axiom**), apply **production rules** simultaneously to every symbol, and repeat for multiple **generations**. The resulting string is then interpreted geometrically by a **turtle**.

## Step 1: Define the Axiom

The axiom is the initial string at generation 0. For the Koch curve, we start with a single forward-drawing symbol `F`:

```julia
using Physis

axiom = LString("F")
```

`LString("F")` creates an L-string containing one `LSymbol('F')`.

## Step 2: Define the Rules

The Koch curve has one rule: replace each `F` with `F+F--F+F`, where `+` turns left and `-` turns right:

```julia
rules = RuleSet([
    Rule(LSymbol('F'), LString("F+F--F+F"))
])
```

- `Rule` is a deterministic, context-free production (D0L).
- `RuleSet` indexes rules by their left-hand-side character for fast lookup.

## Step 3: Derive

Apply the rules for multiple generations. Each generation replaces every `F` in the current string with the right-hand side:

```julia
# Generation 0: F
# Generation 1: F+F--F+F
# Generation 2: F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F
result = derive(axiom, rules, 4)

println("Length after 4 generations: ", length(result))
```

The string grows exponentially -- generation `n` has `4^n` `F` symbols.

## Step 4: Interpret with the 2D Turtle

The turtle interprets each symbol as a command:
- `F` -- move forward, drawing a line
- `+` -- turn left by the angle
- `-` -- turn right by the angle
- `[` -- push state (save position and heading)
- `]` -- pop state (restore position and heading)

```julia
segments = interpret2d(result; angle=60.0)
println("Number of line segments: ", length(segments))
```

Each `LineSegment2D` has a `start` and `stop` field (both `SVector{2, Float64}`).

## Step 5: Render (Optional)

If you have CairoMakie available, you can render to SVG:

```julia
using CairoMakie
render_lsystem(axiom, rules, 4; angle=60.0, output="koch.svg")
```

## Exploring Further

### Try Different Plants

The classic ABOP plant uses branching (`[` and `]`):

```julia
axiom = LString("F")
rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))])
segments = interpret2d(derive(axiom, rules, 5); angle=25.7)
```

### Use a Predefined Species

Physis ships with 127 species ready to use:

```julia
species = get_species("Koch Curve")
result = derive(species.axiom, species.rules, species.generations)
segments = interpret2d(result; angle=species.angle)
```

### 3D Interpretation

Switch to the 3D turtle for three-dimensional structures:

```julia
segments_3d = interpret3d(result; angle=25.7)
```

The 3D turtle uses additional symbols: `&` (pitch down), `^` (pitch up), `\\` (roll left), `/` (roll right).

### Stochastic Variation

Add randomness for natural-looking plants:

```julia
using StableRNGs

rules = RuleSet([
    StochasticRule(
        LSymbol('F'),
        [0.5, 0.5],
        [LString("F[+F]F[-F]F"), LString("F[+F]F")]
    )
])

rng = StableRNG(42)
result = derive(LString("F"), rules, 4; rng=rng)
```

Use `StableRNG` for reproducible results across Julia versions.
