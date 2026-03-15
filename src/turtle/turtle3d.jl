"""
    turtle3d.jl — 3D turtle graphics interpreter for L-strings

Converts an LString into a list of 3D line segments by interpreting symbols
as turtle commands: forward, yaw, pitch, roll, push/pop branch state.

The turtle carries a local coordinate frame (H, L, U) — heading, left, up —
and rotates using Rodrigues' formula per ABOP §1.5.3.

Reference: ABOP §1.5.3 (Three-dimensional interpretation)
"""

using StaticArrays
using LinearAlgebra

# ──────────────────────────────────────────────────────────────────
# Types
# ──────────────────────────────────────────────────────────────────

"""
    LineSegment3D(start, stop, width, depth=0)

A 3D line segment from `start` to `stop`, both `SVector{3,Float64}`,
with a `width` for rendering thickness and `depth` for branch stack depth
(0 = trunk, increments on `[`).
"""
struct LineSegment3D
    start::SVector{3, Float64}
    stop::SVector{3, Float64}
    width::Float64
    depth::Int
end

# Backward-compatible 3-arg constructor (depth defaults to 0)
LineSegment3D(start::SVector{3,Float64}, stop::SVector{3,Float64}, width::Float64) =
    LineSegment3D(start, stop, width, 0)

Base.:(==)(a::LineSegment3D, b::LineSegment3D) =
    a.start == b.start && a.stop == b.stop && a.width == b.width && a.depth == b.depth
Base.hash(s::LineSegment3D, h::UInt) =
    hash(s.depth, hash(s.width, hash(s.stop, hash(s.start, hash(:LineSegment3D, h)))))
Base.isapprox(a::LineSegment3D, b::LineSegment3D; kwargs...) =
    isapprox(a.start, b.start; kwargs...) && isapprox(a.stop, b.stop; kwargs...) &&
    isapprox(a.width, b.width; kwargs...) && a.depth == b.depth

function Base.show(io::IO, s::LineSegment3D)
    print(io, "(", s.start[1], ",", s.start[2], ",", s.start[3],
          ")→(", s.stop[1], ",", s.stop[2], ",", s.stop[3], ")")
end

# ──────────────────────────────────────────────────────────────────
# Turtle state
# ──────────────────────────────────────────────────────────────────

"""
    TurtleState3D

Internal mutable state for the 3D turtle interpreter.
Carries position and a local coordinate frame (H, L, U).
"""
mutable struct TurtleState3D
    pos::SVector{3, Float64}
    heading::SVector{3, Float64}  # H — direction of movement
    left::SVector{3, Float64}     # L — left direction
    up::SVector{3, Float64}       # U — up direction
    step::Float64
    width::Float64
    depth::Int                    # Branch stack depth (0 = trunk)
end

"""
    TurtleState3D(; step=1.0, width=1.0)

Create a 3D turtle at the origin facing up along the Y axis.
Default frame: H=(0,1,0), L=(-1,0,0), U=(0,0,1).
"""
function TurtleState3D(; step::Float64=1.0, width::Float64=1.0)
    TurtleState3D(
        SVector(0.0, 0.0, 0.0),
        SVector(0.0, 1.0, 0.0),
        SVector(-1.0, 0.0, 0.0),
        SVector(0.0, 0.0, 1.0),
        step, width, 0
    )
end

Base.copy(t::TurtleState3D) = TurtleState3D(t.pos, t.heading, t.left, t.up, t.step, t.width, t.depth)

# ──────────────────────────────────────────────────────────────────
# Rotation helpers
# ──────────────────────────────────────────────────────────────────

"""
    _rotate_vector(v, axis, angle_rad)

Rotate vector `v` around `axis` by `angle_rad` using Rodrigues' formula.
"""
function _rotate_vector(v::SVector{3,Float64}, axis::SVector{3,Float64}, angle_rad::Float64)
    c = cos(angle_rad)
    s = sin(angle_rad)
    v * c + cross(axis, v) * s + axis * dot(axis, v) * (1 - c)
end

"""
    _reorthonormalize!(turtle)

Gram-Schmidt re-orthonormalization to prevent floating-point drift
in the turtle's coordinate frame.
"""
function _reorthonormalize!(turtle::TurtleState3D)
    turtle.heading = normalize(turtle.heading)
    turtle.left = normalize(turtle.left - dot(turtle.left, turtle.heading) * turtle.heading)
    turtle.up = cross(turtle.heading, turtle.left)
    nothing
end

# ──────────────────────────────────────────────────────────────────
# Interpreter
# ──────────────────────────────────────────────────────────────────

