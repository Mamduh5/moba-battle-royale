class_name DeathResolver
extends RefCounted

func mark_dead(target: Dictionary, source: Dictionary, request: DamageRequest, state: SimulationState) -> void:
	var target_id := int(target.get("entity_id", 0))
	var respawn_ticks := int(state.rules.get("respawn_ticks", 90))
	state.patch_entity(target_id, {
		"status_tags": [GameConstants.STATUS_DEAD],
		"respawn_ticks": respawn_ticks,
		"velocity": {"x": 0.0, "y": 0.0},
		"deaths": int(target.get("deaths", 0)) + 1,
	})
	var source_id := int(source.get("entity_id", 0))
	if source_id != 0 and source_id != target_id and state.has_entity(source_id):
		var source_patch := {
			"kills": int(source.get("kills", 0)) + 1,
			"score": int(source.get("score", 0)) + int(state.rules.get("kill_score", 1)),
		}
		state.patch_entity(source_id, source_patch)
		var source_team := int(source.get("team_id", 0))
		if bool(state.rules.get("teams_enabled", false)):
			var team_key := str(source_team)
			var teams: Dictionary = state.scoreboard.get("teams", {})
			var team_data: Dictionary = teams.get(team_key, {"score": 0, "kills": 0})
			team_data["score"] = int(team_data.get("score", 0)) + int(state.rules.get("kill_score", 1))
			team_data["kills"] = int(team_data.get("kills", 0)) + 1
			teams[team_key] = team_data
			state.scoreboard["teams"] = teams
	state.push_event({
		"type": "entity_death",
		"source_entity_id": source_id,
		"target_entity_id": target_id,
		"ability_id": request.ability_id,
	})
