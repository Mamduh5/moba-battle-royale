class_name AbilityContext
extends RefCounted

var state: SimulationState = null
var caster_entity_id := 0
var ability: AbilityDef = null
var target_entity_id := 0
var target_position := Vector2.ZERO
var aim := Vector2.RIGHT
var map_def: MapDef = null
var tick_rate := 30

static func make(p_state: SimulationState, p_caster_id: int, p_ability: AbilityDef, request: Dictionary, p_map: MapDef, p_tick_rate: int) -> AbilityContext:
	var ctx := AbilityContext.new()
	ctx.state = p_state
	ctx.caster_entity_id = p_caster_id
	ctx.ability = p_ability
	ctx.target_entity_id = int(request.get("target_entity_id", 0))
	var target_dict: Dictionary = request.get("target_position", {})
	ctx.target_position = Vector2(float(target_dict.get("x", 0.0)), float(target_dict.get("y", 0.0)))
	var aim_dict: Dictionary = request.get("aim", {})
	ctx.aim = Vector2(float(aim_dict.get("x", 1.0)), float(aim_dict.get("y", 0.0)))
	if ctx.aim.length() == 0.0:
		ctx.aim = Vector2.RIGHT
	ctx.aim = ctx.aim.normalized()
	ctx.map_def = p_map
	ctx.tick_rate = p_tick_rate
	return ctx
