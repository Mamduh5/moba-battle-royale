class_name DeathResolver
extends RefCounted

func resolve_death(source_entity_id: int, target_entity_id: int, state: SimulationState) -> void:
	if not state.has_entity(target_entity_id):
		return
	var target := state.get_entity(target_entity_id)
	if not bool(target.get("alive", true)):
		return
	var source := state.get_entity(source_entity_id)
	var source_player := str(source.get("owner_player_id", ""))
	var target_player := str(target.get("owner_player_id", ""))
	state.patch_entity(target_entity_id, {
		"alive": false,
		"status_tags": ["dead"],
		"health_current": 0,
		"velocity": Vector2.ZERO,
		"respawn_tick": state.server_tick + int(state.mode_def.respawn_sec * 30.0) if state.mode_def != null else state.server_tick + 90,
	})
	state.record_kill(source_player, target_player, state.mode_def.kill_score if state.mode_def != null else 1)
	state.push_event({
		"type": "entity_death",
		"source_entity_id": source_entity_id,
		"target_entity_id": target_entity_id,
		"source_player_id": source_player,
		"target_player_id": target_player,
	})
