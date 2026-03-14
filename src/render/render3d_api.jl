"""
    render3d_api.jl — 3D rendering pipeline for L-systems

Full pipeline: derive → interpret3d → segments_to_mesh → optional export_glb.
"""

# ──────────────────────────────────────────────────────────────────
# render_lsystem_3d — full 3D pipeline
# ──────────────────────────────────────────────────────────────────

"""
    render_lsystem_3d(axiom, ruleset, generations;
                      angle=25.0, step=1.0, width=1.0, step_scale=1.0,
                      base_radius=0.1, taper=0.7, mesh_segments=8,
                      output_path=nothing, color=(0.45, 0.32, 0.18),
                      rng=Random.default_rng()) -> TriangleMesh

Full 3D pipeline: derive → interpret3d → segments_to_mesh → optional GLB export.

Returns the generated `TriangleMesh`. If `output_path` is provided, also
exports the mesh as a binary glTF (.glb) file.

Throws `ArgumentError` if derivation produces no drawable segments.
"""
function render_lsystem_3d(
    axiom::LString,
    ruleset::RuleSet,
    generations::Integer;
    angle::Real=25.0,
    step::Real=1.0,
    width::Real=1.0,
    step_scale::Real=1.0,
    base_radius::Float64=0.1,
    taper::Float64=0.7,
    mesh_segments::Int=8,
    output_path::Union{String, Nothing}=nothing,
    color::Tuple{Real,Real,Real}=(0.45, 0.32, 0.18),
    rng::AbstractRNG=Random.default_rng()
)
    derived = derive(axiom, ruleset, generations; rng=rng)
    segments = interpret3d(derived; angle=angle, step=step, width=width, step_scale=step_scale)

    isempty(segments) && throw(ArgumentError(
        "derivation produced no drawable segments (no F symbols after $generations generations)"))

    mesh = segments_to_mesh(segments; base_radius=base_radius, taper=taper, segments=mesh_segments)

    if output_path !== nothing
        export_glb(output_path, mesh; color=color)
    end

    mesh
end
