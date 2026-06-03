class_name ProjectileRuntime
extends RefCounted

var _damage_resolver := DamageResolver.new()

func tick(state: SimulationState, config: SimulationConfig) -> void:
	var to_remove: Array[int] = []
	for entity_id in state.query_entities({"kind": "projectile"}):
		var projectile := state.get_entity(entity_id)
		var remaining := int(projectile.get("remaining_ticks", 0)) - 1
		var position: Vector2 = projectile.get("position", Vector2.ZERO)
		var velocity: Vector2 = projectile.get("velocity", Vector2.ZERO)
		position += velocity * config.fixed_delta
		state.patch_entity(entity_id, {"position": position, "remaining_ticks": remaining})
		if remaining <= 0 or not CollisionQuery.is_position_safe(position, float(projectile.get("radius", 5.0)), config.map_def):
			to_remove.append(entity_id)
			continue
		var hit := TargetingResolver.find_enemies_in_radius(state, int(projectile.get("source_entity_id", 0)), position, float(projectile.get("radius", 5.0)))
		if not hit.is_empty():
			var request := DamageRequest.create(
				int(projectile.get("source_entity_id", 0)),
				hit[0],
				str(projectile.get("ability_id", "")),
				int(projectile.get("damage", 0)),
				state.server_tick
			)
			_damage_resolver.resolve_damage(request, state)
			to_remove.append(entity_id)
	for entity_id in to_remove:
		state.remove_entity(entity_id)
