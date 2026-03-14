"""
Blender Cycles photorealistic render script for Physis L-system plants.

Placeholders (replaced by Julia before execution):
    {{GLB_PATH}}                — absolute path to input .glb file
    {{OUTPUT_PATH}}             — absolute path to output .png file
    {{RESOLUTION_X}}            — render width in pixels
    {{RESOLUTION_Y}}            — render height in pixels
    {{SAMPLES}}                 — Cycles render samples
    {{CAMERA_DISTANCE_FACTOR}}  — multiplier for auto-framing distance
    {{BARK_COLOR_R}}            — bark base color red (0-1)
    {{BARK_COLOR_G}}            — bark base color green (0-1)
    {{BARK_COLOR_B}}            — bark base color blue (0-1)
    {{GROUND_PLANE}}            — True/False for ground plane
    {{MATERIAL_TYPE}}           — "bark" or "foliage"

Designed for Blender 5.0+ with Cycles METAL/OPTIX/CUDA or CPU fallback.
"""

import bpy
import math
import sys
from mathutils import Vector

# ── Material parameters ──────────────────────────────────────────────

MATERIAL_PARAMS = {
    "bark": {
        "noise_scale_large": 4.0,
        "noise_detail_large": 8.0,
        "noise_distortion": 1.5,
        "noise_scale_fine": 15.0,
        "noise_detail_fine": 12.0,
        "mapping_scale": (3.0, 3.0, 8.0),
        "base_darken": 0.5,
        "tip_lighten": 1.3,
        "roughness_min": 0.65,
        "roughness_max": 0.95,
        "bump_strength": 0.4,
        "bump_distance": 0.02,
        "subsurface_weight": 0.05,
        "subsurface_radius": (0.3, 0.1, 0.05),
        "specular_ior": 0.3,
        "moss_enabled": True,
        "moss_height_max": 0.35,
        "moss_color": (0.15, 0.35, 0.1, 1.0),
        "moss_blend": 0.6,
    },
    "foliage": {
        "noise_scale_large": 8.0,
        "noise_detail_large": 6.0,
        "noise_distortion": 0.5,
        "noise_scale_fine": 25.0,
        "noise_detail_fine": 10.0,
        "mapping_scale": (5.0, 5.0, 5.0),
        "base_darken": 0.6,
        "tip_lighten": 1.5,
        "roughness_min": 0.35,
        "roughness_max": 0.65,
        "bump_strength": 0.15,
        "bump_distance": 0.01,
        "subsurface_weight": 0.2,
        "subsurface_radius": (0.5, 0.3, 0.1),
        "specular_ior": 0.5,
        "moss_enabled": False,
        "moss_height_max": 0.0,
        "moss_color": (0.0, 0.0, 0.0, 0.0),
        "moss_blend": 0.0,
    },
}

material_type = "{{MATERIAL_TYPE}}"
params = MATERIAL_PARAMS.get(material_type, MATERIAL_PARAMS["bark"])

# ── 1. Clear scene ──────────────────────────────────────────────────

bpy.ops.wm.read_factory_settings(use_empty=True)

# ── 2. Import GLB ──────────────────────────────────────────────────

glb_path = r"{{GLB_PATH}}"
bpy.ops.import_scene.gltf(filepath=glb_path)

# ── 3. Configure Cycles ────────────────────────────────────────────

scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = {{SAMPLES}}
scene.cycles.use_denoising = True

# GPU auto-detect: try METAL (Apple), then OPTIX/CUDA (NVIDIA), then CPU
prefs = bpy.context.preferences.addons["cycles"].preferences
gpu_found = False
for compute_type in ["METAL", "OPTIX", "CUDA"]:
    try:
        prefs.compute_device_type = compute_type
        prefs.get_devices()
        devices = prefs.devices
        if devices:
            for d in devices:
                d.use = True
            scene.cycles.device = "GPU"
            gpu_found = True
            print(f"Cycles: using {compute_type} GPU")
            break
    except Exception:
        continue

if not gpu_found:
    scene.cycles.device = "CPU"
    print("Cycles: falling back to CPU")

# ── 4. Calculate bounding box ───────────────────────────────────────

imported_objects = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]

if not imported_objects:
    print("ERROR: No mesh objects found after GLB import", file=sys.stderr)
    sys.exit(1)

# Compute combined bounding box in world space
bbox_min = Vector((float("inf"), float("inf"), float("inf")))
bbox_max = Vector((float("-inf"), float("-inf"), float("-inf")))

