class_name DeterministicRng
extends RefCounted

var _state := 1

func seed(value: int) -> void:
	_state = max(value, 1)

func next_int() -> int:
	_state = int((_state * 1103515245 + 12345) & 0x7fffffff)
	return _state

func randf() -> float:
	return float(next_int()) / float(0x7fffffff)

func randf_range(min_value: float, max_value: float) -> float:
	return lerpf(min_value, max_value, randf())

func randi_range(min_value: int, max_value: int) -> int:
	if max_value <= min_value:
		return min_value
	return min_value + int(next_int() % (max_value - min_value + 1))

func choose(values: Array) -> Variant:
	if values.is_empty():
		return null
	return values[randi_range(0, values.size() - 1)]
