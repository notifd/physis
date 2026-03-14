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
    {{GROUND_PLANE}}            — True/False for shadow catcher ground plane

Designed for Blender 5.0+ with Cycles METAL/OPTIX/CUDA or CPU fallback.
"""

import bpy
import math
import sys
from mathutils import Vector

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

# ── 5. Camera ──────────────────────────────────────────────────────

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

# Point camera at center using track-to constraint
track = cam_obj.constraints.new(type="TRACK_TO")
track.target = imported_objects[0]
track.track_axis = "TRACK_NEGATIVE_Z"
track.up_axis = "UP_Y"

# Override track target with empty at center for better framing
empty = bpy.data.objects.new("CameraTarget", None)
empty.location = center
bpy.context.collection.objects.link(empty)
track.target = empty

# ── 6. World lighting — procedural sky ─────────────────────────────

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

# ── 7. Ground plane (shadow catcher) ───────────────────────────────

ground_plane = {{GROUND_PLANE}}

if ground_plane:
    ground_size = max_dim * 5.0
    bpy.ops.mesh.primitive_plane_add(size=ground_size, location=(center.x, center.y, bbox_min.z))
    ground_obj = bpy.context.active_object
    ground_obj.name = "GroundPlane"
    ground_obj.is_shadow_catcher = True

# ── 8. Apply PBR material ──────────────────────────────────────────

bark_color = ({{BARK_COLOR_R}}, {{BARK_COLOR_G}}, {{BARK_COLOR_B}}, 1.0)

mat = bpy.data.materials.new("PhysisBark")
mat.use_nodes = True
bsdf = mat.node_tree.nodes.get("Principled BSDF")
if bsdf is None:
    bsdf = mat.node_tree.nodes.new("ShaderNodeBsdfPrincipled")

bsdf.inputs["Base Color"].default_value = bark_color
bsdf.inputs["Roughness"].default_value = 0.85
bsdf.inputs["Subsurface Weight"].default_value = 0.1
bsdf.inputs["Subsurface Radius"].default_value = (0.3, 0.1, 0.05)

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
