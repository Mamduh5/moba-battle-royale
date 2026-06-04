class_name EntityId
extends RefCounted

static func invalid() -> int:
	return 0

static func is_valid(entity_id: int) -> bool:
	return entity_id > 0
