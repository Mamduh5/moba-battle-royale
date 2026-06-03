class_name DamageRequest
extends RefCounted

var source_entity_id := 0
var target_entity_id := 0
var ability_id := ""
var amount := 0
var damage_type := "ability"
var server_tick := 0

static func create(source_id: int, target_id: int, ability: String, value: int, tick: int) -> DamageRequest:
	var request := DamageRequest.new()
	request.source_entity_id = source_id
	request.target_entity_id = target_id
	request.ability_id = ability
	request.amount = value
	request.server_tick = tick
	return request
