class_name MovementMotor
extends RefCounted

static func apply_input(entity: Dictionary, input: InputFrame, speed: float, delta: float, map_def: MapDef) -> Dictionary:
	var patch: Dictionary = {}
	if not bool(entity.get("alive", true)):
		patch["velocity"] = Vector2.ZERO
		return patch
	var direction := Vector2(input.move_x, input.move_y)
	if direction.length() > 1.0:
		direction = direction.normalized()
	var velocity := direction * speed
	var previous: Vector2 = entity.get("position", Vector2.ZERO)
	var desired := previous + velocity * delta
	var radius := float(entity.get("radius", 12.0))
	var solved := CollisionQuery.solve_position(previous, desired, radius, map_def)
	patch["position"] = solved
	patch["velocity"] = (solved - previous) / max(delta, 0.0001)
	var aim := Vector2(input.aim_x, input.aim_y)
	if aim.length_squared() > 0.001:
		patch["facing"] = aim.normalized()
	elif direction.length_squared() > 0.001:
		patch["facing"] = direction.normalized()
	return patch
