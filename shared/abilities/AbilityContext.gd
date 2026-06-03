class_name AbilityContext
extends RefCounted

var caster_entity_id := 0
var slot := ""
var ability_id := ""
var target_entity_id := 0
var target_position := Vector2.ZERO
var aim := Vector2.RIGHT
var state: SimulationState = null
var content_db: Object = null
var config: SimulationConfig = null
