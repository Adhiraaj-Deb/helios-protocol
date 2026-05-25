extends Node

# GameManager: The primary conductor of the application lifecycle
# Implements programmatic InputMap registration to ensure robustness.

enum State { BOOT, MENU, GAMEPLAY, PAUSED }
var current_state: State = State.BOOT

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Run even when the tree is paused
	_setup_inputs()
	print("[GameManager] Core inputs set. Transitioning from BOOT...")
	
	# Start at Menu immediately
	current_state = State.MENU
	call_deferred("_boot_sequence")

func _boot_sequence():
	# If running the bootstrap scene directly, we boot.
	# Otherwise, verify if we need to show the Main Menu.
	print("[GameManager] Boot sequence complete. Active state: MENU.")

# --- Programmatic Safe Input Configuration ---
func _setup_inputs():
	var inputs = {
		"move_forward": [KEY_W, KEY_UP],
		"move_backward": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"sprint": [KEY_SHIFT],
		"crouch": [KEY_CTRL],
		"interact": [KEY_E],
		"inspect": [KEY_F],
		"pause_menu": [KEY_ESCAPE],
		"node_toggle": [KEY_TAB],
		"evidence_toggle": [KEY_I],
		"dialogue_advance": [KEY_SPACE],
		"toggle_lighting": [KEY_N],
		"jump": [KEY_SPACE]
	}

	for action in inputs.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			# Add default events
			for keycode in inputs[action]:
				var event = InputEventKey.new()
				event.keycode = keycode
				InputMap.action_add_event(action, event)
	
	print("[GameManager] Input Map dynamically configured with default keybindings.")

# --- Scene Load / Transition Actions ---

func load_title_screen():
	current_state = State.MENU
	UIManager.force_close_all()
	get_tree().change_scene_to_file("res://scenes/core/boot.tscn")
	print("[GameManager] Navigating to: Title Menu")

func start_vertical_slice():
	current_state = State.GAMEPLAY
	UIManager.force_close_all()
	# Load the gameplay scene
	var err = get_tree().change_scene_to_file("res://scenes/main/solaris_isle.tscn")
	if err != OK:
		push_error("[GameManager] Failed to load solaris_isle scene. Error: %d" % err)
	else:
		print("[GameManager] Main gameplay environment loaded successfully.")
		# Defer mouse capture alignment
		call_deferred("_finalize_gameplay_start")

func _finalize_gameplay_start():
	UIManager.start_gameplay()
	AudioManager.play_ambience(false) # Day ambience by default

# End of GameManager
