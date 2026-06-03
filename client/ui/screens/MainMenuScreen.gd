class_name MainMenuScreen
extends Control

signal quick_start_pressed
signal mode_select_pressed

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ArenaBackdrop.new()
	bg.variant = "menu"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var shell := MarginContainer.new()
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.add_theme_constant_override("margin_left", 92)
	shell.add_theme_constant_override("margin_top", 76)
	shell.add_theme_constant_override("margin_right", 92)
	shell.add_theme_constant_override("margin_bottom", 64)
	add_child(shell)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 34)
	shell.add_child(columns)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 0)
	ArenaStyle.style_panel_container(panel, Color(0.045, 0.075, 0.085, 0.94), Color(0.380, 1.000, 0.920, 0.36))
	columns.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	var eyebrow := Label.new()
	eyebrow.text = "SERVER-AUTHORITATIVE HERO ARENA"
	ArenaStyle.style_label(eyebrow, 13, ArenaStyle.GOLD)
	box.add_child(eyebrow)
	var title := Label.new()
	title.text = "Arena Royale"
	ArenaStyle.style_label(title, 58)
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Choose a hero, fill the arena with bots, and fight through a full arcade match to the result screen."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ArenaStyle.style_label(subtitle, 19, ArenaStyle.TEXT_MUTED)
	box.add_child(subtitle)
	var quick := Button.new()
	quick.text = "Quick Start Team Arena"
	ArenaStyle.style_button(quick, "primary", Vector2(360, 52))
	quick.pressed.connect(func() -> void: quick_start_pressed.emit())
	box.add_child(quick)
	var modes := Button.new()
	modes.text = "Mode Select"
	ArenaStyle.style_button(modes, "secondary", Vector2(360, 52))
	modes.pressed.connect(func() -> void: mode_select_pressed.emit())
	box.add_child(modes)
	var mode_line := Label.new()
	mode_line.text = "3v3 Team Arena  /  25 Player Deathmatch  /  LAN friend bot fill"
	mode_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ArenaStyle.style_label(mode_line, 15, ArenaStyle.TEXT_MUTED)
	box.add_child(mode_line)
	_add_preview(columns)

func _add_preview(parent: Node) -> void:
	var preview := PanelContainer.new()
	preview.custom_minimum_size = Vector2(420, 0)
	ArenaStyle.style_panel_container(preview, Color(0.030, 0.052, 0.060, 0.84), Color(1.000, 0.765, 0.275, 0.25))
	parent.add_child(preview)
	var art := Control.new()
	art.custom_minimum_size = Vector2(390, 430)
	art.draw.connect(func() -> void:
		var c := art.size * 0.5
		art.draw_rect(Rect2(Vector2(22, 32), art.size - Vector2(44, 64)), Color(0.050, 0.140, 0.155, 0.92), true)
		for x in range(42, int(art.size.x - 36), 56):
			art.draw_line(Vector2(x, 34), Vector2(x, art.size.y - 34), Color(0.300, 0.930, 0.880, 0.12), 1.0)
		for y in range(54, int(art.size.y - 36), 56):
			art.draw_line(Vector2(24, y), Vector2(art.size.x - 24, y), Color(0.300, 0.930, 0.880, 0.12), 1.0)
		art.draw_rect(Rect2(c + Vector2(-54, -42), Vector2(108, 84)), Color(0.100, 0.230, 0.250, 0.92), true)
		art.draw_rect(Rect2(c + Vector2(-54, -42), Vector2(108, 84)), Color(0.520, 1.000, 0.930, 0.32), false, 2.0)
		_draw_guardian(art, c + Vector2(-105, 52))
		_draw_shade(art, c + Vector2(0, -64))
		_draw_arcanist(art, c + Vector2(112, 54))
		art.draw_arc(c + Vector2(-105, 52), 46, 0, TAU, 40, ArenaStyle.GOLD, 3)
		art.draw_line(c + Vector2(-150, 130), c + Vector2(150, 130), Color(1.0, 0.76, 0.28, 0.42), 3)
	)
	preview.add_child(art)

func _draw_guardian(canvas: CanvasItem, p: Vector2) -> void:
	canvas.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -42), p + Vector2(38, -12), p + Vector2(24, 42), p + Vector2(0, 55), p + Vector2(-24, 42), p + Vector2(-38, -12)]), ArenaStyle.BLUE)
	canvas.draw_line(p + Vector2(0, -34), p + Vector2(0, 42), ArenaStyle.GOLD, 5)

func _draw_shade(canvas: CanvasItem, p: Vector2) -> void:
	canvas.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -54), p + Vector2(38, 8), p + Vector2(8, 58), p + Vector2(-42, 12)]), ArenaStyle.PURPLE)
	canvas.draw_line(p + Vector2(-24, 28), p + Vector2(26, -22), Color(0.360, 1.000, 0.730), 4)

func _draw_arcanist(canvas: CanvasItem, p: Vector2) -> void:
	canvas.draw_circle(p, 34, Color(0.920, 0.570, 0.165))
	canvas.draw_circle(p + Vector2(0, -42), 15, Color(0.180, 0.950, 0.800))
	canvas.draw_line(p + Vector2(34, -22), p + Vector2(48, 48), Color(0.180, 0.950, 0.800), 5)