for obj in imported_objects:
    for corner in obj.bound_box:
        world_corner = obj.matrix_world @ Vector(corner)
        bbox_min.x = min(bbox_min.x, world_corner.x)
        bbox_min.y = min(bbox_min.y, world_corner.y)
        bbox_min.z = min(bbox_min.z, world_corner.z)
        bbox_max.x = max(bbox_max.x, world_corner.x)
        bbox_max.y = max(bbox_max.y, world_corner.y)
        bbox_max.z = max(bbox_max.z, world_corner.z)

center = (bbox_min + bbox_max) / 2.0
size = bbox_max - bbox_min
max_dim = max(size.x, size.y, size.z, 0.001)

# ── 5. Camera with DOF ─────────────────────────────────────────────

camera_distance_factor = {{CAMERA_DISTANCE_FACTOR}}
distance = max_dim * camera_distance_factor

cam_data = bpy.data.cameras.new("PhysisCamera")
cam_data.lens = 50
cam_obj = bpy.data.objects.new("PhysisCamera", cam_data)
bpy.context.collection.objects.link(cam_obj)
scene.camera = cam_obj

# Position camera at 30 deg elevation, looking at center
elevation_angle = math.radians(30)
cam_x = center.x + distance * math.cos(elevation_angle) * 0.7
cam_y = center.y - distance * math.cos(elevation_angle) * 0.7
cam_z = center.z + distance * math.sin(elevation_angle)
cam_obj.location = (cam_x, cam_y, cam_z)

# Focus target empty at center
empty = bpy.data.objects.new("CameraTarget", None)
empty.location = center
bpy.context.collection.objects.link(empty)

# Point camera at center using track-to constraint
track = cam_obj.constraints.new(type="TRACK_TO")
track.target = empty
track.track_axis = "TRACK_NEGATIVE_Z"
track.up_axis = "UP_Y"

# Depth of field
cam_data.dof.use_dof = True
cam_data.dof.focus_object = empty
cam_data.dof.aperture_fstop = 4.0

# ── 6. Three-point lighting ────────────────────────────────────────

# 6a. Key light (Sun lamp) — sharp shadows, slightly warm
sun_data = bpy.data.lights.new("KeySun", "SUN")
sun_data.energy = 3.0
sun_data.angle = math.radians(1.0)
sun_data.color = (1.0, 0.98, 0.95)
sun_obj = bpy.data.objects.new("KeySun", sun_data)
sun_obj.rotation_euler = (math.radians(50), math.radians(10), math.radians(30))
bpy.context.collection.objects.link(sun_obj)

# 6b. Fill light (Area lamp) — cool sky bounce, opposite to camera
fill_data = bpy.data.lights.new("FillLight", "AREA")
fill_data.energy = 50.0
fill_data.size = max_dim * 2.0
fill_data.color = (0.85, 0.9, 1.0)
fill_obj = bpy.data.objects.new("FillLight", fill_data)
# Position opposite to camera
fill_obj.location = (
    center.x - distance * 0.5,
    center.y + distance * 0.5,
    center.z + distance * 0.3,
)
fill_track = fill_obj.constraints.new(type="TRACK_TO")
fill_track.target = empty
fill_track.track_axis = "TRACK_NEGATIVE_Z"
fill_track.up_axis = "UP_Y"
bpy.context.collection.objects.link(fill_obj)

# 6c. Rim light (Spot lamp) — warm backlight
rim_data = bpy.data.lights.new("RimLight", "SPOT")
rim_data.energy = 100.0
rim_data.spot_size = math.radians(45)
rim_data.color = (1.0, 0.95, 0.85)
rim_obj = bpy.data.objects.new("RimLight", rim_data)
rim_obj.location = (
    center.x - distance * 0.3,
    center.y + distance * 0.8,
    center.z + max_dim * 1.5,
)
rim_track = rim_obj.constraints.new(type="TRACK_TO")
rim_track.target = empty
rim_track.track_axis = "TRACK_NEGATIVE_Z"
rim_track.up_axis = "UP_Y"
bpy.context.collection.objects.link(rim_obj)

# ── 6d. World lighting — procedural sky + volumetric atmosphere ────

world = bpy.data.worlds.new("PhysisWorld")
scene.world = world
world.node_tree.nodes.clear()

node_tree = world.node_tree
bg_node = node_tree.nodes.new("ShaderNodeBackground")
sky_node = node_tree.nodes.new("ShaderNodeTexSky")
output_node = node_tree.nodes.new("ShaderNodeOutputWorld")

