extends Node3D

# ============================================================
# IslandLoader
# - Scales island 4x (0.008 total)
# - Centers island at world origin
# - Applies alpha-scissor material to cut black padding
# - Generates trimesh collision on every mesh surface
# - Disables fog
# ============================================================

const SCALE: float = 0.008        # 4x the previous 0.002
const ALPHA_CUTOFF: float = 0.08  # Black pixels (< 8% brightness) become invisible

# GLB raw bounds: X=88055, Z=68487 → at scale 0.008: 704m × 548m
# Center offsets cancel the [0..max] range so island is at world origin
const OFFSET_X: float = -(88055.0 * SCALE / 2.0)   # -352.22
const OFFSET_Z: float = -(68487.0 * SCALE / 2.0)   # -273.95

func _ready() -> void:
	# This node sits at world origin; the GLB child handles its own offset
	global_position = Vector3.ZERO
	call_deferred("_setup")

func _setup() -> void:
	_disable_fog()
	_configure_island_glb()

# ----------------------------------------------------------
func _disable_fog() -> void:
	var we := get_tree().root.find_child("WorldEnvironment", true, false) as WorldEnvironment
	if we and we.environment:
		we.environment.fog_enabled = false

# ----------------------------------------------------------
func _configure_island_glb() -> void:
	# The child "IslandGLB" is the instanced PackedScene from Island.glb
	var island_glb := get_node_or_null("IslandGLB") as Node3D
	if island_glb == null:
		push_error("IslandLoader: child 'IslandGLB' not found!")
		return

	# Apply 4x scale and center the island at world origin
	island_glb.transform = Transform3D(
		Basis().scaled(Vector3(SCALE, SCALE, SCALE)),
		Vector3(OFFSET_X, 0.0, OFFSET_Z)
	)

	# Walk the GLB subtree: fix material transparency + add collision
	var mesh_count := 0
	_process_node(island_glb, mesh_count)
	print("IslandLoader: configured %d mesh(es). Island is %.0fm × %.0fm." % [
		mesh_count,
		88055.0 * SCALE,
		68487.0 * SCALE
	])

# ----------------------------------------------------------
func _process_node(node: Node, mesh_count: int) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			# Fix material: use the GLB's own embedded material but enable alpha scissor
			# to cut away the black UV padding regions
			for s in range(mi.mesh.get_surface_count()):
				var original_mat := mi.mesh.surface_get_material(s)
				var mat := StandardMaterial3D.new()

				# Copy base color texture from original if available
				if original_mat is BaseMaterial3D:
					mat.albedo_texture = (original_mat as BaseMaterial3D).albedo_texture
				elif original_mat is ShaderMaterial:
					# Fallback: try albedo param
					var t = original_mat.get_shader_parameter("albedo_texture")
					if t: mat.albedo_texture = t

				# Alpha scissor: discard pixels where luminance < threshold
				# Black padding pixels will be invisible, island stays solid
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				mat.alpha_scissor_threshold = ALPHA_CUTOFF
				mat.cull_mode = BaseMaterial3D.CULL_BACK
				mat.roughness = 0.85
				mat.metallic = 0.0

				mi.set_surface_override_material(s, mat)

			# Add solid trimesh collision as a StaticBody3D child of this MeshInstance3D
			# (Inherits the mesh's local transform automatically)
			if not _has_static_body(mi):
				var sb := StaticBody3D.new()
				sb.collision_layer = 1
				sb.collision_mask = 0
				sb.name = "IslandCollision"
				var cs := CollisionShape3D.new()
				cs.shape = mi.mesh.create_trimesh_shape()
				sb.add_child(cs)
				mi.add_child(sb)

			mesh_count += 1

	for child in node.get_children():
		_process_node(child, mesh_count)

func _has_static_body(node: Node) -> bool:
	for c in node.get_children():
		if c is StaticBody3D:
			return true
	return false
