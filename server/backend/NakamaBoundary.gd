class_name NakamaBoundary
extends RefCounted

func get_player_profile(_session_token: String) -> Dictionary:
	return {}

func issue_match_token(_request: Dictionary) -> Dictionary:
	return {}

func submit_match_result(_result: Dictionary) -> Dictionary:
	return {"accepted": false, "reason": "not_implemented"}
