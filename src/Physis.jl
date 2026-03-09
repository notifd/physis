module Physis

using Random

# ── Core L-system types ──────────────────────────────────────────
include("core/symbols.jl")
include("core/rules.jl")
include("core/rewriter.jl")

# ── Turtle interpreters ─────────────────────────────────────────
include("turtle/turtle2d.jl")
include("turtle/turtle3d.jl")

# ── Rendering API (2D) ────────────────────────────────────────
include("render/render_api.jl")

# ── Geometry ──────────────────────────────────────────────────────
include("geometry/mesh.jl")
include("geometry/cylinder.jl")
include("geometry/bbox3d.jl")
include("geometry/tree_mesh.jl")

# ── 3D Rendering + glTF export ───────────────────────────────────
include("render/gltf_export.jl")
include("render/render3d_api.jl")

# ── Species catalog ──────────────────────────────────────────────
include("species/catalog.jl")
include("species/registry.jl")
include("species/fractals/fractal_curves.jl")
include("species/fractals/dragon_family.jl")
include("species/fractals/sierpinski_family.jl")
include("species/fractals/space_filling.jl")
include("species/deciduous/plants_trees.jl")
include("species/fractals/artistic_patterns.jl")

# Re-export public API
export AbstractSymbol, LSymbol, ParametricSymbol, LString
export name, arity, params, matches
export AbstractRule, Rule, ParametricRule, StochasticRule, RuleSet
export rewrite_step, derive, apply_rule
export LineSegment2D, interpret2d
export LineSegment3D, interpret3d
export BoundingBox2D, compute_bbox, render2d, save_render, render_lsystem
export TriangleMesh, cylinder_mesh, merge_meshes, segments_to_mesh
export BoundingBox3D
export export_glb, render_lsystem_3d
export LSystemDef, species_slug, substitute_draw_symbols
export register_species!, get_species, list_species, list_categories

end # module Physis
