class_name ScoreService
extends RefCounted

static func build_rankings(state: SimulationState) -> Array[Dictionary]:
	var rankings: Array[Dictionary] = []
	for entity in state.all_entities():
		if str(entity.get("kind", "")) != "hero":
			continue
		rankings.append({
			"player_id": str(entity.get("owner_player_id", "")),
			"entity_id": int(entity.get("entity_id", 0)),
			"display_name": str(entity.get("display_name", "")),
			"hero_id": str(entity.get("hero_id", "")),
			"team_id": int(entity.get("team_id", 0)),
			"is_bot": bool(entity.get("is_bot", false)),
			"score": int(entity.get("score", 0)),
			"kills": int(entity.get("kills", 0)),
			"deaths": int(entity.get("deaths", 0)),
			"damage_dealt": int(entity.get("damage_dealt", 0)),
		})
	_sort_rankings_in_place(rankings)
	var rank := 1
	for entry in rankings:
		entry["rank"] = rank
		rank += 1
	return rankings

static func _sort_rankings_in_place(rankings: Array[Dictionary]) -> void:
	for i in range(rankings.size()):
		var best := i
		for j in range(i + 1, rankings.size()):
			if _comes_before(rankings[j], rankings[best]):
				best = j
		if best != i:
			var temp := rankings[i]
			rankings[i] = rankings[best]
			rankings[best] = temp

static func _comes_before(a: Dictionary, b: Dictionary) -> bool:
	if int(a.get("score", 0)) != int(b.get("score", 0)):
		return int(a.get("score", 0)) > int(b.get("score", 0))
	if int(a.get("deaths", 0)) != int(b.get("deaths", 0)):
		return int(a.get("deaths", 0)) < int(b.get("deaths", 0))
	if int(a.get("damage_dealt", 0)) != int(b.get("damage_dealt", 0)):
		return int(a.get("damage_dealt", 0)) > int(b.get("damage_dealt", 0))
	return str(a.get("player_id", "")) < str(b.get("player_id", ""))
