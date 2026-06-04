class_name DeterministicRng
extends RefCounted

var _state := 1

func seed(seed_value: int) -> void:
	_state = max(1, seed_value)

func next_float() -> float:
	_state = int((_state * 1103515245 + 12345) & 0x7fffffff)
	return float(_state) / 2147483647.0

func next_int(max_exclusive: int) -> int:
	if max_exclusive <= 0:
		return 0
	return int(floor(next_float() * float(max_exclusive))) % max_exclusive
