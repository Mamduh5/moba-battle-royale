class_name VictoryResolver
extends RefCounted

func evaluate(state: SimulationState) -> Array[Dictionary]:
	if state.match_status == GameConstants.MATCH_STATE_FINISHED or state.mode_def == null:
		return []
	if state.mode_def.team_based:
		for team_key in state.score_by_team.keys():
			if int(state.score_by_team[team_key]) >= state.mode_def.score_limit:
				state.finish_match("score_limit", int(team_key))
				return state.drain_events()
	else:
		for player_id in state.player_stats.keys():
			var stats: Dictionary = state.player_stats[player_id]
			if int(stats.get("score", 0)) >= state.mode_def.score_limit:
				state.finish_match("score_limit", GameConstants.TEAM_NONE)
				return state.drain_events()
	if state.remaining_ticks <= 0:
		if state.mode_def.team_based:
			state.finish_match("timer", _leading_team(state))
		else:
			state.finish_match("timer", GameConstants.TEAM_NONE)
		return state.drain_events()
	return []

func _leading_team(state: SimulationState) -> int:
	var team_a := int(state.score_by_team.get(str(GameConstants.TEAM_A), 0))
	var team_b := int(state.score_by_team.get(str(GameConstants.TEAM_B), 0))
	if team_a >= team_b:
		return GameConstants.TEAM_A
	return GameConstants.TEAM_B
