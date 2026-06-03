class_name HealthBarPresenter
extends RefCounted

static func draw_bar(canvas: CanvasItem, origin: Vector2, width: float, current: int, max_value: int, shield: int, local: bool) -> void:
	var ratio := clampf(float(current) / float(max(max_value, 1)), 0.0, 1.0)
	var bg := Rect2(origin, Vector2(width, 5.0))
	canvas.draw_rect(bg, Color(0.04, 0.06, 0.07, 0.86), true)
	canvas.draw_rect(Rect2(origin, Vector2(width * ratio, 5.0)), Color(0.24, 0.92, 0.50, 0.95) if local else Color(0.95, 0.32, 0.28, 0.95), true)
	if shield > 0:
		canvas.draw_rect(Rect2(origin + Vector2(0, -3), Vector2(width * clampf(float(shield) / float(max(max_value, 1)), 0.0, 1.0), 2.0)), Color(0.35, 0.75, 1.0, 0.95), true)
