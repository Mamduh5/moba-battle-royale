class_name DamageResolver
extends RefCounted

var _death_resolver := DeathResolver.new()

func resolve_damage(request: DamageRequest, state: SimulationState) -> DamageResult:
	assert(request != null)
	assert(state != null)
	var result := DamageResult.new()
	if not can_damage(request.source_entity_id, request.target_entity_id, state):
		result.reason = "cannot_damage"
		return result
	var source := state.get_entity(request.source_entity_id)
	var target := state.get_entity(request.target_entity_id)
	if state.server_tick < int(target.get("invulnerable_until_tick", 0)):
		result.reason = "target_invulnerable"
		return result
	var amount: int = max(request.amount, 0)
	var armor := clampf(float(target.get("armor", 0.0)), 0.0, 0.85)
	amount = int(round(float(amount) * (1.0 - armor)))
	var shield := float(target.get("shield", 0.0))
	if shield > 0.0:
		var shield_absorb: float = min(shield, float(amount))
		shield -= shield_absorb
		amount -= int(shield_absorb)
	var health: int = max(int(target.get("health_current", 0)) - amount, 0)
	state.patch_entity(request.target_entity_id, {
		"health_current": health,
		"shield": max(shield, 0.0),
	})
	var source_player := str(source.get("owner_player_id", ""))
	state.record_damage(source_player, amount)
	result.accepted = true
	result.amount_applied = amount
	result.health_after = health
	state.push_event({
		"type": "damage_applied",
		"source_entity_id": request.source_entity_id,
		"target_entity_id": request.target_entity_id,
		"ability_id": request.ability_id,
		"amount": amount,
		"health_after": health,
	})
	if health <= 0:
		result.killed = true
		_death_resolver.resolve_death(request.source_entity_id, request.target_entity_id, state)
	return result

func can_damage(source_entity_id: int, target_entity_id: int, state: SimulationState) -> bool:
	if source_entity_id <= 0 or target_entity_id <= 0 or source_entity_id == target_entity_id:
		return false
	if not state.has_entity(source_entity_id) or not state.has_entity(target_entity_id):
		return false
	var source := state.get_entity(source_entity_id)
	var target := state.get_entity(target_entity_id)
	if not bool(source.get("alive", true)) or not bool(target.get("alive", true)):
		return false
	if state.mode_def != null and state.mode_def.team_based and not state.mode_def.friendly_fire:
		if int(source.get("team_id", 0)) == int(target.get("team_id", 0)):
			return false
	return true
