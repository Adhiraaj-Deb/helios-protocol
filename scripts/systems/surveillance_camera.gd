extends Node3D

# SurveillanceCamera: Autonomous surveillance agent representing the active threat.
# Coordinates panning sector sweeps, raycast occlusion testing, crouch stealth scaling,
# and dynamically scales spotlights and debug meshes based on alert states.

const DEBUG_MODE = true # Change to false to fully disable debug wireframe cone geometry

# Detection Parameters
@export var scan_speed: float = 0.5
@export var scan_angle: float = 45.0 # Sweeps +/- 45 degrees
@export var view_range: float = 12.0
@export var view_fov: float = 90.0 # Field of view in degrees

var suspicion: float = 0.0 # Range: 0.0 to 1.0 (0-100%)
var alert_state: String = "UNNOTICED"

# Internal Angles
var start_yaw: float = 0.0
var target_yaw: float = 0.0
var time_passed: float = 0.0
var player_node: CharacterBody3D = null

# Node Hooks
@onready var camera_body: Node3D = $CameraBody
@onready var camera_light: SpotLight3D = $CameraBody/SpotLight3D
@onready var occlusion_ray: RayCast3D = $CameraBody/OcclusionRay

var debug_cone: MeshInstance3D = null

func _ready():
	start_yaw = camera_body.rotation.y
	occlusion_ray.target_position = Vector3(0, 0, -view_range)
	occlusion_ray.collide_with_areas = false
	occlusion_ray.collide_with_bodies = true # Check walls and player body
	
	# Configure spotlight to represent direct vision sector
	camera_light.spot_range = view_range
	camera_light.spot_angle = view_fov / 2.0
	camera_light.light_energy = 8.0
	
	# Find player node in tree
	call_deferred("_locate_player")
	
	# Dynamic Debug Cone construction
	if DEBUG_MODE:
		_create_debug_cone()
		
	print("[SurveillanceCamera] Camera sensor online. Grid scan active.")

func _locate_player():
	var root = get_tree().root
	# Search recursively
	player_node = _find_child_by_class(root, "CharacterBody3D")
	if player_node:
		print("[SurveillanceCamera] Synced with target signature: Maya.")

# Helper to recursively locate a child node of a specific class type
func _find_child_by_class(node: Node, target_class: String) -> Node:
	if node.is_class(target_class):
		return node
	for child in node.get_children():
		var found = _find_child_by_class(child, target_class)
		if found:
			return found
	return null

func _create_debug_cone():
	debug_cone = MeshInstance3D.new()
	debug_cone.name = "DebugVisionCone"
	camera_body.add_child(debug_cone)
	
	# Assemble simple cone mesh using a Cylinder shape
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.01
	cyl.bottom_radius = view_range * tan(deg_to_rad(view_fov / 2.0))
	cyl.height = view_range
	cyl.radial_segments = 16
	cyl.rings = 2
	
	debug_cone.mesh = cyl
	
	# Position and rotate to align forward along negative Z
	debug_cone.position = Vector3(0, 0, -view_range / 2.0)
	debug_cone.rotation.x = deg_to_rad(-90.0) # Rotate to face forward
	
	# Create translucent material
	var mat = StandardMaterial3D.new()
	mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.7, 0.7, 0.7, 0.08) # Slate grey translucent
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	debug_cone.material_override = mat

func _process(delta: float):
	if get_tree().paused:
		return
		
	time_passed += delta
	
	# 1. Sweep Rotation behavior (Yaw)
	_handle_rotation(delta)

	# 2. Check for player presence in cone
	var can_see = _evaluate_vision()

	# 3. Update Suspicion Level
	_update_suspicion(can_see, delta)

	# 4. Align Visual Color Feedbacks
	_align_feedbacks()

