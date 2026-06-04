class_name DamageResolver
extends RefCounted

var _death_resolver := DeathResolver.new()

func resolve_damage(request: DamageRequest, state: SimulationState) -> DamageResult:
	var result: DamageResult = DamageResult.new()
	if request == null:
		result.errors.append("request is null")
		return result
	if request.amount <= 0:
		result.errors.append("damage amount must be positive")
		return result
	if not state.has_entity(request.source_entity_id) or not state.has_entity(request.target_entity_id):
		result.errors.append("source or target missing")
		return result
	var source: Dictionary = state.get_entity(request.source_entity_id)
	var target: Dictionary = state.get_entity(request.target_entity_id)
	if not can_damage(request.source_entity_id, request.target_entity_id, state):
		result.errors.append("target cannot be damaged")
		return result
	if int(target.get("invuln_ticks", 0)) > 0:
		result.errors.append("target is invulnerable")
		return result
	var was_alive := HealthComponent.is_alive(target)
	var shield: int = int(target.get("shield", 0))
	var incoming: int = request.amount
	if shield > 0:
		result.shield_absorbed = min(shield, incoming)
		shield -= result.shield_absorbed
		incoming -= result.shield_absorbed
	var health: Dictionary = target.get("health", {})
	var current: int = int(health.get("current", 0))
	var new_health: int = max(0, current - incoming)
	health["current"] = new_health
	result.accepted = true
	result.amount_applied = current - new_health
	state.patch_entity(request.target_entity_id, {"health": health, "shield": shield})
	if result.amount_applied > 0:
		state.patch_entity(request.source_entity_id, {"damage_dealt": int(source.get("damage_dealt", 0)) + result.amount_applied})
	state.push_event({
		"type": "damage_applied",
		"source_entity_id": request.source_entity_id,
		"target_entity_id": request.target_entity_id,
		"ability_id": request.ability_id,
		"amount": result.amount_applied,
		"health_after": new_health,
		"shield_absorbed": result.shield_absorbed,
	})
	if new_health <= 0 and was_alive:
		result.killed = true
		_death_resolver.mark_dead(target, source, request, state)
	return result

func can_damage(source_entity_id: int, target_entity_id: int, state: SimulationState) -> bool:
	if source_entity_id == target_entity_id:
		return false
	var source: Dictionary = state.get_entity(source_entity_id)
	var target: Dictionary = state.get_entity(target_entity_id)
	if source.is_empty() or target.is_empty():
		return false
	if not HealthComponent.is_alive(source) or not HealthComponent.is_alive(target):
		return false
	return TeamService.are_hostile(source, target, state.rules)
