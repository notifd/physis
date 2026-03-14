# Shader Design — Photorealistic Blender Cycles Renders

## Why Procedural Over Image Textures

- Resolution-independent: no texture resolution limits at any zoom level
- No asset management: no texture files to ship, load, or path-manage
- Parameterizable per species: the same node graph with different parameters produces bark, foliage, moss, etc.
- Reproducible: deterministic output from the same parameters

## Vertex-Color Encoding Scheme

The geometry pipeline encodes branch depth into per-vertex colors exported as `COLOR_0` in the GLB:

| Channel | Encoding | Range |
|---------|----------|-------|
| R | Normalized branch depth | 0.0 (trunk) → 1.0 (deepest twig) |
| G | Reserved (currently 1.0) | Could encode segment width |
| B | Reserved (currently 0.0) | — |
| A | Opaque | Always 1.0 |

Depth is tracked via `[`/`]` stack operations in the 3D turtle interpreter. The `LineSegment3D` struct carries a `depth::Int` field. At mesh generation time, depths are normalized to [0,1] against the maximum depth in the tree.

Blender imports `COLOR_0` as a vertex color layer named `"Col"`. The shader reads this via `ShaderNodeVertexColor` and uses the R channel as a blending factor between trunk and twig materials.

## Height-Gradient Principle

Object-space Z position is mapped to [0,1] via `ShaderNodeMapRange` using the scene bounding box. A `ColorRamp` then maps this to a darkening/lightening multiplier:

- **Base (Z=0)**: darkened by `base_darken` factor (0.5 for bark, 0.6 for foliage)
- **Tips (Z=1)**: lightened by `tip_lighten` factor (1.3 for bark, 1.5 for foliage)

This mimics real trees where the base is darker (soil contact, moisture, shadow) and tips are lighter (sun exposure, new growth).

## Multi-Layer Material Strategy

### Layer 1 — Base Color
`bark_color × noise_pattern × height_gradient`

Two procedural noise textures (large-scale crevices + fine-grain) are mixed 70/30, then multiplied with the species base color and height gradient.

### Layer 2 — Branch Depth Tinting
The vertex color R channel blends between the base color (trunk) and a computed tip tint (lighter, shifted green). Twigs appear visually distinct from the main trunk.

### Layer 3 — Moss Overlay (bark only)
A Voronoi texture masked to the lower 35% of the tree height adds a green moss overlay using the OVERLAY blend mode. This is disabled for foliage material type.

### Surface Detail
- **Roughness**: noise-driven, mapped from `roughness_min` to `roughness_max`
- **Bump**: noise-driven displacement for surface texture
- **Subsurface scattering**: depth-dependent — twigs get more SSS than trunk
- **Specular IOR**: tuned per material type (bark=0.3, foliage=0.5)

## Material Types

Two parameter sets drive the same shader graph:

| Parameter | Bark | Foliage |
|-----------|------|---------|
| Large noise scale | 4.0 | 8.0 |
| Fine noise scale | 15.0 | 25.0 |
| Distortion | 1.5 | 0.5 |
| Roughness range | 0.65–0.95 | 0.35–0.65 |
| Bump strength | 0.4 | 0.15 |
| SSS weight | 0.05 | 0.2 |
| Moss | Yes (lower 35%) | No |

Auto-classification: `glb_color` green channel > 0.35 → foliage, else bark.

## Lighting Philosophy

Three-point lighting separates the subject from the background:

1. **Key Sun**: `energy=3.0`, 1° angle (sharp shadows), slightly warm (1.0, 0.98, 0.95), 50° elevation
2. **Fill Area**: `energy=50.0`, large area light (2× max_dim), cool sky bounce (0.85, 0.9, 1.0), opposite camera
3. **Rim Spot**: `energy=100.0`, 45° cone, warm backlight (1.0, 0.95, 0.85), behind and above subject

Plus a Hosek-Wilkie procedural sky and volumetric scatter (density=0.005) for atmospheric haze.

## Camera

- 50mm lens, 30° elevation
- DOF enabled: f/4.0, focused on scene center
- Auto-framing via `camera_distance_factor × max_dim`
