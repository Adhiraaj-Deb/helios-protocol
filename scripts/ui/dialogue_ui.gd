extends Control

# DialogueUI: Branching conversation overlay. All nodes built in code.

var speaker_lbl: Label
var text_lbl: Label
var choices_container: VBoxContainer

var type_speed: float = 0.025
var full_text: String = ""
var typing_active: bool = false
var stored_choices: Array = []

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Dim top background (let 3D show through)
	# Bottom dialogue box
	var box = PanelContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	box.offset_left = 80.0
	box.offset_top = -240.0
	box.offset_right = -80.0
	box.offset_bottom = -24.0
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(box)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 16)
	box.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	
	speaker_lbl = Label.new()
	speaker_lbl.add_theme_color_override("font_color", Color(0.76, 0.59, 0.31, 1.0))
	speaker_lbl.add_theme_font_size_override("font_size", 13)
	speaker_lbl.text = "SPEAKER"
	vbox.add_child(speaker_lbl)
	
	text_lbl = Label.new()
	text_lbl.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92, 1.0))
	text_lbl.add_theme_font_size_override("font_size", 15)
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	text_lbl.custom_minimum_size = Vector2(0, 52)
	vbox.add_child(text_lbl)
	
	choices_container = VBoxContainer.new()
	choices_container.add_theme_constant_override("separation", 6)
	vbox.add_child(choices_container)
	
	# Connect to DialogueManager signals
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_updated.connect(_on_dialogue_updated)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	print("[DialogueUI] Conversation panel active.")

func _on_dialogue_started(_npc: String):
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_dialogue_updated(speaker: String, text: String, choices: Array):
	speaker_lbl.text = speaker.to_upper()
	full_text = text
	stored_choices = choices
	for child in choices_container.get_children():
		child.queue_free()
	_run_typewriter()

func _on_dialogue_ended():
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not UIManager.is_node_ui_open and not UIManager.is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _run_typewriter():
	typing_active = true
	text_lbl.text = ""
	var i = 0
	while i < full_text.length():
		if not typing_active:
			break
		i += 1
		text_lbl.text = full_text.substr(0, i)
		await get_tree().create_timer(type_speed).timeout
	typing_active = false
	text_lbl.text = full_text
	_populate_choices()

func _populate_choices():
	for child in choices_container.get_children():
		child.queue_free()
	for i in range(stored_choices.size()):
		var choice = stored_choices[i]
		var mod_str = ""
		if choice.trust_mods.size() > 0:
			var parts = []
			for c in choice.trust_mods.keys():
				parts.append("%s %+d" % [c, choice.trust_mods[c]])
			mod_str = "  (" + ", ".join(parts) + ")"
		var btn = Button.new()
		btn.text = "  [%d]  %s%s" % [i + 1, choice.text, mod_str]
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 13)
		btn.add_theme_color_override("font_color", Color(0.9, 0.88, 0.85, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.76, 0.59, 0.31, 1.0))
		btn.pressed.connect(_on_choice.bind(i))
		choices_container.add_child(btn)

func _on_choice(index: int):
	AudioManager.play_ui_click()
	if typing_active:
		typing_active = false
		return
	DialogueManager.select_choice(index)
