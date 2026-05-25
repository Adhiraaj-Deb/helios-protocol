extends Node

# EnvController: Drives daytime/nighttime mood transitions.
# Press N to toggle. All lighting values calibrated for the luxury-brutalist art direction.

@export var sun_path: NodePath
@export var world_env_path: NodePath
@export var night_accent_lights_parent_path: NodePath

var sun: DirectionalLight3D = null
var world_env: WorldEnvironment = null
var night_accents: Node3D = null

var is_night: bool = false

func _ready():
	if sun_path:
		sun = get_node(sun_path)
	if world_env_path:
		world_env = get_node(world_env_path)
	if night_accent_lights_parent_path:
		night_accents = get_node(night_accent_lights_parent_path)

	_apply_lighting_state()
	print("[EnvController] Lighting controller active. Press N to toggle day/night mood.")

func _input(event: InputEvent):
	if event.is_action_pressed("toggle_lighting"):
		is_night = not is_night
		_apply_lighting_state()
		var mood = "NIGHT — SURVEILLANCE MODE" if is_night else "DAY — GOLDEN HOUR"
		UIManager.show_toast("ENV SHIFT", mood)
		AudioManager.play_ui_click()

func _apply_lighting_state():
	if not sun or not world_env:
		return
	var env = world_env.environment
	if not env:
		return

	if is_night:
		# ---- NIGHT: Cool navy foundation, warm isolated practicals ----
		sun.light_color = Color(0.28, 0.36, 0.58, 1.0)   # Dim moonlight (blue-violet)
		sun.light_energy = 0.18
		sun.shadow_enabled = true

		env.ambient_light_color = Color(0.10, 0.14, 0.26, 1.0)  # Deep cool navy
		env.ambient_light_energy = 0.45

		env.fog_enabled = true
		env.fog_light_color = Color(0.06, 0.08, 0.14, 1.0)
		env.fog_density = 0.018

		if night_accents:
			night_accents.visible = true

		AudioManager.play_ambience(true)
		print("[EnvController] Applied: NIGHT — Surveillance Mode")

	else:
		# ---- DAY: Warm coastal morning / golden hour ----
		sun.light_color = Color(0.99, 0.88, 0.65, 1.0)   # Rich warm gold
		sun.light_energy = 1.55
		sun.shadow_enabled = true

		env.ambient_light_color = Color(0.88, 0.78, 0.65, 1.0)  # Warm coastal fill
		env.ambient_light_energy = 0.55

		env.fog_enabled = true
		env.fog_light_color = Color(0.72, 0.62, 0.50, 1.0)
		env.fog_density = 0.005

		if night_accents:
			night_accents.visible = false

		AudioManager.play_ambience(false)
		print("[EnvController] Applied: DAY — Golden Hour")
