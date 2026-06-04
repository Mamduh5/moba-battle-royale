class_name DamageResult
extends RefCounted

var accepted := false
var killed := false
var amount_applied := 0
var shield_absorbed := 0
var errors: Array[String] = []

func to_dict() -> Dictionary:
	return {
		"accepted": accepted,
		"killed": killed,
		"amount_applied": amount_applied,
		"shield_absorbed": shield_absorbed,
		"errors": errors.duplicate(),
	}
