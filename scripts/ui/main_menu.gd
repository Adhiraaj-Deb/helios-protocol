extends Control

# MainMenu: Builds itself entirely in code — no brittle node path dependencies.

var start_button: Button
var options_button: Button
var exit_button: Button

func _ready():
	# Full-screen anchoring
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Dark charcoal background
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.11, 0.10, 0.09, 1.0)
	add_child(bg)
	
	# Gold brand stripe at top
	var stripe = ColorRect.new()
	stripe.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	stripe.custom_minimum_size = Vector2(0, 6)
	stripe.color = Color(0.76, 0.59, 0.31, 1.0)
	add_child(stripe)
	
	# Center container
	var center = VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.offset_left = -220.0
	center.offset_top = -160.0
	center.offset_right = 220.0
	center.offset_bottom = 160.0
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 20)
	add_child(center)
	
	# Title label
	var title = Label.new()
	title.text = "HELIOS PROTOCOL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92, 1.0))
	title.add_theme_font_size_override("font_size", 48)
	center.add_child(title)
	
	# Subtitle
	var sub = Label.new()
	sub.text = "PART ONE: THE ARRIVAL"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color(0.76, 0.59, 0.31, 1.0))
	sub.add_theme_font_size_override("font_size", 16)
	center.add_child(sub)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	center.add_child(spacer)
	
	# Start button
	start_button = _make_button("START VERTICAL SLICE", Color(0.96, 0.95, 0.92, 1.0))
	center.add_child(start_button)
	start_button.pressed.connect(_on_start_pressed)
	
	# Options button
	options_button = _make_button("SYSTEM OPTIONS", Color(0.76, 0.74, 0.70, 1.0))
	center.add_child(options_button)
	options_button.pressed.connect(_on_options_pressed)
	
	# Exit button
	exit_button = _make_button("DISCONNECT TERMINAL", Color(0.76, 0.74, 0.70, 1.0))
	center.add_child(exit_button)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Footer
	var footer = Label.new()
	footer.text = "CLASSIFIED. UNAUTHORIZED ACCESS PROHIBITED UNDER PROTOCOL 4A."
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -36.0
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color(0.35, 0.33, 0.31, 1.0))
	footer.add_theme_font_size_override("font_size", 11)
	add_child(footer)

func _make_button(label_text: String, col: Color) -> Button:
	var btn = Button.new()
	btn.text = label_text
	btn.flat = true
	btn.custom_minimum_size = Vector2(320, 44)
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", col)
	btn.add_theme_color_override("font_hover_color", Color(0.76, 0.59, 0.31, 1.0))
	return btn

func _on_start_pressed():
	AudioManager.play_ui_click()
	GameManager.start_vertical_slice()

func _on_options_pressed():
	AudioManager.play_ui_click()
	print("[MainMenu] Options (placeholder).")

func _on_exit_pressed():
	AudioManager.play_ui_click()
	get_tree().quit()