sky_node.sky_type = "HOSEK_WILKIE"
sky_node.sun_elevation = math.radians(30)
sky_node.sun_rotation = math.radians(45)

bg_node.inputs["Strength"].default_value = 1.0

node_tree.links.new(sky_node.outputs["Color"], bg_node.inputs["Color"])
node_tree.links.new(bg_node.outputs["Background"], output_node.inputs["Surface"])

# Volumetric atmosphere — subtle depth-dependent haze
vol_scatter = node_tree.nodes.new("ShaderNodeVolumeScatter")
vol_scatter.inputs["Color"].default_value = (0.9, 0.93, 1.0, 1.0)
vol_scatter.inputs["Density"].default_value = 0.005
vol_scatter.inputs["Anisotropy"].default_value = 0.3
node_tree.links.new(vol_scatter.outputs["Volume"], output_node.inputs["Volume"])

# ── 7. Ground plane with procedural earth material ─────────────────

ground_plane = {{GROUND_PLANE}}

if ground_plane:
    ground_size = max_dim * 5.0
    bpy.ops.mesh.primitive_plane_add(size=ground_size, location=(center.x, center.y, bbox_min.z))
    ground_obj = bpy.context.active_object
    ground_obj.name = "GroundPlane"

    # Procedural earth material
    ground_mat = bpy.data.materials.new("GroundMat")
    ground_mat.use_nodes = True
    gt = ground_mat.node_tree
    gt.nodes.clear()

    g_output = gt.nodes.new("ShaderNodeOutputMaterial")
    g_bsdf = gt.nodes.new("ShaderNodeBsdfPrincipled")
    g_noise = gt.nodes.new("ShaderNodeTexNoise")
    g_ramp = gt.nodes.new("ShaderNodeValToRGB")
    g_texcoord = gt.nodes.new("ShaderNodeTexCoord")

    # Earth noise pattern
    g_noise.inputs["Scale"].default_value = 2.0
    g_noise.inputs["Detail"].default_value = 6.0
    g_noise.inputs["Roughness"].default_value = 0.7

    # Color ramp: dark soil → medium earth → sandy → pebble
    ramp = g_ramp.color_ramp
    ramp.elements[0].position = 0.0
    ramp.elements[0].color = (0.08, 0.06, 0.04, 1.0)
    ramp.elements.new(0.35)
    ramp.elements[1].color = (0.18, 0.14, 0.10, 1.0)
    ramp.elements.new(0.65)
    ramp.elements[2].color = (0.30, 0.25, 0.18, 1.0)
    ramp.elements[3].position = 1.0
    ramp.elements[3].color = (0.40, 0.36, 0.30, 1.0)

    g_bsdf.inputs["Roughness"].default_value = 0.9

    gt.links.new(g_texcoord.outputs["Object"], g_noise.inputs["Vector"])
    gt.links.new(g_noise.outputs["Fac"], g_ramp.inputs["Fac"])
    gt.links.new(g_ramp.outputs["Color"], g_bsdf.inputs["Base Color"])
    gt.links.new(g_bsdf.outputs["BSDF"], g_output.inputs["Surface"])

    ground_obj.data.materials.clear()
    ground_obj.data.materials.append(ground_mat)

# ── 8. Procedural shader material ──────────────────────────────────

bark_color = ({{BARK_COLOR_R}}, {{BARK_COLOR_G}}, {{BARK_COLOR_B}}, 1.0)

mat = bpy.data.materials.new("PhysisMaterial")
mat.use_nodes = True
nt = mat.node_tree
nt.nodes.clear()

# Output and BSDF
output = nt.nodes.new("ShaderNodeOutputMaterial")
bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
nt.links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])

# ── LAYER 1: Base color from noise ──────────────────────────────

# Texture coordinates (object space)
tex_coord = nt.nodes.new("ShaderNodeTexCoord")
mapping = nt.nodes.new("ShaderNodeMapping")
mapping.inputs["Scale"].default_value = params["mapping_scale"]
nt.links.new(tex_coord.outputs["Object"], mapping.inputs["Vector"])

# Large noise (crevice/bark pattern)
noise_large = nt.nodes.new("ShaderNodeTexNoise")
noise_large.inputs["Scale"].default_value = params["noise_scale_large"]
noise_large.inputs["Detail"].default_value = params["noise_detail_large"]
noise_large.inputs["Distortion"].default_value = params["noise_distortion"]
nt.links.new(mapping.outputs["Vector"], noise_large.inputs["Vector"])

