extends CharacterBody3D

# MayaController: Smooth, deliberate third-person exploration character controller.
# Implements realistic movement, intimate RE2/TLOU-style framing, and raycast interaction.

# Movement Constants
const WALK_SPEED = 2.5
const SPRINT_SPEED = 4.5
const CROUCH_SPEED = 1.2
const JUMP_VELOCITY = 4.2 # Standard dynamic jump velocity
const ROTATION_SPEED = 8.0 # Smooth yaw orientation
const GRAVITY = 9.8

# Lateral Movement Tuning (A/D feel)
# Scales left/right input contribution to ~75% of forward speed for deliberate thriller movement.
const LATERAL_SCALE: float = 0.75
const LATERAL_ACCEL: float = 12.0  # Rate of lateral input build-up (per second)
const LATERAL_DECEL: float = 28.0  # Rate of lateral input drop-off when key released (sharper stop)
var _smooth_lateral: float = 0.0   # Smoothed lateral input state

# Camera Settings
const MOUSE_SENSITIVITY = 0.003 # Radians per pixel
const PITCH_MIN = -45.0
const PITCH_MAX = 60.0

# Node References
@onready var camera_hinge: Node3D = $CameraHinge
@onready var spring_arm: SpringArm3D = $CameraHinge/SpringArm3D
@onready var camera: Camera3D = $CameraHinge/SpringArm3D/Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_body: MeshInstance3D = $PlaceholderBody
@onready var mesh_head: MeshInstance3D = $PlaceholderHead
@onready var interaction_ray: RayCast3D = $InteractionRay

# State Variables
var current_speed: float = WALK_SPEED
var is_crouching: bool = false
var is_sprinting: bool = false
var current_interactable = null
var _animation_time: float = 0.0
var _crouch_weight: float = 0.0

func _ready():
	# Configure Raycast range programmatically to prevent editor discrepancies
	interaction_ray.target_position = Vector3(0, 0, -2.5) # Look forward 2.5 meters
	interaction_ray.collide_with_areas = true
	interaction_ray.collide_with_bodies = false
	
	# First Person Conversion
	camera.fov = 78.0 
	spring_arm.spring_length = 0.0 # No offset depth
	spring_arm.position = Vector3.ZERO # Remove lateral shoulder offset
	camera.position = Vector3.ZERO # Remove local camera offset
	camera_hinge.position.y = 0.65 # Eye level height
	
	# Hide the player body from the local camera
	mesh_body.visible = false
	mesh_head.visible = false
	
	spring_arm.add_excluded_object(get_rid()) # Prevent camera colliders clipping player
	
	print("[MayaController] Core systems operational. First-Person rig active.")

func _input(event: InputEvent):
	# Don't capture inputs if a menu/tablet/dialogue is open
	if get_tree().paused or UIManager.is_node_ui_open or DialogueManager.is_in_dialogue:
		return

	# Handle Mouse-Look rotation
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate horizontal hinge (Yaw)
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Rotate vertical spring arm (Pitch)
		camera_hinge.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera_hinge.rotation.x = clamp(
			camera_hinge.rotation.x, 
			deg_to_rad(PITCH_MIN), 
			deg_to_rad(PITCH_MAX)
		)

	# Global Actions Capture
	if event.is_action_pressed("pause_menu"):
		UIManager.toggle_pause()
	elif event.is_action_pressed("node_toggle"):
		UIManager.toggle_node_ui()

func _physics_process(delta: float):
	# Gravity and Jump application
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		if Input.is_action_just_pressed("jump") and not is_crouching:
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y = 0.0

	# Disable gameplay motion if dialogue/tablet or menus are active
	if UIManager.is_node_ui_open or DialogueManager.is_in_dialogue or get_tree().paused:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# Handle Sprint and Crouch state inputs
	_handle_states()

	# Compute Camera-Relative Movement direction
	var raw_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# --- Lateral Smoothing (A/D) ---
	# Smoothly ramp lateral input toward 75% of its raw value.
	# Uses a faster deceleration rate for snappy stops (avoids sliding feel).
	var lateral_target = raw_input.x * LATERAL_SCALE
	var lerp_t = (LATERAL_ACCEL if abs(raw_input.x) > 0.01 else LATERAL_DECEL) * delta
	_smooth_lateral = lerp(_smooth_lateral, lateral_target, minf(lerp_t, 1.0))

	# Build camera-relative direction: smoothed lateral + full forward response
	var move_local = Vector3(_smooth_lateral, 0.0, raw_input.y)
	var direction = (transform.basis * move_local).limit_length(1.0)

	if direction.length() > 0.001:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		# Character body always faces the mouse-look direction (set via rotate_y in _input).
		# A/D strafe left/right relative to that facing — no body rotation on lateral input.
	else:
		# Quick but not instant stop — prevents momentum floatiness
		velocity.x = move_toward(velocity.x, 0, current_speed * 1.8)
		velocity.z = move_toward(velocity.z, 0, current_speed * 1.8)

	# Commit movement using slide physics
	move_and_slide()

	# Check for Interactable items
	_process_interactions()

func _handle_states():
	# Crouch logic
	if Input.is_action_pressed("crouch"):
		if not is_crouching:
			is_crouching = true
			current_speed = CROUCH_SPEED
			# Visual shrink representation (Procedural scale adjustment)
			collision_shape.scale.y = 0.6
			collision_shape.position.y = -0.3
			mesh_body.scale.y = 0.6
			mesh_body.position.y = -0.3
			mesh_head.position.y = 0.1
	else:
		if is_crouching:
			is_crouching = false
			# Restore visual proportions
			collision_shape.scale.y = 1.0
			collision_shape.position.y = 0.0
			mesh_body.scale.y = 1.0
			mesh_body.position.y = 0.0
			mesh_head.position.y = 0.65

	# Sprint logic (Cannot sprint while crouching)
	if Input.is_action_pressed("sprint") and not is_crouching:
		is_sprinting = true
		current_speed = SPRINT_SPEED
	else:
		is_sprinting = false
		if not is_crouching:
			current_speed = WALK_SPEED

func _process_interactions():
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		
		# Verify that collider is an interactable Area3D
		if collider and collider.has_method("interact"):
			if current_interactable != collider:
				current_interactable = collider
				
				# Show HUD prompt
				var prompt = "Press E to %s" % collider.prompt_name
				if collider.is_locked:
					prompt += " [SECURE]"
				UIManager.show_interaction_prompt(prompt)
		else:
			_clear_detected_interactable()
	else:
		_clear_detected_interactable()

	# Action triggers
	if current_interactable:
		if Input.is_action_just_pressed("interact"):
			current_interactable.interact(self)
		elif Input.is_action_just_pressed("inspect"):
			if current_interactable.has_method("inspect"):
				current_interactable.inspect(self)

func _clear_detected_interactable():
	if current_interactable != null:
		current_interactable = null
		UIManager.clear_interaction_prompt()

# End of Controller
