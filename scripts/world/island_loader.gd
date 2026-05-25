extends Node3D

# ============================================================
# IslandLoader – attaches to the IslandTerrain Node3D
# Finds all MeshInstance3D children inside the instanced GLB,
# applies the texture, and generates trimesh collision.
# ============================================================

func _ready() -> void:
	# Move the island to a clean position in world space.
	# The room spawns at origin; the island sits 500 m to the side.
	global_position = Vector3(500, 0, 0)
	
	# Disable fog so the island is visible from the room
	call_deferred("_setup_fog")
	call_deferred("_build_collision")

func _setup_fog() -> void:
	var we := get_tree().root.find_child("WorldEnvironment", true, false) as WorldEnvironment
	if we and we.environment:
		we.environment.fog_enabled = false

func _build_collision() -> void:
	# Load the texture once
	var tex: Texture2D = load("res://assets/models/island/Island_0.png")
	if tex == null:
		push_error("IslandLoader: Island_0.png not found!")
	
	var meshes_found := 0
	_process_node(self, tex, meshes_found)
	
	if meshes_found == 0:
		push_error("IslandLoader: No MeshInstance3D found inside the GLB!")
	else:
		print("IslandLoader: Done – processed %d mesh(es) with collision and texture." % meshes_found)

func _process_node(node: Node, tex: Texture2D, meshes_found: int) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			# Apply texture material
			if tex:
				var mat := StandardMaterial3D.new()
				mat.albedo_texture = tex
				mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
				mat.cull_mode = BaseMaterial3D.CULL_DISABLED
				for s in range(mi.mesh.get_surface_count()):
					mi.set_surface_override_material(s, mat)
			
			# Build exact trimesh collision — add StaticBody3D as sibling
			# (Adding as child of MeshInstance3D also works and is simpler)
			var sb := StaticBody3D.new()
			sb.collision_layer = 1
			sb.collision_mask = 0
			var cs := CollisionShape3D.new()
			cs.shape = mi.mesh.create_trimesh_shape()
			sb.add_child(cs)
			mi.add_child(sb)
			meshes_found += 1
	
	for child in node.get_children():
		_process_node(child, tex, meshes_found)
