extends Control

# NodeUI: Maya's secure surveillance tablet. All nodes built in code.

var map_panel: Control
var evidence_panel: Control
var messages_panel: Control
var profile_panel: Control

var fragments_list: VBoxContainer
var links_list: VBoxContainer
var questions_list: VBoxContainer

var dara_bar: ProgressBar
var dara_val: Label
var sable_bar: ProgressBar
var sable_val: Label
var ashfield_bar: ProgressBar
var ashfield_val: Label
var leon_bar: ProgressBar
var leon_val: Label

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Dark translucent background overlay
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.13, 0.12, 0.11, 0.96)
	add_child(bg)
	
	# Sidebar
	var sidebar = _make_panel(Color(0.10, 0.09, 0.08, 1.0))
	sidebar.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	sidebar.offset_right = 240.0
	add_child(sidebar)
	
	var sidebar_vbox = VBoxContainer.new()
	sidebar_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sidebar_vbox.offset_top = 20.0
	sidebar_vbox.offset_left = 8.0
	sidebar_vbox.add_theme_constant_override("separation", 4)
	sidebar.add_child(sidebar_vbox)
	
	# Sidebar title
	var title_lbl = Label.new()
	title_lbl.text = "HELIOS PROTOCOL"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_color_override("font_color", Color(0.76, 0.59, 0.31, 1.0))
	title_lbl.add_theme_font_size_override("font_size", 16)
	sidebar_vbox.add_child(title_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = "SECURE NODE v4.11"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_color_override("font_color", Color(0.40, 0.38, 0.35, 1.0))
	sub_lbl.add_theme_font_size_override("font_size", 10)
	sidebar_vbox.add_child(sub_lbl)
	
	# Separator
	var sep = HSeparator.new()
	sidebar_vbox.add_child(sep)
	
	# Tab buttons
	var tabs = [["[I]  SATELLITE MAP", "map"], ["[II]  EVIDENCE", "evidence"],
				["[III]  CAPTURED COMS", "messages"], ["[IV]  PROFILES", "profile"]]
	for tab in tabs:
		var btn = Button.new()
		btn.text = tab[0]
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 44)
		btn.add_theme_font_size_override("font_size", 13)
		btn.add_theme_color_override("font_color", Color(0.9, 0.88, 0.85, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.76, 0.59, 0.31, 1.0))
		var tab_key = tab[1]
		btn.pressed.connect(_switch_tab.bind(tab_key))
		sidebar_vbox.add_child(btn)
	
	# Content area
	var content_area = Control.new()
	content_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_area.offset_left = 250.0
	content_area.offset_top = 20.0
	content_area.offset_right = -20.0
	content_area.offset_bottom = -20.0
	add_child(content_area)
	
	# Build each panel
	map_panel = _build_map_panel(content_area)
	evidence_panel = _build_evidence_panel(content_area)
	messages_panel = _build_messages_panel(content_area)
	profile_panel = _build_profile_panel(content_area)
	
	_switch_tab("map")
	print("[NodeUI] Tablet interface active.")

func _make_panel(col: Color) -> ColorRect:
	var p = ColorRect.new()
	p.color = col
	return p

func _make_section_title(text: String) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", Color(0.76, 0.59, 0.31, 1.0))
	lbl.add_theme_font_size_override("font_size", 18)
	return lbl

func _build_map_panel(parent: Control) -> Control:
	var panel = Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(panel)
	
	var title = _make_section_title("SOLARIS ISLE — INFILTRATION GRID")
	title.offset_bottom = 32
	panel.add_child(title)
	
	var map_bg = ColorRect.new()
	map_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_bg.offset_top = 40.0
	map_bg.color = Color(0.17, 0.16, 0.15, 1.0)
	panel.add_child(map_bg)
	
	var map_lbl = Label.new()
	map_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_lbl.offset_left = 20.0
	map_lbl.offset_top = 56.0
	map_lbl.offset_right = -20.0
	map_lbl.add_theme_color_override("font_color", Color(0.50, 0.48, 0.45, 1.0))
	map_lbl.add_theme_font_size_override("font_size", 13)
	map_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	map_lbl.text = "+ - - - - - - - - - - - - - - - - - +\n|  [ARRIVAL TERRACE]       [POOL]  |\n|     (o) MAYA                     |\n|  [SOLARIUM LOBBY]    [TERMINAL]  |\n|  [SECURITY CORRIDOR] [CAM ZONE]  |\n|     (x) DARA      [GATE]         |\n+ - - - - - - - - - - - - - - - - - +"
	panel.add_child(map_lbl)
	return panel

func _build_evidence_panel(parent: Control) -> Control:
	var panel = Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(panel)
	
	var title = _make_section_title("INVESTIGATION LOGS & INTEL")
	panel.add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 40.0
	panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)
	
	# Fragments section
	vbox.add_child(_make_category_title("[A] PHYSICAL FRAGMENTS"))
	fragments_list = VBoxContainer.new()
	vbox.add_child(fragments_list)
	
	vbox.add_child(_make_category_title("[B] SURVEILLANCE LINKS"))
	links_list = VBoxContainer.new()
	vbox.add_child(links_list)
	
	vbox.add_child(_make_category_title("[C] OPEN HYPOTHESES"))
	questions_list = VBoxContainer.new()
	vbox.add_child(questions_list)
	
	return panel

func _make_category_title(text: String) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92, 1.0))
	lbl.add_theme_font_size_override("font_size", 14)
	return lbl