func _handle_rotation(delta: float):
	if alert_state == "COMPROMISED" and player_node:
		# Hyper-aware tracking mode: point directly at player
		var direction_to_player = (player_node.global_position - camera_body.global_position).normalized()
		var target_look = atan2(-direction_to_player.x, -direction_to_player.z)
		camera_body.rotation.y = rotate_toward(camera_body.rotation.y, target_look, 2.0 * delta)
	elif alert_state == "SUSPICIOUS" and player_node:
		# Hesitant tracking: slowly lock rotation on player
		var direction_to_player = (player_node.global_position - camera_body.global_position).normalized()
		var target_look = atan2(-direction_to_player.x, -direction_to_player.z)
		camera_body.rotation.y = rotate_toward(camera_body.rotation.y, target_look, 0.8 * delta)
	else:
		# Standard scan sweep: swing back and forth
		var target_offset = sin(time_passed * scan_speed) * deg_to_rad(scan_angle)
		camera_body.rotation.y = start_yaw + target_offset

func _evaluate_vision() -> bool:
	if not player_node:
		return false
		
	var cam_pos = camera_body.global_position
	# Offset player pos slightly to target head/body rather than feet
	var target_pos = player_node.global_position + Vector3(0, 0.4, 0)
	
	# Distance check
	var dist = cam_pos.distance_to(target_pos)
	if dist > view_range:
		return false
		
	# Field of view angular check
	var dir_to_player = (target_pos - cam_pos).normalized()
	# Camera Z direction is -camera_body.global_transform.basis.z in Godot
	var cam_forward = -camera_body.global_transform.basis.z.normalized()
	
	var angle = rad_to_deg(cam_forward.angle_to(dir_to_player))
	if angle > (view_fov / 2.0):
		return false
		
	# Raycast line-of-sight test (verify occluding walls)
	occlusion_ray.look_at(target_pos, Vector3.UP)
	occlusion_ray.force_raycast_update()
	
	if occlusion_ray.is_colliding():
		var col = occlusion_ray.get_collider()
		# If colliding with something other than player body, vision is blocked!
		if col != player_node:
			return false
			
	return true

func _update_suspicion(can_see: bool, delta: float):
	if can_see:
		# Suspicion build speed: standard takes 3.0s, crouch takes 6.0s (crouch modifies alert speeds by 0.5)
		var build_speed = 0.33
		if player_node.has_method("_handle_states") and player_node.is_crouching:
			build_speed = 0.16 # Half speed
			
		suspicion = clamp(suspicion + build_speed * delta, 0.0, 1.0)
	else:
		# Suspicion drains faster when line of sight is broken
		suspicion = clamp(suspicion - 0.5 * delta, 0.0, 1.0)

	# State Transition updates
	var old_state = alert_state
	if suspicion >= 1.0:
		alert_state = "COMPROMISED"
	elif suspicion >= 0.4:
		alert_state = "SUSPICIOUS"
	else:
		alert_state = "UNNOTICED"

	if old_state != alert_state:
		# Update global HUD stealth indicators
		if UIManager.current_hud:
			UIManager.current_hud.update_stealth_indicator(alert_state)
		# Trigger dynamic tension music layers
		AudioManager.play_stealth_music(suspicion)
		print("[SurveillanceCamera] Alert state transition: %s -> %s" % [old_state, alert_state])

func _align_feedbacks():
	# Color transitions: grey/white -> yellow -> red
	var light_color = Color(0.85, 0.85, 0.85, 1.0) # Unnoticed
	var cone_alpha = 0.05
	
	if alert_state == "SUSPICIOUS":
		# Lerp gold color based on suspicion progress
		var factor = (suspicion - 0.4) / 0.6
		light_color = Color(0.95, 0.85, 0.35).lerp(Color(0.95, 0.55, 0.15), factor)
		cone_alpha = 0.12
	elif alert_state == "COMPROMISED":
		light_color = Color(0.90, 0.28, 0.24, 1.0) # Danger Red
		cone_alpha = 0.25

	# Update light beam
	camera_light.light_color = light_color
	
	# Update debug material if enabled
	if DEBUG_MODE and debug_cone and debug_cone.material_override:
		var mat = debug_cone.material_override as StandardMaterial3D
		mat.albedo_color = Color(light_color.r, light_color.g, light_color.b, cone_alpha)
