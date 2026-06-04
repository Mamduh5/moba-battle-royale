class_name BackendCheckCommand
extends RefCounted

func run(_options: Dictionary = {}) -> int:
	var backend := LocalNakamaAdapter.new()
	var profile := backend.get_player_profile("local")
	var token := backend.issue_match_token({"match_id": "backend_check", "player_id": GameConstants.LOCAL_PLAYER_ID, "team_id": 1})
	var result := backend.submit_match_result({"mode_id": "3v3_team_arena", "winner_player_id": GameConstants.LOCAL_PLAYER_ID})
	var errors: Array[String] = []
	if profile.get("owned_heroes", []).size() < 3:
		errors.append("local backend profile missing required heroes")
	if str(token.get("match_token", "")) == "":
		errors.append("local backend did not issue token")
	if not bool(result.get("accepted", false)):
		errors.append("local backend result was not accepted")
	if not errors.is_empty():
		print(JSON.stringify({"cmd": "backend-check", "status": "fail", "errors": errors}))
		return 6
	print(JSON.stringify({"cmd": "backend-check", "status": "pass", "adapter": "LocalNakamaAdapter", "nakama_compatible_boundary": true}))
	return 0