"""
    interpret3d(ls::LString; angle=25.0, step=1.0, width=1.0, step_scale=1.0,
                collect_organs=false, tropism=nothing, tropism_strength=0.0)

Interpret an L-string as 3D turtle graphics commands, returning line segments.

# Symbol commands (ABOP §1.5.3)
- `F` / `F(d)` — move forward by `step` (or `d`), drawing a line
- `f` / `f(d)` — move forward without drawing
- `+` / `+(a)` — yaw left by `angle` (or `a`) degrees (rotate around U)
- `-` / `-(a)` — yaw right (rotate around U)
- `&` / `&(a)` — pitch down (rotate around L)
- `^` / `^(a)` — pitch up (rotate around L)
- `\\` / `\\(a)` — roll left (rotate around H)
- `/` / `/(a)` — roll right (rotate around H)
- `|` — turn around (180° yaw)
- `"` — multiply step length by `step_scale` (Houdini length scaling)
- `[` — push turtle state onto branch stack
- `]` — pop turtle state from branch stack
- `L` — record leaf organ placement (only when `collect_organs=true`)
- `K` — record flower organ placement (only when `collect_organs=true`)
- `Q` — record fruit organ placement (only when `collect_organs=true`)
- All other symbols — ignored

# Returns
- When `collect_organs=false` (default): `Vector{LineSegment3D}`
- When `collect_organs=true`: `Tuple{Vector{LineSegment3D}, Vector{OrganPlacement}}`

# Arguments
- `angle`: default rotation angle in degrees (default 25.0)
- `step`: default forward step size (default 1.0)
- `width`: default line width (default 1.0)
- `step_scale`: multiplier applied to step when `"` is encountered (default 1.0)
- `collect_organs`: whether to collect L/K/Q symbols as OrganPlacement (default false)
- `tropism`: tropism direction vector, e.g. `SVector(0.0,-1.0,0.0)` for gravity (default nothing)
- `tropism_strength`: strength of tropism effect applied after each F step (default 0.0)

Reference: ABOP §1.5.3, §3.3; Houdini L-System documentation (SideFX)
"""
function interpret3d(ls::LString; angle::Real=25.0, step::Real=1.0, width::Real=1.0,
                     step_scale::Real=1.0, collect_organs::Bool=false,
                     tropism::Union{SVector{3,Float64}, Nothing}=nothing,
                     tropism_strength::Real=0.0)
    turtle = TurtleState3D(; step=Float64(step), width=Float64(width))
    angle_rad = deg2rad(Float64(angle))
    scale = Float64(step_scale)
    tropism_strength_f = Float64(tropism_strength)
    stack = TurtleState3D[]
    segments = LineSegment3D[]
    sizehint!(segments, count(s -> name(s) == 'F', ls))

    organs = collect_organs ? OrganPlacement[] : nothing

    step_count = 0
    reorth_interval = 100

    for sym in ls
        c = name(sym)
        if c == 'F'
            d = _get_step(sym, turtle.step)
            new_pos = turtle.pos + d * turtle.heading
            push!(segments, LineSegment3D(turtle.pos, new_pos, turtle.width, turtle.depth))
            turtle.pos = new_pos
            # Apply tropism after forward step
            if tropism !== nothing && tropism_strength_f > 0.0
                new_h, new_u = apply_tropism(turtle.heading, turtle.up, tropism, tropism_strength_f)
                turtle.heading = new_h
                turtle.up = new_u
                turtle.left = cross(turtle.up, turtle.heading)
            end
        elseif c == 'f'
            d = _get_step(sym, turtle.step)
            turtle.pos = turtle.pos + d * turtle.heading
        elseif c == '+'
            a = _get_angle(sym, angle_rad)
            turtle.heading = _rotate_vector(turtle.heading, turtle.up, a)
            turtle.left = _rotate_vector(turtle.left, turtle.up, a)
            step_count += 1
        elseif c == '-'
            a = _get_angle(sym, angle_rad)
            turtle.heading = _rotate_vector(turtle.heading, turtle.up, -a)
            turtle.left = _rotate_vector(turtle.left, turtle.up, -a)
            step_count += 1
        elseif c == '&'
            a = _get_angle(sym, angle_rad)
            turtle.heading = _rotate_vector(turtle.heading, turtle.left, a)
            turtle.up = _rotate_vector(turtle.up, turtle.left, a)
            step_count += 1
        elseif c == '^'
            a = _get_angle(sym, angle_rad)
            turtle.heading = _rotate_vector(turtle.heading, turtle.left, -a)
            turtle.up = _rotate_vector(turtle.up, turtle.left, -a)
            step_count += 1
        elseif c == '\\'
            a = _get_angle(sym, angle_rad)
            turtle.left = _rotate_vector(turtle.left, turtle.heading, a)
            turtle.up = _rotate_vector(turtle.up, turtle.heading, a)
            step_count += 1
        elseif c == '/'
            a = _get_angle(sym, angle_rad)
            turtle.left = _rotate_vector(turtle.left, turtle.heading, -a)
            turtle.up = _rotate_vector(turtle.up, turtle.heading, -a)
            step_count += 1
        elseif c == '|'
            turtle.heading = _rotate_vector(turtle.heading, turtle.up, Float64(π))
            turtle.left = _rotate_vector(turtle.left, turtle.up, Float64(π))
            step_count += 1
        elseif c == '"'
            turtle.step *= scale
        elseif c == '['
            push!(stack, copy(turtle))
            turtle.depth += 1
        elseif c == ']'
            isempty(stack) && throw(ArgumentError("unmatched ']': no state to pop from branch stack"))
            restored = pop!(stack)
            turtle.pos = restored.pos
            turtle.heading = restored.heading
            turtle.left = restored.left
            turtle.up = restored.up
            turtle.step = restored.step
            turtle.width = restored.width
            turtle.depth = restored.depth
        elseif collect_organs && c == 'L'
            push!(organs, OrganPlacement(
                turtle.pos, turtle.heading, turtle.up, turtle.left, :leaf, turtle.width))
        elseif collect_organs && c == 'K'
            push!(organs, OrganPlacement(
                turtle.pos, turtle.heading, turtle.up, turtle.left, :flower, turtle.width))
        elseif collect_organs && c == 'Q'
            push!(organs, OrganPlacement(
                turtle.pos, turtle.heading, turtle.up, turtle.left, :fruit, turtle.width))
        end

        # Re-orthonormalize periodically to prevent drift
        if step_count >= reorth_interval
            _reorthonormalize!(turtle)
            step_count = 0
        end
    end

    collect_organs ? (segments, organs) : segments
end
