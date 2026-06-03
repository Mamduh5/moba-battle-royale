class_name MatchLifecycle
extends RefCounted

var state := GameConstants.MATCH_STATE_LOBBY

func mark_running() -> void:
	state = GameConstants.MATCH_STATE_RUNNING

func mark_finished() -> void:
	state = GameConstants.MATCH_STATE_FINISHED

func is_running() -> bool:
	return state == GameConstants.MATCH_STATE_RUNNING
