class_name HealthBarPresenter
extends RefCounted

static func draw_bar(canvas: CanvasItem, origin: Vector2, width: float, current: int, max_value: int, shield: int, local: bool) -> void:
	var ratio := clampf(float(current) / float(max(max_value, 1)), 0.0, 1.0)
	var height := 7.0 if local else 5.0
	var bg := Rect2(origin, Vector2(width, height))
	canvas.draw_rect(bg.grow(2.0), Color(0.0, 0.0, 0.0, 0.64), true)
	canvas.draw_rect(bg, Color(0.035, 0.050, 0.055, 0.92), true)
	canvas.draw_rect(Rect2(origin, Vector2(width * ratio, height)), Color(0.24, 0.92, 0.50, 0.95) if local else Color(0.95, 0.32, 0.28, 0.95), true)
	canvas.draw_rect(bg, Color(1.0, 1.0, 1.0, 0.22) if local else Color(1.0, 1.0, 1.0, 0.12), false, 1.0)
	if shield > 0:
		canvas.draw_rect(Rect2(origin + Vector2(0, -4), Vector2(width * clampf(float(shield) / float(max(max_value, 1)), 0.0, 1.0), 2.5)), Color(0.35, 0.75, 1.0, 0.95), true)
