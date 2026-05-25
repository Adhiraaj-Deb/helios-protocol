extends Node3D

# ============================================================
# IslandLoader
# Handles: scale, centering, luminance-discard shader (removes
# black UV padding), solid trimesh collision, fog off.
# ============================================================

const SCALE: float = 0.032        # 4x the previous 0.008

# GLB raw bounds: X=88055, Z=68487 → at 0.032: 2817.8m × 2191.6m
# Negative half-extents center the island mesh at world origin
# We shift it slightly more (0.42 instead of 0.5) to bring the landmass closer if it's off-center
const OFFSET_X: float = -(88055.0 * SCALE * 0.42)
const OFFSET_Z: float = -(68487.0 * SCALE * 0.42)

func _ready() -> void:
	global_position = Vector3(0, -0.5, 0) # Slightly below room floor
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
	var island_glb := get_node_or_null("IslandGLB") as Node3D
	if island_glb == null:
		push_error("IslandLoader: child 'IslandGLB' not found!")
		return

	# Apply 4x scale and center at world origin
	island_glb.transform = Transform3D(
		Basis().scaled(Vector3(SCALE, SCALE, SCALE)),
		Vector3(OFFSET_X, 0.0, OFFSET_Z)
	)

	# Load the cutout shader
	var shader := load("res://assets/shaders/island_cutout.gdshader") as Shader

	var mesh_count := 0
	_process_node(island_glb, shader, mesh_count)
	print("IslandLoader: %d mesh(es) configured. Island ≈ %.0fm × %.0fm." % [
		mesh_count, 88055.0 * SCALE, 68487.0 * SCALE
	])

# ----------------------------------------------------------
func _process_node(node: Node, shader: Shader, mesh_count: int) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			for s in range(mi.mesh.get_surface_count()):
				# Try to grab the material from the MeshInstance (override) or the Mesh resource
				var original_mat := mi.get_active_material(s)
				if original_mat == null:
					original_mat = mi.mesh.surface_get_material(s)

				var albedo_tex: Texture2D = null
				if original_mat is BaseMaterial3D:
					albedo_tex = (original_mat as BaseMaterial3D).albedo_texture
				elif original_mat is ShaderMaterial:
					albedo_tex = original_mat.get_shader_parameter("albedo_tex") as Texture2D

				# Fallback: If texture is missing from material, try to load it from the expected path
				if albedo_tex == null:
					var fallback_path = "res://assets/models/island/Island_0.png"
					if FileAccess.file_exists(fallback_path):
						albedo_tex = load(fallback_path) as Texture2D
						print("IslandLoader: Applied fallback texture to %s" % mi.name)
					else:
						# Try one more location
						fallback_path = "res://assets/models/Island_0.png"
						if FileAccess.file_exists(fallback_path):
							albedo_tex = load(fallback_path) as Texture2D
							print("IslandLoader: Applied secondary fallback texture to %s" % mi.name)

				# Build the ShaderMaterial with luminance-discard
				var mat := ShaderMaterial.new()
				mat.shader = shader
				if albedo_tex:
					mat.set_shader_parameter("albedo_tex", albedo_tex)
					mat.set_shader_parameter("has_texture", true)
				else:
					mat.set_shader_parameter("has_texture", false)
					print("IslandLoader: WARNING - No texture found for surface %d of %s" % [s, mi.name])
					
				mat.set_shader_parameter("discard_threshold", 0.1) # Lowered slightly for safety
				mat.set_shader_parameter("roughness", 0.85)
				mi.set_surface_override_material(s, mat)

			# Add trimesh collision as StaticBody3D child (if not already present)
			if not _has_static_body(mi):
				var sb := StaticBody3D.new()
				sb.collision_layer = 1
				sb.collision_mask = 0
				sb.name = "IslandCollision"
				var cs := CollisionShape3D.new()
				# Use a high-quality trimesh shape for solid collision
				cs.shape = mi.mesh.create_trimesh_shape()
				sb.add_child(cs)
				mi.add_child(sb)

			mesh_count += 1

	for child in node.get_children():
		_process_node(child, shader, mesh_count)

func _has_static_body(node: Node) -> bool:
	for c in node.get_children():
		if c is StaticBody3D:
			return true
	return false
