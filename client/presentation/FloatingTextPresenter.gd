class_name FloatingTextPresenter
extends Node2D

var _items: Array[Dictionary] = []

func add_text(text: String, position: Vector2, color: Color) -> void:
	_items.append({"text": text, "position": position, "color": color, "ttl": 0.8})
	queue_redraw()

func _process(delta: float) -> void:
	for item in _items:
		item["ttl"] = float(item.get("ttl", 0.0)) - delta
		item["position"] = item.get("position", Vector2.ZERO) + Vector2(0, -34.0 * delta)
	_items = _items.filter(func(item: Dictionary) -> bool:
		return float(item.get("ttl", 0.0)) > 0.0
	)
	queue_redraw()

func _draw() -> void:
	for item in _items:
		var alpha := clampf(float(item.get("ttl", 0.0)) / 0.8, 0.0, 1.0)
		var color: Color = item.get("color", Color.WHITE)
		color.a = alpha
		draw_string(ThemeDB.fallback_font, item.get("position", Vector2.ZERO), str(item.get("text", "")), HORIZONTAL_ALIGNMENT_CENTER, 80.0, 18, color)
