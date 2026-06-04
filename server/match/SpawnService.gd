class_name SpawnService
extends RefCounted

func get_spawn_id(mode: ModeDef, index: int, team_id: int) -> String:
	if mode.teams_enabled:
		return "t%d_%d" % [team_id, index % max(1, mode.team_size)]
	return "ffa_%02d" % (index % max(1, mode.max_participants))
