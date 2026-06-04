class_name FloatingTextPresenter
extends RefCounted

func build_damage_labels(events: Array[Dictionary]) -> Array[Dictionary]:
	var labels: Array[Dictionary] = []
	for event in events:
		if str(event.get("type", "")) == "damage_applied":
			labels.append({"entity_id": int(event.get("target_entity_id", 0)), "text": str(event.get("amount", ""))})
	return labels
