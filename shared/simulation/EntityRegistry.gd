class_name EntityRegistry
extends RefCounted

var _next_id := 1000
var _entities: Dictionary = {}

func reset(start_id: int = 1000) -> void:
	_next_id = start_id
	_entities.clear()

func create(initial: Dictionary = {}) -> int:
	_next_id += 1
	var entity_id := _next_id
	var entity := initial.duplicate(true)
	entity["entity_id"] = entity_id
	_entities[entity_id] = entity
	return entity_id

func remove(entity_id: int) -> void:
	_entities.erase(entity_id)

func has(entity_id: int) -> bool:
	return _entities.has(entity_id)

func get_entity(entity_id: int) -> Dictionary:
	return _entities.get(entity_id, {})

func patch(entity_id: int, patch_data: Dictionary) -> void:
	if not _entities.has(entity_id):
		return
	var entity: Dictionary = _entities[entity_id]
	for key in patch_data.keys():
		entity[key] = patch_data[key]
	_entities[entity_id] = entity

func all() -> Dictionary:
	return _entities
