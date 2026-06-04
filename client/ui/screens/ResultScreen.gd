class_name ResultScreen
extends Control

signal restart_requested(mode_id: String)
signal menu_requested

var result: Dictionary = {}
var local_player_id := GameConstants.LOCAL_PLAYER_ID

func _ready() -> void:
	theme = ArenaTheme.create_theme()

func show_result(next_result: Dictionary, player_id: String) -> void:
	result = next_result.duplicate(true)
	local_player_id = player_id
	_build()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BG, true)
	draw_circle(size * 0.5 + Vector2(-360, -140), 130, Color("#30D1C8", 0.10))
	draw_circle(size * 0.5 + Vector2(350, 160), 150, Color("#FF4D8D", 0.09))

func _build() -> void:
	for child in get_children():
		child.queue_free()
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -380
	panel.offset_right = 380
	panel.offset_top = -280
	panel.offset_bottom = 280
	panel.add_theme_stylebox_override("panel", ArenaTheme.panel_style(Color("#172235"), ArenaTheme.COLOR_GOLD, 0.96))
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var title := Label.new()
	title.text = _title_text()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", ArenaTheme.COLOR_GOLD)
	box.add_child(title)
	var reason := Label.new()
	reason.text = "Finished by %s at tick %d" % [str(result.get("reason", "")), int(result.get("server_tick", 0))]
	reason.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reason.add_theme_color_override("font_color", ArenaTheme.COLOR_MUTED)
	box.add_child(reason)
	var rankings: Array = result.get("player_results", [])
	for i in range(min(8, rankings.size())):
		var entry: Dictionary = rankings[i]
		var row := Label.new()
		row.text = "#%d  %-12s  score %02d  K/D %d/%d" % [int(entry.get("rank", i + 1)), str(entry.get("display_name", "")), int(entry.get("score", 0)), int(entry.get("kills", 0)), int(entry.get("deaths", 0))]
		row.add_theme_font_size_override("font_size", 18)
		row.add_theme_color_override("font_color", ArenaTheme.COLOR_TEXT if str(entry.get("player_id", "")) == local_player_id else ArenaTheme.COLOR_MUTED)
		box.add_child(row)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	box.add_child(buttons)
	var restart := Button.new()
	restart.text = "Restart"
	restart.pressed.connect(func() -> void: restart_requested.emit(str(result.get("mode_id", "3v3_team_arena"))))
	buttons.add_child(restart)
	var menu := Button.new()
	menu.text = "Main Menu"
	menu.pressed.connect(menu_requested.emit)
	buttons.add_child(menu)

func _title_text() -> String:
	var mode_id := str(result.get("mode_id", ""))
	if mode_id == "3v3_team_arena":
		return "VICTORY" if int(result.get("winning_team_id", 0)) == GameConstants.TEAM_BLUE else "DEFEAT"
	var rankings: Array = result.get("player_results", [])
	for entry in rankings:
		if str(entry.get("player_id", "")) == local_player_id:
			return "FINAL RANK #%d" % int(entry.get("rank", 0))
	return "MATCH RESULTS"
