class_name TeamService
extends RefCounted

static func are_hostile(source: Dictionary, target: Dictionary, rules: Dictionary) -> bool:
	if source.is_empty() or target.is_empty():
		return false
	if int(source.get("entity_id", 0)) == int(target.get("entity_id", 0)):
		return false
	if not bool(rules.get("teams_enabled", false)):
		return true
	if bool(rules.get("friendly_fire", false)):
		return true
	return int(source.get("team_id", 0)) != int(target.get("team_id", 0))

static func next_balanced_team(counts: Dictionary, team_count: int) -> int:
	var best_team := 1
	var best_count := 9999
	for team_id in range(1, team_count + 1):
		var count := int(counts.get(str(team_id), 0))
		if count < best_count:
			best_count = count
			best_team = team_id
	return best_team
