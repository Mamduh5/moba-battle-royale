class_name AbilityIcon
extends Control

var slot := ""
var title := ""
var key_hint := ""
var accent := ArenaStyle.GOLD
var cooldown := 0.0
var cooldown_max := 1.0

func setup(slot_id: String, display_title: String, hint: String, color: Color, max_cooldown: float) -> void:
	slot = slot_id
	title = display_title
	key_hint = hint
	accent = color
	cooldown_max = max(max_cooldown, 0.1)
	queue_redraw()

func set_cooldown(seconds: float) -> void:
	cooldown = max(seconds, 0.0)
	queue_redraw()

func _ready() -> void:
	custom_minimum_size = Vector2(88, 72)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.030, 0.050, 0.058, 0.95), true)
	draw_rect(rect, Color(0.180, 0.360, 0.370, 0.80), false, 2.0)
	var inner := Rect2(Vector2(8, 8), Vector2(size.x - 16, size.y - 26))
	draw_rect(inner, Color(accent.r, accent.g, accent.b, 0.14), true)
	draw_rect(inner, Color(accent.r, accent.g, accent.b, 0.72), false, 1.5)
	_draw_symbol(inner)
	if cooldown > 0.05:
		var ratio := clampf(cooldown / cooldown_max, 0.0, 1.0)
		var cover := Rect2(Vector2(8, 8 + inner.size.y * (1.0 - ratio)), Vector2(inner.size.x, inner.size.y * ratio))
		draw_rect(cover, Color(0.0, 0.0, 0.0, 0.56), true)
		_draw_text("%.1f" % cooldown, Vector2(0, 38), 18, ArenaStyle.TEXT)
	else:
		_draw_text("READY", Vector2(0, 42), 10, Color(0.760, 1.000, 0.780))
	_draw_text(key_hint, Vector2(6, 16), 13, Color(0.940, 0.980, 0.950))
	_draw_text(title, Vector2(0, size.y - 9), 10, ArenaStyle.TEXT_MUTED)

func _draw_symbol(rect: Rect2) -> void:
	var center := rect.get_center()
	if slot == GameConstants.SLOT_BASIC:
		var bolt := PackedVector2Array([
			center + Vector2(-9, -16),
			center + Vector2(5, -4),
			center + Vector2(-1, -3),
			center + Vector2(10, 15),
			center + Vector2(-8, 1),
			center + Vector2(-1, 0),
		])
		draw_colored_polygon(bolt, accent)
	elif slot == GameConstants.SLOT_ABILITY_1:
		var arrow := PackedVector2Array([
			center + Vector2(-18, 4),
			center + Vector2(5, 4),
			center + Vector2(5, 13),
			center + Vector2(20, 0),
			center + Vector2(5, -13),
			center + Vector2(5, -4),
			center + Vector2(-18, -4),
		])
		draw_colored_polygon(arrow, accent)
	else:
		for i in range(8):
			var a := float(i) / 8.0 * TAU
			draw_line(center, center + Vector2(cos(a), sin(a)) * 18.0, accent, 3.0)
		draw_circle(center, 9.0, accent)

func _draw_text(text: String, pos: Vector2, font_size: int, color: Color) -> void:
	var font := get_theme_default_font()
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(font, Vector2((size.x - text_size.x) * 0.5 + pos.x, pos.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
