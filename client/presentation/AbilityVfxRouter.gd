class_name AbilityVfxRouter
extends Node2D

var _effects: Array[Dictionary] = []

func apply_events(events: Array[Dictionary]) -> void:
	for event in events:
		var type := str(event.get("type", ""))
		if type == "ability_cast" or type == "area_effect" or type == "dash" or type == "blink":
			var cast_event := event.duplicate(true)
			cast_event["ttl"] = 0.46 if type == "ability_cast" else 0.58
			_effects.append(cast_event)
		elif type == "damage_applied":
			var hit_event := event.duplicate(true)
			hit_event["ttl"] = 0.40
			_effects.append(hit_event)
		elif type == "entity_death":
			var death_event := event.duplicate(true)
			death_event["ttl"] = 0.82
			_effects.append(death_event)
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
		if str(effect.get("type", "")) == "damage_applied":
			color = Color(1.0, 0.34, 0.22)
		elif str(effect.get("type", "")) == "entity_death":
			color = Color(1.0, 0.76, 0.25)
		color.a = clampf(float(effect.get("ttl", 0.35)) / 0.58, 0.1, 0.9)
		var type := str(effect.get("type", ""))
		if type == "area_effect":
			var pos_data: Dictionary = effect.get("position", {})
			var pos := _dict_pos(pos_data)
			var radius := float(effect.get("radius", 80.0))
			draw_circle(pos, radius, Color(color.r, color.g, color.b, 0.14))
			draw_arc(pos, radius, 0.0, TAU, 56, color, 4.0)
			draw_arc(pos, radius * 0.62, 0.4, TAU - 0.2, 44, Color(1.0, 1.0, 1.0, color.a * 0.26), 2.0)
		elif type == "dash" or type == "blink":
			var from_data: Dictionary = effect.get("from", {})
			var to_data: Dictionary = effect.get("to", {})
			var from_pos := _dict_pos(from_data)
			var to_pos := _dict_pos(to_data)
			draw_line(from_pos, to_pos, Color(color.r, color.g, color.b, 0.20), 15.0)
			draw_line(from_pos, to_pos, color, 5.0)
			draw_circle(to_pos, 18.0, Color(color.r, color.g, color.b, 0.18))
			draw_arc(to_pos, 24.0, 0.0, TAU, 32, color, 3.0)
		elif type == "ability_cast":
			var source_data: Dictionary = effect.get("source_position", {})
			var source_pos := _dict_pos(source_data)
			draw_arc(source_pos, 31.0, 0.0, TAU, 30, color, 3.0)
			draw_arc(source_pos, 43.0, 0.5, TAU - 0.5, 30, Color(color.r, color.g, color.b, color.a * 0.35), 2.0)
		elif type == "damage_applied":
			var target_data: Dictionary = effect.get("target_position", {})
			var target_pos := _dict_pos(target_data)
			var t := clampf(float(effect.get("ttl", 0.35)) / 0.40, 0.0, 1.0)
			for i in range(6):
				var a := float(i) / 6.0 * TAU
				var end := target_pos + Vector2(cos(a), sin(a)) * (18.0 + (1.0 - t) * 18.0)
				draw_line(target_pos, end, Color(color.r, color.g, color.b, t), 3.0)
		elif type == "entity_death":
			var death_data: Dictionary = effect.get("target_position", {})
			var death_pos := _dict_pos(death_data)
			var fade := clampf(float(effect.get("ttl", 0.82)) / 0.82, 0.0, 1.0)
			var burst := PackedVector2Array([death_pos + Vector2(0, -42), death_pos + Vector2(42, 0), death_pos + Vector2(0, 42), death_pos + Vector2(-42, 0)])
			draw_colored_polygon(burst, Color(color.r, color.g, color.b, 0.10 * fade))
			var outline := PackedVector2Array(burst)
			outline.append(burst[0])
			draw_polyline(outline, Color(color.r, color.g, color.b, 0.75 * fade), 4.0)

func _dict_pos(data: Dictionary) -> Vector2:
	return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
