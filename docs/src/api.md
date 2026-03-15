# API Reference

## Core Types

### Symbols

```@docs
AbstractSymbol
LSymbol
ParametricSymbol
LString
name
arity
params
matches
```

### Rules

```@docs
AbstractRule
Rule
ParametricRule
StochasticRule
ContextRule
RuleSet
```

### Derivation

```@docs
rewrite_step
derive
apply_rule
```

## Turtle Interpreters

### 2D Turtle

```@docs
LineSegment2D
interpret2d
```

### 3D Turtle

```@docs
LineSegment3D
interpret3d
```

### Tropisms

```@docs
apply_tropism
```

## Rendering

### 2D Rendering

```@docs
BoundingBox2D
compute_bbox
render2d
save_render
render_lsystem
```

### 3D Rendering

```@docs
BoundingBox3D
render_lsystem_3d
export_glb
```

### Animation

```@docs
animate_growth
```

## Geometry

### Mesh Types

```@docs
TriangleMesh
```

### Mesh Generation

```@docs
cylinder_mesh
merge_meshes
segments_to_mesh
leaf_mesh
flower_mesh
petal_mesh
sphere_mesh
cone_mesh
```

### Tree Organs

```@docs
OrganPlacement
build_tree_with_organs
```

### Level of Detail

```@docs
generate_lod
```

## Tree Topology

```@docs
TreeNode
build_tree
compute_pipe_radii
```

## Algorithms

### Phyllotaxis

```@docs
GOLDEN_ANGLE
phyllotaxis_positions
```

### Space Colonization

```@docs
generate_envelope
space_colonize
TreeBud
```

### Weber-Penn Trees

```@docs
WeberPennParams
weber_penn_preset
generate_weber_penn
```

### Self-Organizing Trees

```@docs
LightGrid
cast_shadow!
query_light
self_organize_tree
```

## Species Catalog

```@docs
LSystemDef
species_slug
substitute_draw_symbols
register_species!
get_species
list_species
list_categories
```

## Blender Integration

```@docs
find_blender
generate_blender_script
render_photorealistic
render_species_photorealistic
```
