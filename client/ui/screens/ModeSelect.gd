class_name ModeSelect
extends Control

signal mode_selected(mode_id: String)
signal back_requested

func _ready() -> void:
	theme = ArenaTheme.create_theme()
	_build()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BG_2, true)
	draw_rect(Rect2(Vector2(60, 68), Vector2(size.x - 120, size.y - 136)), Color("#101826", 0.62), true)
	draw_rect(Rect2(Vector2(60, 68), Vector2(size.x - 120, size.y - 136)), ArenaTheme.COLOR_BLUE, false, 2.0)

func _build() -> void:
	var title := Label.new()
	title.text = "SELECT BATTLE MODE"
	title.anchor_left = 0.0
	title.anchor_right = 1.0
	title.offset_top = 34
	title.offset_bottom = 86
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", ArenaTheme.COLOR_GOLD)
	add_child(title)
	var container := HBoxContainer.new()
	container.anchor_left = 0.5
	container.anchor_right = 0.5
	container.anchor_top = 0.5
	container.anchor_bottom = 0.5
	container.offset_left = -470
	container.offset_right = 470
	container.offset_top = -170
	container.offset_bottom = 170
	container.add_theme_constant_override("separation", 28)
	add_child(container)
	container.add_child(_mode_card("3v3 Team Arena", "Balanced teams, compact chaos, first to 12 kills.", "3v3_team_arena", ArenaTheme.COLOR_BLUE))
	container.add_child(_mode_card("25 Player Deathmatch", "No teams. Fight for top rank with 24 combatants around you.", "25_player_deathmatch", ArenaTheme.COLOR_RED))
	var back := Button.new()
	back.text = "Back"
	back.anchor_left = 0.5
	back.anchor_right = 0.5
	back.anchor_bottom = 1.0
	back.anchor_top = 1.0
	back.offset_left = -90
	back.offset_right = 90
	back.offset_top = -82
	back.offset_bottom = -32
	back.pressed.connect(back_requested.emit)
	add_child(back)

func _mode_card(title: String, body: String, mode_id: String, color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(450, 300)
	panel.add_theme_stylebox_override("panel", ArenaTheme.panel_style(Color("#172235"), color, 0.94))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var header := Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 27)
	header.add_theme_color_override("font_color", color)
	box.add_child(header)
	var art := Control.new()
	art.custom_minimum_size = Vector2(0, 108)
	art.draw.connect(func() -> void:
		art.draw_rect(Rect2(Vector2.ZERO, art.size), Color("#101826"), true)
		for i in range(8 if mode_id == "25_player_deathmatch" else 6):
			var x := 30.0 + float(i % 5) * 72.0
			var y := 32.0 + float(i / 5) * 46.0
			art.draw_circle(Vector2(x, y), 14.0, color if i == 0 else ArenaTheme.COLOR_MUTED)
		art.draw_rect(Rect2(Vector2.ZERO, art.size), color, false, 2.0)
	)
	box.add_child(art)
	var label := Label.new()
	label.text = body
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", ArenaTheme.COLOR_MUTED)
	box.add_child(label)
	var button := Button.new()
	button.text = "Start"
	button.pressed.connect(func() -> void: mode_selected.emit(mode_id))
	box.add_child(button)
	return panel
