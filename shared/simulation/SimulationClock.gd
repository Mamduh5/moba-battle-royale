class_name SimulationClock
extends RefCounted

var tick_rate := 30
var tick := 0
var accumulator := 0.0

func configure(rate: int) -> void:
	tick_rate = max(rate, 1)
	tick = 0
	accumulator = 0.0

func advance(delta: float) -> int:
	accumulator += max(delta, 0.0)
	var steps := 0
	var fixed_delta := 1.0 / float(tick_rate)
	while accumulator >= fixed_delta:
		accumulator -= fixed_delta
		tick += 1
		steps += 1
	return steps
