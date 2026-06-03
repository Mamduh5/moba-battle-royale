class_name ModeSelectScreen
extends Control

signal start_with_bots(mode_id: String, hero_id: String)
signal host_match(room_code: String)
signal join_match(mode_id: String, hero_id: String, room_code: String)
signal back_pressed

var _content_db: Object = null
var _selected_mode := GameConstants.MODE_TEAM_ARENA
var _selected_hero := GameConstants.DEFAULT_HERO
var _room_field: LineEdit = null
var _room_label: Label = null
var _mode_buttons: Dictionary = {}

func setup(content_db: Object, selected_mode: String, selected_hero: String) -> void:
	_content_db = content_db
	_selected_mode = selected_mode
	_selected_hero = selected_hero
	if is_inside_tree():
		_rebuild()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	_mode_buttons.clear()
	var bg := ArenaBackdrop.new()
	bg.variant = "menu"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var shell := MarginContainer.new()
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.add_theme_constant_override("margin_left", 84)
	shell.add_theme_constant_override("margin_top", 54)
	shell.add_theme_constant_override("margin_right", 84)
	shell.add_theme_constant_override("margin_bottom", 48)
	add_child(shell)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 28)
	shell.add_child(columns)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 0)
	ArenaStyle.style_panel_container(panel, Color(0.050, 0.080, 0.090, 0.94), Color(0.310, 0.900, 0.840, 0.34))
	columns.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	var eyebrow := Label.new()
	eyebrow.text = "LOCAL ARENA SETUP"
	ArenaStyle.style_label(eyebrow, 13, ArenaStyle.GOLD)
	box.add_child(eyebrow)
	var title := Label.new()
	title.text = "Choose Your Match"
	ArenaStyle.style_label(title, 42)
	box.add_child(title)
	var modes := HBoxContainer.new()
	modes.add_theme_constant_override("separation", 12)
	box.add_child(modes)
	_add_mode_button(modes, GameConstants.MODE_TEAM_ARENA, "3v3 Team Arena", "Two squads, score race, bot-filled teams.")
	_add_mode_button(modes, GameConstants.MODE_DEATHMATCH, "25 Player Deathmatch", "Free-for-all chaos with live ranking.")
	ArenaStyle.add_section_label(box, "Hero")
	var hero_select := OptionButton.new()
	ArenaStyle.style_option(hero_select)
	if _content_db != null:
		for hero_id in _content_db.get_all_heroes().keys():
			var hero: HeroDef = _content_db.get_hero(str(hero_id))
			hero_select.add_item(hero.display_name)
			hero_select.set_item_metadata(hero_select.item_count - 1, hero.id)
			if hero.id == _selected_hero:
				hero_select.select(hero_select.item_count - 1)
	hero_select.item_selected.connect(func(index: int) -> void:
		_selected_hero = str(hero_select.get_item_metadata(index))
	)
	box.add_child(hero_select)
	ArenaStyle.add_section_label(box, "Friend / LAN")
	var room_row := HBoxContainer.new()
	room_row.add_theme_constant_override("separation", 10)
	box.add_child(room_row)
	_room_field = LineEdit.new()
	_room_field.text = "LOCAL"
	_room_field.custom_minimum_size = Vector2(220, 44)
	ArenaStyle.style_line_edit(_room_field)
	room_row.add_child(_room_field)
	var host := Button.new()
	host.text = "Host Match"
	ArenaStyle.style_button(host, "secondary", Vector2(142, 44))
	host.pressed.connect(_on_host_pressed)
	room_row.add_child(host)
	var join := Button.new()
	join.text = "Join Match"
	ArenaStyle.style_button(join, "secondary", Vector2(142, 44))
	join.pressed.connect(func() -> void:
		join_match.emit(_selected_mode, _selected_hero, _normalized_room_code())
	)
	room_row.add_child(join)
	_room_label = Label.new()
	_room_label.text = "Room Code: LOCAL"
	ArenaStyle.style_label(_room_label, 16, ArenaStyle.TEXT_MUTED)
	box.add_child(_room_label)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 12)
	box.add_child(action_row)
	var start := Button.new()
	start.text = "Start With Bots"
	ArenaStyle.style_button(start, "primary", Vector2(250, 50))
	start.pressed.connect(func() -> void:
		start_with_bots.emit(_selected_mode, _selected_hero)
	)
	action_row.add_child(start)
	var back := Button.new()
	back.text = "Back"
	ArenaStyle.style_button(back, "secondary", Vector2(132, 50))
	back.pressed.connect(func() -> void: back_pressed.emit())
	action_row.add_child(back)
	_add_preview_panel(columns)
	_update_mode_buttons()

func _add_mode_button(parent: Node, mode_id: String, title: String, subline: String) -> void:
	var button := Button.new()
	button.text = "%s\n%s" % [title, subline]
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(310, 78)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	ArenaStyle.style_button(button, "secondary", Vector2(310, 78))
	button.pressed.connect(func() -> void:
		_selected_mode = mode_id
		_update_mode_buttons()
	)
	parent.add_child(button)
	_mode_buttons[mode_id] = button

func _add_preview_panel(parent: Node) -> void:
	var preview := PanelContainer.new()
	preview.custom_minimum_size = Vector2(330, 0)
	ArenaStyle.style_panel_container(preview, Color(0.035, 0.055, 0.064, 0.86), Color(1.000, 0.765, 0.275, 0.28))
	parent.add_child(preview)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	preview.add_child(box)
	var title := Label.new()
	title.text = "Combat Readability"
	ArenaStyle.style_label(title, 24)
	box.add_child(title)
	var lines := Label.new()
	lines.text = "Bold silhouettes\nAbility icons\nServer-owned bot fill\nLAN friend smoke path\nRank and score HUD"
	lines.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ArenaStyle.style_label(lines, 17, ArenaStyle.TEXT_MUTED)
	box.add_child(lines)
	var art := Control.new()
	art.custom_minimum_size = Vector2(300, 260)
	art.draw.connect(func() -> void:
		var c := art.size * 0.5
		art.draw_circle(c + Vector2(-88, -12), 42, Color(0.070, 0.145, 0.165, 1))
		art.draw_colored_polygon(PackedVector2Array([c + Vector2(-88, -72), c + Vector2(-34, -18), c + Vector2(-72, 70), c + Vector2(-126, -18)]), ArenaStyle.BLUE)
		art.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -86), c + Vector2(62, 36), c + Vector2(8, 86), c + Vector2(-56, 32)]), ArenaStyle.PURPLE)
		art.draw_circle(c + Vector2(92, 8), 42, Color(0.920, 0.560, 0.150, 1))
		art.draw_arc(c + Vector2(92, 8), 58, 0, TAU, 44, ArenaStyle.GOLD, 4)
		art.draw_line(c + Vector2(-128, 94), c + Vector2(138, 94), ArenaStyle.LINE, 3)
	)
	box.add_child(art)

func _update_mode_buttons() -> void:
	for mode_id in _mode_buttons.keys():
		var button: Button = _mode_buttons[mode_id]
		button.button_pressed = mode_id == _selected_mode
		ArenaStyle.style_button(button, "selected" if mode_id == _selected_mode else "secondary", Vector2(310, 78))

func _on_host_pressed() -> void:
	var code := "ROOM%04d" % (Time.get_ticks_msec() % 10000)
	if _room_field != null:
		_room_field.text = code
	if _room_label != null:
		_room_label.text = "Room Code: %s" % code
	host_match.emit(code)

func _normalized_room_code() -> String:
	if _room_field == null:
		return "LOCAL"
	var code := _room_field.text.strip_edges()
	return "LOCAL" if code == "" else code
