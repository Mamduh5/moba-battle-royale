class_name ObjectiveActor
extends Node2D

var color := Color(1.0, 0.85, 0.2, 0.75)

func _draw() -> void:
	draw_arc(Vector2.ZERO, 26.0, 0.0, TAU, 32, color, 3.0)
	draw_line(Vector2(-18, 0), Vector2(18, 0), color, 2.0)
	draw_line(Vector2(0, -18), Vector2(0, 18), color, 2.0)
