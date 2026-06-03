class_name TeamService
extends RefCounted

static func assign_team_for_index(mode: ModeDef, human_index: int, friend_team_mode: String = "") -> int:
	if mode == null or not mode.team_based:
		return GameConstants.TEAM_NONE
	if friend_team_mode == "together":
		if human_index < mode.team_size:
			return GameConstants.TEAM_A
		return GameConstants.TEAM_B
	return GameConstants.TEAM_A if human_index % 2 == 0 else GameConstants.TEAM_B

static func count_team(roster: Array[Dictionary], team_id: int) -> int:
	var count := 0
	for entry in roster:
		if int(entry.get("team_id", 0)) == team_id:
			count += 1
	return count

static func next_balanced_team(mode: ModeDef, roster: Array[Dictionary]) -> int:
	if mode == null or not mode.team_based:
		return GameConstants.TEAM_NONE
	var team_a := count_team(roster, GameConstants.TEAM_A)
	var team_b := count_team(roster, GameConstants.TEAM_B)
	if team_a <= team_b and team_a < mode.team_size:
		return GameConstants.TEAM_A
	if team_b < mode.team_size:
		return GameConstants.TEAM_B
	return GameConstants.TEAM_A
