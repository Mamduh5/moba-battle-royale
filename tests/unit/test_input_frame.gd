extends RefCounted

func run() -> Array[String]:
	var errors: Array[String] = []
	var frame := InputFrame.new()
	frame.player_id = "unit"
	frame.move_x = 5.0
	var normalized := frame.normalized()
	if normalized.move_x > 1.0:
		errors.append("move_x was not clamped")
	return errors
