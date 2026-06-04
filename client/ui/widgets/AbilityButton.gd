class_name AbilityButton
extends Control

var slot := ""
var label := ""
var icon := "bolt"
var accent := ArenaTheme.COLOR_BLUE
var cooldown_remaining := 0.0
var cooldown_max := 1.0

func _ready() -> void:
	custom_minimum_size = Vector2(74, 74)

func configure(slot_name: String, display_label: String, icon_name: String, color: Color) -> void:
	slot = slot_name
	label = display_label
	icon = icon_name
	accent = color
	queue_redraw()

func set_cooldown(remaining: float, maximum: float) -> void:
	cooldown_remaining = max(0.0, remaining)
	cooldown_max = max(0.01, maximum)
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect.grow(-2.0), Color("#142034"), true)
	draw_rect(rect.grow(-2.0), accent, false, 2.0)
	draw_circle(rect.get_center(), min(size.x, size.y) * 0.26, Color(accent.r, accent.g, accent.b, 0.22))
	_draw_icon(rect.get_center(), min(size.x, size.y) * 0.22)
	if cooldown_remaining > 0.0:
		var ratio := clampf(cooldown_remaining / cooldown_max, 0.0, 1.0)
		draw_rect(Rect2(Vector2(2, 2), Vector2(size.x - 4, (size.y - 4) * ratio)), Color(0, 0, 0, 0.55), true)
		_draw_text("%.1f" % cooldown_remaining, rect.get_center() + Vector2(-14, 8), 16, ArenaTheme.COLOR_TEXT)
	_draw_text(label, Vector2(8, size.y - 8), 13, ArenaTheme.COLOR_MUTED)

func _draw_icon(center: Vector2, radius: float) -> void:
	match icon:
		"shield":
			var points := PackedVector2Array([center + Vector2(0, -radius), center + Vector2(radius, -radius * 0.2), center + Vector2(radius * 0.5, radius), center + Vector2(0, radius * 1.25), center + Vector2(-radius * 0.5, radius), center + Vector2(-radius, -radius * 0.2)])
			draw_colored_polygon(points, accent)
		"dash", "arrow":
			draw_line(center + Vector2(-radius, radius * 0.5), center + Vector2(radius, -radius * 0.5), accent, 5.0)
			draw_line(center + Vector2(radius, -radius * 0.5), center + Vector2(radius * 0.2, -radius * 0.75), accent, 5.0)
			draw_line(center + Vector2(radius, -radius * 0.5), center + Vector2(radius * 0.55, radius * 0.25), accent, 5.0)
		"slash", "knife":
			draw_line(center + Vector2(-radius * 0.8, radius), center + Vector2(radius * 0.7, -radius), accent, 6.0)
			draw_circle(center + Vector2(radius * 0.8, -radius), radius * 0.18, accent)
		"star", "burst":
			for i in range(8):
				var angle := TAU * float(i) / 8.0
				draw_line(center, center + Vector2(cos(angle), sin(angle)) * radius, accent, 4.0)
		_:
			draw_circle(center, radius, accent)
			draw_circle(center, radius * 0.55, Color("#101826"))

func _draw_text(text: String, pos: Vector2, font_size: int, color: Color) -> void:
	draw_string(get_theme_default_font(), pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
