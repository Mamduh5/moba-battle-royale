class_name VictoryResolver
extends RefCounted

func resolve(state: SimulationState) -> Dictionary:
	if state.finished:
		return {"finished": true, "reason": state.finish_reason, "winning_team_id": state.winning_team_id}
	var score_limit := int(state.rules.get("score_limit", 0))
	if bool(state.rules.get("teams_enabled", false)):
		var teams: Dictionary = state.scoreboard.get("teams", {})
		for team_key in teams.keys():
			var score := int(teams[team_key].get("score", 0))
			if score_limit > 0 and score >= score_limit:
				return {"finished": true, "reason": "score_limit", "winning_team_id": int(team_key)}
	else:
		for rank in ScoreService.build_rankings(state):
			if score_limit > 0 and int(rank.get("score", 0)) >= score_limit:
				return {"finished": true, "reason": "score_limit", "winner_player_id": str(rank.get("player_id", ""))}
	if int(state.scoreboard.get("ticks_remaining", 1)) <= 0:
		if bool(state.rules.get("teams_enabled", false)):
			return {"finished": true, "reason": "timer", "winning_team_id": _best_team(state)}
		var rankings := ScoreService.build_rankings(state)
		return {"finished": true, "reason": "timer", "winner_player_id": str(rankings[0].get("player_id", "")) if not rankings.is_empty() else ""}
	return {"finished": false}

func _best_team(state: SimulationState) -> int:
	var teams: Dictionary = state.scoreboard.get("teams", {})
	var best_team := 0
	var best_score := -9999
	for team_key in teams.keys():
		var score := int(teams[team_key].get("score", 0))
		if score > best_score:
			best_score = score
			best_team = int(team_key)
	return best_team
