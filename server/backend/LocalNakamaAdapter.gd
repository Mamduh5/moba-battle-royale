class_name LocalNakamaAdapter
extends NakamaBoundary

func get_player_profile(_session_token: String) -> Dictionary:
	return {
		"user_id": "local-dev-user",
		"display_name": "Arena Player",
		"level": 1,
		"owned_heroes": ["hero_guardian", "hero_raptor", "hero_oracle"],
		"currencies": {"soft": 0, "premium": 0},
	}

func issue_match_token(request: Dictionary) -> Dictionary:
	return {
		"match_id": str(request.get("match_id", GameConstants.DEFAULT_MATCH_ID)),
		"player_id": str(request.get("player_id", GameConstants.LOCAL_PLAYER_ID)),
		"team_id": int(request.get("team_id", 1)),
		"match_token": "local-dev-token-not-for-production",
		"expires_at_ms": 4102444800000,
		"match_server_host": "127.0.0.1",
		"match_server_port": 24560,
	}

func submit_match_result(result: Dictionary) -> Dictionary:
	return {
		"accepted": true,
		"mode_id": str(result.get("mode_id", "")),
		"reward_grants": {str(result.get("winner_player_id", "local-dev-user")): {"soft": 50, "xp": 120}},
		"leaderboard_updates": ["arena_3v3_ranked_kills"],
	}
