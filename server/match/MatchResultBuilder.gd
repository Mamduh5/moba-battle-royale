class_name MatchResultBuilder
extends RefCounted

func build(state: SimulationState) -> Dictionary:
	var scoreboard := state.build_scoreboard()
	var result := {
		"match_id": state.match_id,
		"mode_id": state.mode_id,
		"map_id": state.map_id,
		"server_tick": state.server_tick,
		"reason": state.match_end_reason,
		"winning_team_id": state.winning_team_id,
		"team_results": scoreboard.get("teams", {}),
		"player_results": state.player_stats.duplicate(true),
		"rankings": scoreboard.get("rankings", []),
		"result_signature": "local-dev-%s-%d" % [state.match_id, state.server_tick],
	}
	return result
