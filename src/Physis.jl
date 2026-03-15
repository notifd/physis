module Physis

using Random

# ── Core L-system types ──────────────────────────────────────────
include("core/symbols.jl")
include("core/rules.jl")
include("core/context.jl")
include("core/rewriter.jl")

# ── Turtle interpreters ─────────────────────────────────────────
include("turtle/common.jl")
include("turtle/turtle2d.jl")
include("turtle/turtle3d.jl")
include("turtle/tropisms.jl")

# ── Rendering API (2D) ────────────────────────────────────────
include("render/render_api.jl")

# ── Geometry ──────────────────────────────────────────────────────
include("geometry/mesh.jl")
include("geometry/cylinder.jl")
include("geometry/bbox3d.jl")
include("geometry/leaf.jl")
include("geometry/flower.jl")
include("geometry/fruit.jl")
include("geometry/tree_mesh.jl")
include("geometry/lod.jl")

# ── Algorithms ─────────────────────────────────────────────────────
include("algorithms/tree_topology.jl")
include("algorithms/pipe_model.jl")
include("algorithms/phyllotaxis.jl")
include("algorithms/space_colonization.jl")
include("algorithms/weber_penn.jl")
include("algorithms/self_organizing.jl")

# ── 3D Rendering + glTF export ───────────────────────────────────
include("render/gltf_export.jl")
include("render/render3d_api.jl")

# ── Blender Cycles integration ────────────────────────────────────
include("blender/render.jl")

# ── Species catalog ──────────────────────────────────────────────
include("species/catalog.jl")
include("species/registry.jl")
include("species/fractals/fractal_curves.jl")
include("species/fractals/dragon_family.jl")
include("species/fractals/sierpinski_family.jl")
include("species/fractals/space_filling.jl")
include("species/deciduous/plants_trees.jl")
include("species/fractals/artistic_patterns.jl")
include("species/coniferous/coniferous.jl")
include("species/ferns/ferns.jl")
include("species/tropical/tropical.jl")
include("species/flowers/flowers.jl")
include("species/grasses/grasses.jl")
include("species/succulents/succulents.jl")
include("species/aquatic/aquatic.jl")
include("species/vines/vines.jl")
include("species/shrubs/shrubs.jl")

# ── Growth animation ─────────────────────────────────────────────
include("render/animation.jl")

# Re-export public API
export AbstractSymbol, LSymbol, ParametricSymbol, LString
export name, arity, params, matches
export AbstractRule, Rule, ParametricRule, StochasticRule, ContextRule, RuleSet
export rewrite_step, derive, apply_rule
export LineSegment2D, interpret2d
export LineSegment3D, interpret3d
export BoundingBox2D, compute_bbox, render2d, save_render, render_lsystem
export TriangleMesh, cylinder_mesh, merge_meshes, segments_to_mesh, generate_lod
export leaf_mesh, flower_mesh, petal_mesh, sphere_mesh, cone_mesh
export OrganPlacement, build_tree_with_organs
export TreeNode, build_tree, compute_pipe_radii
export GOLDEN_ANGLE, phyllotaxis_positions
export BoundingBox3D
export export_glb, render_lsystem_3d
export LSystemDef, species_slug, substitute_draw_symbols
export register_species!, get_species, list_species, list_categories
export apply_tropism
export generate_envelope, space_colonize, TreeBud
export WeberPennParams, weber_penn_preset, generate_weber_penn
export LightGrid, cast_shadow!, query_light, self_organize_tree
export find_blender, generate_blender_script, render_photorealistic, render_species_photorealistic
export animate_growth

end # module Physis
