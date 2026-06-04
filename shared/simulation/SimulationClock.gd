class_name SimulationClock
extends RefCounted

var tick_rate := 30
var tick := 0

func reset() -> void:
	tick = 0

func step() -> int:
	tick += 1
	return tick
