class_name EntityRegistry
extends RefCounted

var _next_entity_id := 1000

func reset(seed_offset: int = 0) -> void:
	_next_entity_id = 1000 + max(0, seed_offset % 900)

func next_id() -> int:
	_next_entity_id += 1
	return _next_entity_id
