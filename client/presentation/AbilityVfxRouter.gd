class_name AbilityVfxRouter
extends RefCounted

func summarize_events(events: Array[Dictionary]) -> Dictionary:
	var out := {"casts": 0, "impacts": 0, "deaths": 0}
	for event in events:
		match str(event.get("type", "")):
			"ability_cast":
				out["casts"] = int(out["casts"]) + 1
			"damage_applied":
				out["impacts"] = int(out["impacts"]) + 1
			"entity_death":
				out["deaths"] = int(out["deaths"]) + 1
	return out
