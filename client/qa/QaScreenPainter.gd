class_name QaScreenPainter
extends Control

var screen_id := "main_menu"
var mode_id := "3v3_team_arena"

func _draw() -> void:
	match screen_id:
		"main_menu":
			_draw_menu()
		"mode_select":
			_draw_mode_select()
		"3v3_hud_mid_match":
			_draw_gameplay(false)
		"3v3_result":
			_draw_result(false)
		"deathmatch_hud_mid_match":
			_draw_gameplay(true)
		"deathmatch_result":
			_draw_result(true)

func _draw_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BG, true)
	draw_circle(size * 0.5 + Vector2(-260, -120), 118, Color("#30D1C8", 0.12))
	draw_circle(size * 0.5 + Vector2(290, 130), 150, Color("#FF4D8D", 0.10))
	_text("ARENA ROYALE", Vector2(size.x * 0.5 - 205, size.y * 0.28), 56, ArenaTheme.COLOR_GOLD)
	for i in range(5):
		var rect := Rect2(Vector2(size.x * 0.5 - 245, size.y * 0.42 + i * 62), Vector2(490, 48))
		draw_rect(rect, Color("#223149"), true)
		draw_rect(rect, ArenaTheme.COLOR_BLUE if i != 4 else ArenaTheme.COLOR_GOLD, false, 2.0)
	var labels := ["Quick 3v3 Battle", "Choose Mode", "Host Match With Bots", "LOCAL-ARENA", "Join Friend Match"]
	for i in range(labels.size()):
		_text(labels[i], Vector2(size.x * 0.5 - 130, size.y * 0.42 + i * 62 + 31), 18, ArenaTheme.COLOR_TEXT)

func _draw_mode_select() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BG_2, true)
	_text("SELECT BATTLE MODE", Vector2(size.x * 0.5 - 190, 82), 36, ArenaTheme.COLOR_GOLD)
	_draw_card(Rect2(Vector2(size.x * 0.5 - 470, 170), Vector2(430, 330)), "3v3 Team Arena", ArenaTheme.COLOR_BLUE, 6)
	_draw_card(Rect2(Vector2(size.x * 0.5 + 40, 170), Vector2(430, 330)), "25 Player Deathmatch", ArenaTheme.COLOR_RED, 25)

func _draw_card(rect: Rect2, title: String, color: Color, dots: int) -> void:
	draw_rect(rect, Color("#172235"), true)
	draw_rect(rect, color, false, 3.0)
	_text(title, rect.position + Vector2(24, 44), 26, color)
	for i in range(dots):
		var col := i % 8
		var row := i / 8
		draw_circle(rect.position + Vector2(42 + col * 48, 108 + row * 42), 13, color if i == 0 else ArenaTheme.COLOR_MUTED)
	draw_rect(Rect2(rect.position + Vector2(24, rect.size.y - 74), Vector2(rect.size.x - 48, 46)), Color("#223149"), true)
	draw_rect(Rect2(rect.position + Vector2(24, rect.size.y - 74), Vector2(rect.size.x - 48, 46)), color, false, 2.0)
	_text("Start", rect.position + Vector2(rect.size.x * 0.5 - 26, rect.size.y - 44), 18, ArenaTheme.COLOR_TEXT)

func _draw_gameplay(is_deathmatch: bool) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BG, true)
	var arena := Rect2(Vector2(size.x * 0.5 - 510, size.y * 0.5 - 280), Vector2(1020, 560))
	draw_rect(arena, Color("#182235"), true)
	draw_rect(arena, ArenaTheme.COLOR_BLUE, false, 4.0)
	for i in range(4):
		draw_rect(Rect2(arena.position + Vector2(120 + i * 215, 210 + (i % 2) * 80), Vector2(95, 58)), Color("#334C68"), true)
	var count := 25 if is_deathmatch else 6
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		var combat_center := arena.get_center() + (Vector2(0, 34) if is_deathmatch else Vector2.ZERO)
		var pos := combat_center + Vector2(cos(angle), sin(angle)) * Vector2(390, 178 if is_deathmatch else 205)
		var color := ArenaTheme.COLOR_GOLD if i == 0 else (ArenaTheme.COLOR_RED if is_deathmatch or i > 2 else ArenaTheme.COLOR_BLUE)
		_draw_qa_hero(pos, 23 if i == 0 else 15, color, i % 3)
		if i == 0:
			draw_arc(pos, 34, 0.0, TAU, 40, ArenaTheme.COLOR_GOLD, 4.0)
		draw_rect(Rect2(pos + Vector2(-18, -26), Vector2(36, 5)), ArenaTheme.COLOR_GREEN, true)
	_draw_hud(is_deathmatch)

