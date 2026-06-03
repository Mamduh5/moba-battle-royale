class_name ScoreService
extends RefCounted

func apply_kill_score(state: SimulationState, source_player_id: String, target_player_id: String) -> void:
	state.record_kill(source_player_id, target_player_id, state.mode_def.kill_score if state.mode_def != null else 1)
