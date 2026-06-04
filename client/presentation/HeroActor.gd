class_name HeroActor
extends Node2D

var entity: Dictionary = {}

func set_entity(next_entity: Dictionary) -> void:
	entity = next_entity.duplicate(true)
	queue_redraw()

func _draw() -> void:
	var color := Color(str(entity.get("primary_color", "#30D1C8")))
	draw_circle(Vector2.ZERO, 22.0, color)
	draw_arc(Vector2.ZERO, 27.0, 0.0, TAU, 36, Color("#101826"), 3.0)
