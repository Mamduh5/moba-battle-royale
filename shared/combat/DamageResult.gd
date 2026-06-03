class_name DamageResult
extends RefCounted

var accepted := false
var killed := false
var amount_applied := 0
var health_after := 0
var reason := ""

func to_dict() -> Dictionary:
	return {
		"accepted": accepted,
		"killed": killed,
		"amount_applied": amount_applied,
		"health_after": health_after,
		"reason": reason,
	}
