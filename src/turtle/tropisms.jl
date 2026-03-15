"""
    tropisms.jl — Environmental tropism forces for 3D turtle

Implements tropism bending that modifies the turtle's heading after each
forward step, simulating gravitropism, phototropism, etc.

H' = normalize(H + e × (H × T))

where H is heading, T is tropism vector, e is strength.

Reference: ABOP Ch. 3.3 "Tropisms"
"""

using StaticArrays
using LinearAlgebra

"""
    apply_tropism(heading, up, tropism_vec, strength) -> (new_heading, new_up)

Apply tropism force to the turtle's heading. The torque axis is H × T,
and the heading is rotated toward T by an amount proportional to `strength`.

Returns the new heading and up vectors (re-orthonormalized).

Reference: ABOP Ch. 3.3, equation H' = normalize(H + e × (H × T))
"""
function apply_tropism(heading::SVector{3,Float64}, up::SVector{3,Float64},
                       tropism_vec::SVector{3,Float64}, strength::Float64)
    strength == 0.0 && return (heading, up)

    # Torque axis: H × T
    torque = cross(heading, tropism_vec)
    torque_len = norm(torque)
    torque_len < 1e-14 && return (heading, up)  # H parallel to T, no effect

    # Apply rotation: H' = normalize(H + e * (H × T))
    new_heading = heading + strength * torque
    new_heading = normalize(new_heading)

    # Re-derive up to maintain orthogonality
    # Project out heading component from up
    new_up = up - dot(up, new_heading) * new_heading
    up_len = norm(new_up)
    new_up = up_len > 1e-14 ? new_up / up_len : SVector(0.0, 0.0, 1.0)

    (new_heading, new_up)
end
