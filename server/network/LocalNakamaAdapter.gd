class_name LocalNakamaAdapter
extends RefCounted

var _issued_tokens: Dictionary = {}
var _submitted_results: Dictionary = {}

func get_player_profile(user_id: String) -> Dictionary:
	return {
		"user_id": user_id,
		"display_name": "Local Player",
		"level": 1,
		"owned_heroes": ["hero_guardian", "hero_shade", "hero_arcanist"],
		"currencies": {"soft": 0, "premium": 0},
	}

func issue_match_token(match_id: String, user_id: String, player_id: String, team_id: int, hero_id: String, host: String, port: int) -> Dictionary:
	var token := "local-token-%s-%s-%d" % [match_id, player_id, Time.get_ticks_msec()]
	var result := {
		"match_id": match_id,
		"user_id": user_id,
		"player_id": player_id,
		"team_id": team_id,
		"selected_hero_id": hero_id,
		"match_token": token,
		"expires_at_ms": int(Time.get_unix_time_from_system() * 1000.0) + 3600000,
		"match_server_host": host,
		"match_server_port": port,
	}
	_issued_tokens[token] = result
	return result

func validate_match_token(token: String) -> Dictionary:
	return _issued_tokens.get(token, {})

func submit_match_result(result: Dictionary) -> Dictionary:
	var match_id := str(result.get("match_id", ""))
	if _submitted_results.has(match_id):
		return {"accepted": false, "reason": "duplicate_result"}
	_submitted_results[match_id] = result.duplicate(true)
	return {
		"accepted": true,
		"reward_grants": {},
		"leaderboard_updates": ["local_%s" % str(result.get("mode_id", ""))],
	}
