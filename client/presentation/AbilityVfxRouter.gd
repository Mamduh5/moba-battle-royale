class_name AbilityVfxRouter
extends Node2D

var _effects: Array[Dictionary] = []

func apply_events(events: Array[Dictionary]) -> void:
	for event in events:
		var type := str(event.get("type", ""))
		if type == "ability_cast" or type == "area_effect" or type == "dash" or type == "blink":
			_effects.append(event.duplicate(true))
		elif type == "damage_applied":
			_effects.append(event.duplicate(true))
	queue_redraw()

func _process(delta: float) -> void:
	for effect in _effects:
		effect["ttl"] = float(effect.get("ttl", 0.35)) - delta
	_effects = _effects.filter(func(effect: Dictionary) -> bool:
		return float(effect.get("ttl", 0.0)) > 0.0
	)
	queue_redraw()

func _draw() -> void:
	for effect in _effects:
		var color := Color(str(effect.get("vfx_color", "#FFFFFF")))
		color.a = clampf(float(effect.get("ttl", 0.35)) / 0.35, 0.1, 0.8)
		var type := str(effect.get("type", ""))
		if type == "area_effect":
			var pos_data: Dictionary = effect.get("position", {})
			draw_circle(Vector2(float(pos_data.get("x", 0.0)), float(pos_data.get("y", 0.0))), float(effect.get("radius", 80.0)), Color(color.r, color.g, color.b, 0.14))
			draw_arc(Vector2(float(pos_data.get("x", 0.0)), float(pos_data.get("y", 0.0))), float(effect.get("radius", 80.0)), 0.0, TAU, 48, color, 4.0)
		elif type == "dash" or type == "blink":
			var from_data: Dictionary = effect.get("from", {})
			var to_data: Dictionary = effect.get("to", {})
			draw_line(Vector2(float(from_data.get("x", 0.0)), float(from_data.get("y", 0.0))), Vector2(float(to_data.get("x", 0.0)), float(to_data.get("y", 0.0))), color, 7.0)