# Fine noise (surface grain)
noise_fine = nt.nodes.new("ShaderNodeTexNoise")
noise_fine.inputs["Scale"].default_value = params["noise_scale_fine"]
noise_fine.inputs["Detail"].default_value = params["noise_detail_fine"]
nt.links.new(mapping.outputs["Vector"], noise_fine.inputs["Vector"])

# Mix noises 70/30 (large dominant)
mix_noise = nt.nodes.new("ShaderNodeMix")
mix_noise.data_type = 'FLOAT'
mix_noise.inputs[0].default_value = 0.3  # Factor
nt.links.new(noise_large.outputs["Fac"], mix_noise.inputs[2])  # A
nt.links.new(noise_fine.outputs["Fac"], mix_noise.inputs[3])   # B

# Height gradient: object-space Z → normalize to [0,1]
geometry = nt.nodes.new("ShaderNodeNewGeometry")
sep_xyz = nt.nodes.new("ShaderNodeSeparateXYZ")
height_map = nt.nodes.new("ShaderNodeMapRange")
nt.links.new(geometry.outputs["Position"], sep_xyz.inputs["Vector"])
# Map Z from bbox range to [0,1] — use approximate values, refined per-object
height_map.inputs["From Min"].default_value = bbox_min.z
height_map.inputs["From Max"].default_value = bbox_max.z
height_map.inputs["To Min"].default_value = 0.0
height_map.inputs["To Max"].default_value = 1.0
nt.links.new(sep_xyz.outputs["Z"], height_map.inputs["Value"])

# Color ramp for height-based darkening/lightening
height_ramp = nt.nodes.new("ShaderNodeValToRGB")
hr = height_ramp.color_ramp
darken = params["base_darken"]
lighten = params["tip_lighten"]
hr.elements[0].position = 0.0
hr.elements[0].color = (darken, darken, darken, 1.0)
hr.elements[1].position = 1.0
hr.elements[1].color = (lighten, lighten, lighten, 1.0)
nt.links.new(height_map.outputs["Result"], height_ramp.inputs["Fac"])

# Multiply bark_color by noise and height gradient
# Step 1: bark_color * noise_mix
color_x_noise = nt.nodes.new("ShaderNodeMix")
color_x_noise.data_type = 'RGBA'
color_x_noise.blend_type = 'MULTIPLY'
color_x_noise.inputs[0].default_value = 0.6  # Factor
color_x_noise.inputs[6].default_value = bark_color  # A
nt.links.new(mix_noise.outputs[0], color_x_noise.inputs[7])  # B (scalar broadcast)

# Step 2: result * height_gradient
color_x_height = nt.nodes.new("ShaderNodeMix")
color_x_height.data_type = 'RGBA'
color_x_height.blend_type = 'MULTIPLY'
color_x_height.inputs[0].default_value = 0.6  # Factor
nt.links.new(color_x_noise.outputs[2], color_x_height.inputs[6])   # A
nt.links.new(height_ramp.outputs["Color"], color_x_height.inputs[7])  # B

# ── LAYER 2: Branch depth tinting (from vertex COLOR_0) ─────────

# Try to use vertex colors — Blender imports COLOR_0 as "Col"
vert_color = nt.nodes.new("ShaderNodeVertexColor")
vert_color.layer_name = "Col"

sep_vc = nt.nodes.new("ShaderNodeSeparateXYZ")
nt.links.new(vert_color.outputs["Color"], sep_vc.inputs["Vector"])

# Depth factor = R channel (0=trunk, 1=twig)
# Mix from base color (trunk) to lighter tip tint
tip_tint = (
    min(bark_color[0] * 1.4, 1.0),
    min(bark_color[1] * 1.6, 1.0),
    min(bark_color[2] * 1.2, 1.0),
    1.0,
)
depth_mix = nt.nodes.new("ShaderNodeMix")
depth_mix.data_type = 'RGBA'
depth_mix.blend_type = 'MIX'
nt.links.new(sep_vc.outputs["X"], depth_mix.inputs[0])  # Factor = depth
nt.links.new(color_x_height.outputs[2], depth_mix.inputs[6])  # A = base
depth_mix.inputs[7].default_value = tip_tint  # B = tip tint

# ── LAYER 3: Moss overlay (bark only) ───────────────────────────

