# Photorealistic Renders

This tutorial shows how to produce photorealistic renders of L-system plants using Blender Cycles.

## Prerequisites

1. **Blender 3.0+** installed on your system
2. Physis will search for Blender in this order:
   - `ENV["BLENDER_PATH"]` environment variable
   - Platform-specific default paths (e.g. `/Applications/Blender.app/Contents/MacOS/Blender` on macOS)
   - `blender` on your system `PATH`

Verify Blender is found:

```julia
using Physis

blender_path = find_blender()
if blender_path === nothing
    error("Blender not found. Set BLENDER_PATH environment variable.")
end
println("Found Blender at: ", blender_path)
```

## Step 1: Generate a GLB Model

First, generate a 3D model as a GLB (binary glTF) file:

```julia
using Physis

# Using a predefined species
species = get_species("Plant 1 (ABOP 1.24a)")
result = derive(species.axiom, species.rules, species.generations)
segments = interpret3d(result; angle=species.angle)
mesh = segments_to_mesh(segments; base_radius=0.05, taper=0.7)
export_glb(mesh, "plant.glb")
```

Or use the convenience pipeline:

```julia
mesh = render_lsystem_3d(
    species.axiom, species.rules, species.generations;
    angle=species.angle,
    output_path="plant.glb"
)
```

## Step 2: Render with Blender Cycles

Use `render_photorealistic` to invoke Blender headless with a Cycles render script:

```julia
render_photorealistic(
    "plant.glb",
    "plant_render.png";
    samples=128,
    resolution=(1920, 1080),
)
```

This generates a Blender Python script from the built-in template, imports the GLB, sets up lighting and camera, and renders with Cycles.

## Step 3: Render a Species Directly

The `render_species_photorealistic` function wraps the entire pipeline -- derive, interpret, mesh, export, and render -- in one call:

```julia
render_species_photorealistic(
    "Plant 1 (ABOP 1.24a)",
    "plant1_photo.png";
    samples=256,
    resolution=(1920, 1080),
)
```

## Customization

### Blender Script Generation

For advanced control, generate the Blender script without running it:

```julia
script = generate_blender_script(
    "plant.glb",
    "plant_render.png";
    samples=128,
    resolution=(1920, 1080),
)

# Save and run manually
write("render_script.py", script)
# Then: blender --background --python render_script.py
```

### Mesh Parameters

Control the 3D mesh quality before rendering:

```julia
# Higher quality mesh
mesh = segments_to_mesh(segments;
    base_radius=0.05,
    taper=0.7,
    mesh_segments=12,        # More radial subdivisions
    radius_mode=:pipe_model, # Realistic branch radii
)
```

### Adding Organs

Build trees with leaves, flowers, and fruits:

```julia
tree_mesh = build_tree_with_organs(segments;
    base_radius=0.05,
    leaf_placements=[OrganPlacement(...)],
)
```

## Troubleshooting

- **"Blender not found"** -- Set the `BLENDER_PATH` environment variable to the full path of your Blender executable.
- **Render is dark** -- Increase `samples` for better convergence, or check that the GLB model has reasonable scale.
- **Slow renders** -- Reduce `resolution` or `samples` for preview renders. Use GPU rendering in Blender preferences.
- **Missing textures** -- The photorealistic template includes procedural materials. No external textures are needed.
