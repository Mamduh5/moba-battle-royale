class_name DamageRequest
extends RefCounted

var source_entity_id := 0
var target_entity_id := 0
var ability_id := ""
var amount := 0
var is_self_elimination := false

static func make(source_id: int, target_id: int, ability: String, damage: int) -> DamageRequest:
	var request := DamageRequest.new()
	request.source_entity_id = source_id
	request.target_entity_id = target_id
	request.ability_id = ability
	request.amount = damage
	return request
