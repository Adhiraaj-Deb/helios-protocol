extends Node

# UIManager: Manages screens, HUD prompts, and cursor control
# Performs programmatic runtime UI instancing on a persistent CanvasLayer.

var current_hud: Control = null
var current_node_ui: Control = null
var current_dialogue_ui: Control = null
var current_main_menu: Control = null
var current_pause_menu: Control = null

# Visibility State flags
var is_node_ui_open: bool = false
var is_paused: bool = false

func _ready():
	print("[UIManager] Interface Controller active. Initializing dynamic UI layer...")
	call_deferred("_instance_ui_elements")

func _instance_ui_elements():
	# Create persistent CanvasLayer
	var canvas = CanvasLayer.new()
	canvas.name = "HELIOS_GlobalUI"
	canvas.layer = 100 # Highest layer to display over 3D game spaces
	add_child(canvas)

	# 1. Load and Instance Main Menu
	var main_menu_res = load("res://scenes/ui/main_menu.tscn")
	current_main_menu = main_menu_res.instantiate()
	canvas.add_child(current_main_menu)
	
	# 2. Load and Instance HUD
	var hud_res = load("res://scenes/ui/hud.tscn")
	current_hud = hud_res.instantiate()
	canvas.add_child(current_hud)
	
	# 3. Load and Instance Node Tablet UI
	var node_res = load("res://scenes/ui/node_ui.tscn")
	current_node_ui = node_res.instantiate()
	canvas.add_child(current_node_ui)
	
	# 4. Load and Instance Dialogue UI
	var dialogue_res = load("res://scenes/ui/dialogue_ui.tscn")
	current_dialogue_ui = dialogue_res.instantiate()
	canvas.add_child(current_dialogue_ui)
	
	# 5. Load and Instance Pause Menu
	var pause_res = load("res://scenes/ui/pause_menu.tscn")
	current_pause_menu = pause_res.instantiate()
	canvas.add_child(current_pause_menu)
	
	# Open title screen on startup
	show_main_menu()
	print("[UIManager] Persistent UI elements instanced successfully.")

# --- Visibility Controls ---

func show_main_menu():
	if current_main_menu:
		current_main_menu.visible = true
	if current_hud:
		current_hud.visible = false
	if current_node_ui:
		current_node_ui.visible = false
	if current_dialogue_ui:
		current_dialogue_ui.visible = false
	if current_pause_menu:
		current_pause_menu.visible = false
		
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	is_node_ui_open = false
	is_paused = false
	print("[UIManager] Displaying: Title Menu")

func start_gameplay():
	if current_main_menu:
		current_main_menu.visible = false
	if current_hud:
		current_hud.visible = true
	if current_node_ui:
		current_node_ui.visible = false
	if current_dialogue_ui:
		current_dialogue_ui.visible = false
	if current_pause_menu:
		current_pause_menu.visible = false
		
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_node_ui_open = false
	is_paused = false
	print("[UIManager] Switched to: Active Gameplay")

func toggle_node_ui():
	if DialogueManager.is_in_dialogue or is_paused or not current_hud.visible:
		# Don't allow opening Node device during dialogue, pause, or when main menu is active
		return
		
	is_node_ui_open = not is_node_ui_open
	if current_node_ui:
		current_node_ui.visible = is_node_ui_open
		if is_node_ui_open:
			if current_node_ui.has_method("refresh_data"):
				current_node_ui.refresh_data()
				
	AudioManager.play_ui_node_toggle(is_node_ui_open)
	
	if is_node_ui_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("[UIManager] Node Tablet Toggled: %s" % is_node_ui_open)

func toggle_pause():
	if is_node_ui_open or DialogueManager.is_in_dialogue or current_main_menu.visible:
		return
		
	is_paused = not is_paused
	if current_pause_menu:
		current_pause_menu.visible = is_paused
		
	get_tree().paused = is_paused
	
	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("[UIManager] Game Paused: %s" % is_paused)

func force_close_all():
	is_node_ui_open = false
	is_paused = false
	get_tree().paused = false
	
	if current_node_ui:
		current_node_ui.visible = false
	if current_dialogue_ui:
		current_dialogue_ui.visible = false
	if current_pause_menu:
		current_pause_menu.visible = false
	if current_hud:
		current_hud.visible = false

# --- HUD Interaction Prompts ---

func show_interaction_prompt(prompt_text: String):
	if current_hud and current_hud.has_method("set_prompt"):
		current_hud.set_prompt(prompt_text)

func clear_interaction_prompt():
	if current_hud and current_hud.has_method("clear_prompt"):
		current_hud.clear_prompt()

func show_toast(title: String, desc: String):
	if current_hud and current_hud.has_method("display_toast"):
		current_hud.display_toast(title, desc)
