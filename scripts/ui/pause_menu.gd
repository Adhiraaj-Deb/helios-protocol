extends Control

# PauseMenu: Game suspension overlay. All nodes built in code.

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Dim overlay
	var overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.65)
	add_child(overlay)

	# Center box
	var box = PanelContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.offset_left = -180.0
	box.offset_top = -150.0
	box.offset_right = 180.0
	box.offset_bottom = 150.0
	add_child(box)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	box.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "CONNECTION SUSPENDED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.76, 0.59, 0.31, 1.0))
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Buttons
	var resume = _make_btn("RESUME OPERATION", Color(0.96, 0.95, 0.92, 1.0))
	resume.pressed.connect(_on_resume)
	vbox.add_child(resume)

	var restart = _make_btn("RESTART ARRIVAL", Color(0.76, 0.74, 0.70, 1.0))
	restart.pressed.connect(_on_restart)
	vbox.add_child(restart)

	var quit = _make_btn("DISCONNECT TERMINAL", Color(0.76, 0.74, 0.70, 1.0))
	quit.pressed.connect(_on_quit)
	vbox.add_child(quit)

	print("[PauseMenu] Suspension overlay ready.")

func _make_btn(txt: String, col: Color) -> Button:
	var btn = Button.new()
	btn.text = txt
	btn.flat = true
	btn.custom_minimum_size = Vector2(280, 40)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", col)
	btn.add_theme_color_override("font_hover_color", Color(0.76, 0.59, 0.31, 1.0))
	return btn

func _on_resume():
	AudioManager.play_ui_click()
	UIManager.toggle_pause()

func _on_restart():
	AudioManager.play_ui_click()
	UIManager.toggle_pause()
	GameManager.start_vertical_slice()

func _on_quit():
	AudioManager.play_ui_click()
	UIManager.toggle_pause()
	GameManager.load_title_screen()
