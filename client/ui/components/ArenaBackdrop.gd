class_name ArenaBackdrop
extends Control

var variant := "menu"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, ArenaStyle.BG_DEEP, true)
	var upper := Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.58))
	draw_rect(upper, Color(0.040, 0.105, 0.120, 0.84), true)
	var band_color := Color(0.105, 0.265, 0.270, 0.26)
	for i in range(7):
		var y := size.y * (0.18 + float(i) * 0.105)
		draw_line(Vector2(0, y), Vector2(size.x, y - 145.0), band_color, 2.0)
	var circuit := ArenaStyle.LINE_SOFT
	for x in range(80, int(size.x), 190):
		draw_line(Vector2(x, size.y * 0.06), Vector2(x + 55, size.y * 0.06), circuit, 2.0)
		draw_line(Vector2(x + 55, size.y * 0.06), Vector2(x + 55, size.y * 0.18), circuit, 2.0)
	for i in range(5):
		var p := Vector2(size.x * (0.56 + i * 0.08), size.y * (0.20 + (i % 2) * 0.16))
		draw_arc(p, 46.0 + i * 10.0, 0.15, TAU - 0.45, 36, Color(0.950, 0.760, 0.250, 0.18), 2.0)
	if variant == "result":
		draw_rect(Rect2(Vector2(0, size.y * 0.78), Vector2(size.x, 3)), Color(1.0, 0.76, 0.25, 0.35), true)
	else:
		var wedge := PackedVector2Array([
			Vector2(size.x * 0.62, 0),
			Vector2(size.x, 0),
			Vector2(size.x, size.y),
			Vector2(size.x * 0.82, size.y),
		])
		draw_colored_polygon(wedge, Color(0.080, 0.180, 0.190, 0.42))
		var outline := PackedVector2Array(wedge)
		outline.append(wedge[0])
		draw_polyline(outline, Color(0.300, 0.930, 0.880, 0.20), 2.0)
