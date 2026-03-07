"""
    turtle2d.jl — 2D turtle graphics interpreter for L-strings

Converts an LString into a list of line segments by interpreting symbols
as turtle commands: forward, turn, push/pop branch state.

Reference: ABOP §1.5 (Graphical interpretation of strings)
"""

using StaticArrays

# ──────────────────────────────────────────────────────────────────
# Types
# ──────────────────────────────────────────────────────────────────

"""
    LineSegment2D(start, stop)

A 2D line segment from `start` to `stop`, both `SVector{2,Float64}`.
"""
struct LineSegment2D
    start::SVector{2, Float64}
    stop::SVector{2, Float64}
end

Base.:(==)(a::LineSegment2D, b::LineSegment2D) = a.start == b.start && a.stop == b.stop

"""
    TurtleState2D

Internal mutable state for the 2D turtle interpreter.
Position and heading (in radians, counter-clockwise from +x axis).
"""
mutable struct TurtleState2D
    pos::SVector{2, Float64}
    heading::Float64   # radians, CCW from +x
    step::Float64
end

function TurtleState2D(; step::Float64=1.0)
    TurtleState2D(SVector(0.0, 0.0), π / 2, step)  # default heading up
end

Base.copy(t::TurtleState2D) = TurtleState2D(t.pos, t.heading, t.step)

# ──────────────────────────────────────────────────────────────────
# Interpreter
# ──────────────────────────────────────────────────────────────────

"""
    interpret2d(ls::LString; angle=25.0, step=1.0) -> Vector{LineSegment2D}

Interpret an L-string as 2D turtle graphics commands, returning line segments.

# Symbol commands
- `F` / `F(d)` — move forward by `step` (or `d`), drawing a line
- `f` / `f(d)` — move forward without drawing
- `+` / `+(a)` — turn left by `angle` degrees (or `a` degrees)
- `-` / `-(a)` — turn right by `angle` degrees (or `a` degrees)
- `[` — push turtle state onto branch stack
- `]` — pop turtle state from branch stack
- All other symbols — ignored

# Arguments
- `angle`: default turn angle in degrees (default 25.0)
- `step`: default forward step size (default 1.0)

Reference: ABOP §1.5
"""
function interpret2d(ls::LString; angle::Real=25.0, step::Real=1.0)
    turtle = TurtleState2D(; step=Float64(step))
    angle_rad = deg2rad(Float64(angle))
    stack = TurtleState2D[]
    segments = LineSegment2D[]

    for sym in ls
        c = name(sym)
        if c == 'F'
            d = _get_step(sym, turtle.step)
            new_pos = turtle.pos + SVector(d * cos(turtle.heading), d * sin(turtle.heading))
            push!(segments, LineSegment2D(turtle.pos, new_pos))
            turtle.pos = new_pos
        elseif c == 'f'
            d = _get_step(sym, turtle.step)
            turtle.pos = turtle.pos + SVector(d * cos(turtle.heading), d * sin(turtle.heading))
        elseif c == '+'
            a = _get_angle(sym, angle_rad)
            turtle.heading += a
        elseif c == '-'
            a = _get_angle(sym, angle_rad)
            turtle.heading -= a
        elseif c == '['
            push!(stack, copy(turtle))
        elseif c == ']'
            isempty(stack) && throw(ArgumentError("unmatched ']': no state to pop from branch stack"))
            restored = pop!(stack)
            turtle.pos = restored.pos
            turtle.heading = restored.heading
            turtle.step = restored.step
        end
        # All other symbols: no-op
    end

    segments
end

# ──────────────────────────────────────────────────────────────────
# Internal helpers
# ──────────────────────────────────────────────────────────────────

"""Extract step distance from a parametric symbol, or use default."""
_get_step(::LSymbol, default::Float64) = default
_get_step(sym::ParametricSymbol, default::Float64) = sym.params[1]

"""Extract angle (converting degrees → radians) from a parametric symbol, or use default (already radians)."""
_get_angle(::LSymbol, default_rad::Float64) = default_rad
_get_angle(sym::ParametricSymbol, ::Float64) = deg2rad(sym.params[1])
