class_name SimulationConfig
extends RefCounted

var tick_rate := 30
var snapshot_rate := 15
var max_tick_count := 10800

func seconds_to_ticks(seconds: float) -> int:
	return int(round(seconds * float(tick_rate)))
