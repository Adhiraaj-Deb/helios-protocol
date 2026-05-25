extends Control

# HUD: Persistent gameplay overlay. All nodes built in code for reliability.

var stealth_label: Label
var prompt_panel: PanelContainer
var prompt_label: Label
var toast_panel: PanelContainer
var toast_title_label: Label
var toast_desc_label: Label
var toast_timer: Timer

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks pass through to game
	
	# --- Stealth indicator (top-right) ---
	stealth_label = Label.new()
	stealth_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	stealth_label.offset_left = -260.0
	stealth_label.offset_top = 20.0
	stealth_label.offset_right = -20.0
	stealth_label.offset_bottom = 50.0
	stealth_label.text = "[o] UNNOTICED"
	stealth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stealth_label.add_theme_font_size_override("font_size", 16)
	stealth_label.add_theme_color_override("font_color", Color(0.70, 0.70, 0.65, 1.0))
	stealth_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stealth_label)
	
	# --- Interaction prompt (bottom-center) ---
	prompt_panel = PanelContainer.new()
	prompt_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	prompt_panel.offset_left = 300.0
	prompt_panel.offset_top = -110.0
	prompt_panel.offset_right = -300.0
	prompt_panel.offset_bottom = -60.0
	prompt_panel.visible = false
	prompt_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(prompt_panel)
	
	prompt_label = Label.new()
	prompt_label.text = "Press E to Interact"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 15)
	prompt_label.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92, 1.0))
	prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_panel.add_child(prompt_label)
	
	# --- Toast notification (top-left) ---
	toast_panel = PanelContainer.new()
	toast_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	toast_panel.offset_right = 600.0
	toast_panel.offset_bottom = 160.0
	toast_panel.offset_left = 20.0
	toast_panel.offset_top = 20.0
	toast_panel.visible = false
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast_panel)
	
	var toast_vbox = VBoxContainer.new()
	toast_vbox.add_theme_constant_override("separation", 4)
	toast_panel.add_child(toast_vbox)
	
	toast_title_label = Label.new()
	toast_title_label.add_theme_color_override("font_color", Color(0.76, 0.59, 0.31, 1.0))
	toast_title_label.add_theme_font_size_override("font_size", 22)
	toast_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_vbox.add_child(toast_title_label)
	
	toast_desc_label = Label.new()
	toast_desc_label.add_theme_color_override("font_color", Color(0.92, 0.90, 0.87, 1.0))
	toast_desc_label.add_theme_font_size_override("font_size", 18)
	toast_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	toast_desc_label.custom_minimum_size = Vector2(560, 0)
	toast_desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_vbox.add_child(toast_desc_label)
	
	# Timer for toast auto-hide
	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.timeout.connect(_on_toast_timeout)
	add_child(toast_timer)
	
	print("[HUD] Overlay active.")

# Called by UIManager
func set_prompt(text: String):
	prompt_label.text = text
	prompt_panel.visible = true

func clear_prompt():
	prompt_panel.visible = false

func update_stealth_indicator(state: String):
	match state.to_upper():
		"UNNOTICED":
			stealth_label.text = "[o]  UNNOTICED"
			stealth_label.add_theme_color_override("font_color", Color(0.70, 0.70, 0.65, 1.0))
		"SUSPICIOUS":
			stealth_label.text = "[?]  SUSPICIOUS"
			stealth_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.35, 1.0))
		"COMPROMISED":
			stealth_label.text = "[!]  COMPROMISED"
			stealth_label.add_theme_color_override("font_color", Color(0.90, 0.28, 0.24, 1.0))

func display_toast(title: String, desc: String):
	toast_title_label.text = "CLUE RETRIEVED: " + title.to_upper()
	toast_desc_label.text = desc
	toast_panel.visible = true
	toast_timer.stop()
	toast_timer.start(4.5)

func _on_toast_timeout():
	toast_panel.visible = false