if params["moss_enabled"]:
    # Voronoi pattern for moss
    voronoi = nt.nodes.new("ShaderNodeTexVoronoi")
    voronoi.inputs["Scale"].default_value = 12.0
    voronoi.inputs["Randomness"].default_value = 0.8
    nt.links.new(mapping.outputs["Vector"], voronoi.inputs["Vector"])

    # Mask moss to lower portion of tree
    moss_mask = nt.nodes.new("ShaderNodeMath")
    moss_mask.operation = 'LESS_THAN'
    moss_mask.inputs[1].default_value = params["moss_height_max"]
    nt.links.new(height_map.outputs["Result"], moss_mask.inputs[0])

    # Combine voronoi pattern with height mask
    moss_factor = nt.nodes.new("ShaderNodeMath")
    moss_factor.operation = 'MULTIPLY'
    nt.links.new(voronoi.outputs["Distance"], moss_factor.inputs[0])
    nt.links.new(moss_mask.outputs["Value"], moss_factor.inputs[1])

    # Moss overlay
    moss_mix = nt.nodes.new("ShaderNodeMix")
    moss_mix.data_type = 'RGBA'
    moss_mix.blend_type = 'OVERLAY'
    moss_mix.inputs[0].default_value = params["moss_blend"]
    nt.links.new(depth_mix.outputs[2], moss_mix.inputs[6])  # A = depth-tinted
    moss_mix.inputs[7].default_value = params["moss_color"]  # B = moss color

    # Scale factor by moss pattern
    final_factor = nt.nodes.new("ShaderNodeMath")
    final_factor.operation = 'MULTIPLY'
    nt.links.new(moss_factor.outputs["Value"], final_factor.inputs[0])
    final_factor.inputs[1].default_value = params["moss_blend"]

    # Re-mix with controlled factor
    moss_final = nt.nodes.new("ShaderNodeMix")
    moss_final.data_type = 'RGBA'
    moss_final.blend_type = 'MIX'
    nt.links.new(final_factor.outputs["Value"], moss_final.inputs[0])
    nt.links.new(depth_mix.outputs[2], moss_final.inputs[6])
    moss_final.inputs[7].default_value = params["moss_color"]

    # Connect final color to BSDF
    nt.links.new(moss_final.outputs[2], bsdf.inputs["Base Color"])
else:
    # No moss — connect depth-tinted directly
    nt.links.new(depth_mix.outputs[2], bsdf.inputs["Base Color"])

# ── Surface detail ──────────────────────────────────────────────

# Roughness from noise
rough_ramp = nt.nodes.new("ShaderNodeMapRange")
rough_ramp.inputs["From Min"].default_value = 0.0
rough_ramp.inputs["From Max"].default_value = 1.0
rough_ramp.inputs["To Min"].default_value = params["roughness_min"]
rough_ramp.inputs["To Max"].default_value = params["roughness_max"]
nt.links.new(noise_large.outputs["Fac"], rough_ramp.inputs["Value"])
nt.links.new(rough_ramp.outputs["Result"], bsdf.inputs["Roughness"])

# Bump mapping
bump = nt.nodes.new("ShaderNodeBump")
bump.inputs["Strength"].default_value = params["bump_strength"]
bump.inputs["Distance"].default_value = params["bump_distance"]
nt.links.new(noise_large.outputs["Fac"], bump.inputs["Height"])
nt.links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

# Subsurface scattering
# Twigs get more SSS than trunk (depth-dependent)
sss_map = nt.nodes.new("ShaderNodeMapRange")
sss_map.inputs["From Min"].default_value = 0.0
sss_map.inputs["From Max"].default_value = 1.0
sss_map.inputs["To Min"].default_value = params["subsurface_weight"]
sss_map.inputs["To Max"].default_value = params["subsurface_weight"] * 2.0
nt.links.new(sep_vc.outputs["X"], sss_map.inputs["Value"])
nt.links.new(sss_map.outputs["Result"], bsdf.inputs["Subsurface Weight"])

bsdf.inputs["Subsurface Radius"].default_value = params["subsurface_radius"]
bsdf.inputs["Specular IOR Level"].default_value = params["specular_ior"]

# Apply material to all imported meshes
for obj in imported_objects:
    obj.data.materials.clear()
    obj.data.materials.append(mat)

# ── 9. Render output settings ──────────────────────────────────────

scene.render.resolution_x = {{RESOLUTION_X}}
scene.render.resolution_y = {{RESOLUTION_Y}}
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.render.filepath = r"{{OUTPUT_PATH}}"
scene.render.film_transparent = True

# ── 10. Render ─────────────────────────────────────────────────────

bpy.ops.render.render(write_still=True)
print(f"Render complete: {{OUTPUT_PATH}}")
