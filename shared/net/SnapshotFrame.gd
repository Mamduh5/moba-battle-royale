class_name SnapshotFrame
extends RefCounted

var match_id := ""
var server_tick := 0
var snapshot_id := 0
var last_processed_input_by_player: Dictionary = {}
var entities: Array[Dictionary] = []
var events: Array[Dictionary] = []
var scoreboard: Dictionary = {}

func to_dict() -> Dictionary:
	return {
		"match_id": match_id,
		"server_tick": server_tick,
		"snapshot_id": snapshot_id,
		"last_processed_input_by_player": last_processed_input_by_player.duplicate(true),
		"entities": entities.duplicate(true),
		"events": events.duplicate(true),
		"scoreboard": scoreboard.duplicate(true),
	}

static func from_dict(data: Dictionary) -> SnapshotFrame:
	var frame := SnapshotFrame.new()
	frame.match_id = str(data.get("match_id", ""))
	frame.server_tick = int(data.get("server_tick", 0))
	frame.snapshot_id = int(data.get("snapshot_id", 0))
	frame.last_processed_input_by_player = data.get("last_processed_input_by_player", {}).duplicate(true)
	frame.entities.clear()
	for entity in data.get("entities", []):
		if typeof(entity) == TYPE_DICTIONARY:
			frame.entities.append(entity.duplicate(true))
	frame.events.clear()
	for event in data.get("events", []):
		if typeof(event) == TYPE_DICTIONARY:
			frame.events.append(event.duplicate(true))
	frame.scoreboard = data.get("scoreboard", {}).duplicate(true)
	return frame

func get_entity(entity_id: int) -> Dictionary:
	for entity in entities:
		if int(entity.get("entity_id", 0)) == entity_id:
			return entity.duplicate(true)
	return {}