func _draw_hud(is_deathmatch: bool) -> void:
	var score := Rect2(Vector2(size.x * 0.5 - 165, 16), Vector2(330, 132))
	draw_rect(score, Color("#101826", 0.84), true)
	draw_rect(score, ArenaTheme.COLOR_BLUE, false, 2.0)
	_text("02:18", Vector2(score.get_center().x - 35, 52), 24, ArenaTheme.COLOR_GOLD)
	if is_deathmatch:
		_text("TOP RANKS", score.position + Vector2(18, 30), 18, ArenaTheme.COLOR_GOLD)
		for i in range(5):
			_text("#%d Player %02d  %d/%d" % [i + 1, i + 1, 8 - i, i], score.position + Vector2(18, 56 + i * 20), 15, ArenaTheme.COLOR_TEXT if i == 0 else ArenaTheme.COLOR_MUTED)
	else:
		_text("BLUE 08", score.position + Vector2(18, 42), 24, ArenaTheme.COLOR_BLUE)
		_text("RED 06", score.position + Vector2(218, 42), 24, ArenaTheme.COLOR_RED)
	draw_rect(Rect2(Vector2(24, size.y - 92), Vector2(300, 28)), ArenaTheme.COLOR_GREEN, true)
	for i in range(3):
		var rect := Rect2(Vector2(size.x * 0.5 - 123 + i * 82, size.y - 96), Vector2(74, 74))
		draw_rect(rect, Color("#142034"), true)
		draw_rect(rect, [ArenaTheme.COLOR_GOLD, ArenaTheme.COLOR_BLUE, ArenaTheme.COLOR_RED][i], false, 2.0)

func _draw_qa_hero(pos: Vector2, radius: float, color: Color, shape_index: int) -> void:
	match shape_index:
		0:
			var points := PackedVector2Array([pos + Vector2(0, -radius * 1.2), pos + Vector2(radius, -radius * 0.25), pos + Vector2(radius * 0.55, radius), pos, pos + Vector2(-radius * 0.55, radius), pos + Vector2(-radius, -radius * 0.25)])
			draw_colored_polygon(points, color)
			var closed := points.duplicate()
			closed.append(points[0])
			draw_polyline(closed, Color("#101826"), 2.5)
			draw_line(pos, pos + Vector2(radius, 0), ArenaTheme.COLOR_GOLD, 3.0)
		1:
			var blade := PackedVector2Array([pos + Vector2(radius * 1.35, 0), pos + Vector2(-radius, radius * 0.72), pos + Vector2(-radius, -radius * 0.72)])
			draw_colored_polygon(blade, color)
			draw_line(pos + Vector2(-radius * 0.8, radius), pos + Vector2(radius * 0.8, -radius), ArenaTheme.COLOR_GREEN, 3.0)
		_:
			draw_circle(pos, radius, color)
			draw_circle(pos + Vector2(radius * 0.45, -radius * 0.25), radius * 0.42, ArenaTheme.COLOR_BLUE)
			draw_line(pos + Vector2(-radius * 0.9, -radius), pos + Vector2(-radius * 0.9, radius), ArenaTheme.COLOR_GOLD, 3.0)

func _draw_result(is_deathmatch: bool) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BG, true)
	var panel := Rect2(Vector2(size.x * 0.5 - 380, size.y * 0.5 - 280), Vector2(760, 560))
	draw_rect(panel, Color("#172235"), true)
	draw_rect(panel, ArenaTheme.COLOR_GOLD, false, 3.0)
	_text("FINAL RANK #1" if is_deathmatch else "VICTORY", panel.position + Vector2(230, 70), 38, ArenaTheme.COLOR_GOLD)
	for i in range(8):
		_text("#%d  Player %02d    score %02d    K/D %d/%d" % [i + 1, i + 1, 14 - i, 6 - min(i, 5), i], panel.position + Vector2(90, 132 + i * 42), 20, ArenaTheme.COLOR_TEXT if i == 0 else ArenaTheme.COLOR_MUTED)
	draw_rect(Rect2(panel.position + Vector2(170, panel.size.y - 78), Vector2(150, 46)), Color("#223149"), true)
	draw_rect(Rect2(panel.position + Vector2(390, panel.size.y - 78), Vector2(150, 46)), Color("#223149"), true)
	_text("Restart", panel.position + Vector2(205, panel.size.y - 48), 18, ArenaTheme.COLOR_TEXT)
	_text("Main Menu", panel.position + Vector2(414, panel.size.y - 48), 18, ArenaTheme.COLOR_TEXT)

func _text(text: String, pos: Vector2, font_size: int, color: Color) -> void:
	draw_string(get_theme_default_font(), pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
