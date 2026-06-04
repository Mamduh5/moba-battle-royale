class_name MatchResultBuilder
extends RefCounted

func build(room: MatchRoom) -> Dictionary:
	var snapshot := room.get_last_snapshot()
	var scoreboard: Dictionary = snapshot.scoreboard
	return {
		"match_id": room.match_id,
		"mode_id": str(scoreboard.get("mode_id", "")),
		"map_id": str(scoreboard.get("map_id", "")),
		"server_tick": snapshot.server_tick,
		"reason": str(scoreboard.get("finish_reason", "")),
		"winning_team_id": int(scoreboard.get("winning_team_id", 0)),
		"winner_player_id": str(scoreboard.get("winner_player_id", "")),
		"team_results": scoreboard.get("teams", {}).duplicate(true),
		"player_results": scoreboard.get("rankings", []).duplicate(true),
		"result_signature": "local-dev-signature",
	}