func _build_messages_panel(parent: Control) -> Control:
	var panel = Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(panel)
	
	var title = _make_section_title("DECRYPTED COMMS")
	panel.add_child(title)
	
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.offset_top = 40.0
	bg.color = Color(0.17, 0.16, 0.15, 1.0)
	panel.add_child(bg)
	
	var lbl = Label.new()
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.offset_left = 16.0
	lbl.offset_top = 56.0
	lbl.offset_right = -16.0
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.add_theme_color_override("font_color", Color(0.90, 0.88, 0.85, 1.0))
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.text = "[10:24] SABLE [SECURE B-4]\nSable: You've passed the arrival gate. We are running out of time.\nSable: Dara is sympathetic but suspicious. Earn her trust first.\n\n[10:25] SABLE\nSable: Beware of Leon. He is watching the Solarium closely.\n\n[10:26] SYSTEM\nWarning: Subnet wiretapping detected. Stay dark."
	panel.add_child(lbl)
	return panel

func _build_profile_panel(parent: Control) -> Control:
	var panel = Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(panel)
	
	var title = _make_section_title("PERSONNEL DOSSIERS")
	panel.add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 40.0
	panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(vbox)
	
	# Build rows
	var dara_row = _make_profile_row("DARA OSEI — Research Lead", Color(0.96, 0.95, 0.92, 1.0))
	dara_bar = dara_row[0]; dara_val = dara_row[1]
	vbox.add_child(dara_row[2])
	
	var sable_row = _make_profile_row("SABLE — Handler", Color(0.96, 0.95, 0.92, 1.0))
	sable_bar = sable_row[0]; sable_val = sable_row[1]
	vbox.add_child(sable_row[2])
	
	var ash_row = _make_profile_row("DR. ASHFIELD — Medical Director", Color(0.96, 0.95, 0.92, 1.0))
	ashfield_bar = ash_row[0]; ashfield_val = ash_row[1]
	vbox.add_child(ash_row[2])
	
	var leon_row = _make_profile_row("LEON HARGROVE — Security Director", Color(0.90, 0.28, 0.24, 1.0))
	leon_bar = leon_row[0]; leon_val = leon_row[1]
	vbox.add_child(leon_row[2])
	
	return panel

# Returns [ProgressBar, Label, VBoxContainer_parent]
func _make_profile_row(name_text: String, name_color: Color) -> Array:
	var row = VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	
	var name_lbl = Label.new()
	name_lbl.text = name_text
	name_lbl.add_theme_color_override("font_color", name_color)
	name_lbl.add_theme_font_size_override("font_size", 15)
	row.add_child(name_lbl)
	
	var bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 18)
	bar.value = 50.0
	row.add_child(bar)
	
	var val_lbl = Label.new()
	val_lbl.add_theme_color_override("font_color", Color(0.70, 0.68, 0.65, 1.0))
	val_lbl.add_theme_font_size_override("font_size", 11)
	val_lbl.text = "TRUST VALUE: +0"
	row.add_child(val_lbl)
	
	return [bar, val_lbl, row]

func refresh_data():
	_populate_list(fragments_list, "fragments")
	_populate_list(links_list, "links")
	_populate_list(questions_list, "questions")
	_update_bar("Dara", dara_bar, dara_val)
	_update_bar("Sable", sable_bar, sable_val)
	_update_bar("Dr. Ashfield", ashfield_bar, ashfield_val)
	_update_bar("Leon", leon_bar, leon_val)
	print("[NodeUI] Data refreshed.")

func _switch_tab(tab: String):
	AudioManager.play_ui_click()
	map_panel.visible = (tab == "map")
	evidence_panel.visible = (tab == "evidence")
	messages_panel.visible = (tab == "messages")
	profile_panel.visible = (tab == "profile")
	if tab == "evidence":
		_populate_list(fragments_list, "fragments")
		_populate_list(links_list, "links")
		_populate_list(questions_list, "questions")
	elif tab == "profile":
		_update_bar("Dara", dara_bar, dara_val)
		_update_bar("Sable", sable_bar, sable_val)
		_update_bar("Dr. Ashfield", ashfield_bar, ashfield_val)
		_update_bar("Leon", leon_bar, leon_val)

func _populate_list(container: VBoxContainer, category: String):
	for child in container.get_children():
		child.queue_free()
	var items = EvidenceManager.get_collected_by_category(category)
	if items.is_empty():
		var lbl = Label.new()
		lbl.text = "  — No records —"
		lbl.add_theme_color_override("font_color", Color(0.4, 0.38, 0.35, 1.0))
		lbl.add_theme_font_size_override("font_size", 12)
		container.add_child(lbl)
		return
	for item in items:
		var box = VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		var t = Label.new()
		t.text = "> " + item.title.to_upper()
		t.add_theme_color_override("font_color", Color(0.76, 0.59, 0.31, 1.0))
		t.add_theme_font_size_override("font_size", 13)
		box.add_child(t)
		var d = Label.new()
		d.text = "  " + item.description
		d.autowrap_mode = TextServer.AUTOWRAP_WORD
		d.add_theme_color_override("font_color", Color(0.88, 0.86, 0.83, 1.0))
		d.add_theme_font_size_override("font_size", 11)
		box.add_child(d)
		container.add_child(box)

func _update_bar(char_name: String, bar: ProgressBar, lbl: Label):
	var val = DialogueManager.get_trust(char_name)
	bar.value = ((val + 100.0) / 200.0) * 100.0
	if char_name == "Leon":
		lbl.text = "SUSPICION: %d%%" % int(100 - ((val + 100.0) / 2.0))
	else:
		lbl.text = "TRUST: %+d" % val
