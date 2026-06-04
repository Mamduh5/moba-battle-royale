class_name AbilityRuntime
extends RefCounted

var _damage_resolver := DamageResolver.new()
var _projectile_runtime := ProjectileRuntime.new()
var _area_runtime := AreaEffectRuntime.new()

func can_cast(ctx: AbilityContext) -> Array[String]:
	var errors: Array[String] = []
	if ctx == null or ctx.state == null or ctx.ability == null:
		errors.append("invalid ability context")
		return errors
	if not ctx.state.has_entity(ctx.caster_entity_id):
		errors.append("caster missing")
		return errors
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	if not HealthComponent.is_alive(caster):
		errors.append("dead entities cannot cast")
	if CooldownTracker.get_remaining(caster, ctx.ability.slot) > 0.0:
		errors.append("ability on cooldown")
	return errors

func cast(ctx: AbilityContext) -> Array[Dictionary]:
	var errors := can_cast(ctx)
	if not errors.is_empty():
		if ctx != null and ctx.state != null:
			ctx.state.push_event({"type": "cast_denied", "source_entity_id": ctx.caster_entity_id, "ability_id": ctx.ability.id if ctx.ability != null else "", "errors": errors})
		return []
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	var caster_pos := Vector2(float(caster.get("position", {}).get("x", 0.0)), float(caster.get("position", {}).get("y", 0.0)))
	var out: Array[Dictionary] = []
	match ctx.ability.cast_kind:
		"shield_dash":
			var dash_position: Vector2 = caster_pos + ctx.aim * min(ctx.ability.range, 160.0)
			dash_position = _clamp_and_avoid(dash_position, ctx.map_def)
			ctx.state.patch_entity(ctx.caster_entity_id, {
				"position": {"x": dash_position.x, "y": dash_position.y},
				"shield": int(caster.get("shield", 0)) + ctx.ability.shield,
				"shield_decay_ticks": ctx.tick_rate * 3,
			})
			_damage_nearest(ctx, ctx.ability.damage, out)
		"dash", "blink":
			var dash_position: Vector2 = caster_pos + ctx.aim * ctx.ability.range
			dash_position = _clamp_and_avoid(dash_position, ctx.map_def)
			ctx.state.patch_entity(ctx.caster_entity_id, {"position": {"x": dash_position.x, "y": dash_position.y}})
			if ctx.ability.damage > 0:
				_damage_nearest(ctx, ctx.ability.damage, out)
		"area":
			out.append_array(_area_runtime.damage_area(ctx, _damage_resolver))
		"execute":
			var target_id := TargetingResolver.find_target(ctx)
			if target_id != 0:
				var target := ctx.state.get_entity(target_id)
				var damage := ctx.ability.damage
				if HealthComponent.health_ratio(target) <= ctx.ability.execute_bonus_threshold:
					damage += int(round(float(ctx.ability.damage) * 0.45))
				var request := DamageRequest.make(ctx.caster_entity_id, target_id, ctx.ability.id, damage)
				out.append(_damage_resolver.resolve_damage(request, ctx.state).to_dict())
				_projectile_runtime.emit_projectile_event(ctx, target_id)
		_:
			_damage_nearest(ctx, ctx.ability.damage, out)
	CooldownTracker.set_cooldown(ctx.state, ctx.caster_entity_id, ctx.ability.slot, ctx.ability.cooldown_sec)
	ctx.state.push_event({
		"type": "ability_cast",
		"source_entity_id": ctx.caster_entity_id,
		"ability_id": ctx.ability.id,
		"slot": ctx.ability.slot,
		"color": ctx.ability.vfx_color,
	})
	return out

func tick_active_effects(_state: SimulationState) -> Array[Dictionary]:
	return []

func _damage_nearest(ctx: AbilityContext, damage: int, out: Array[Dictionary]) -> void:
	if damage <= 0:
		return
	var target_id := TargetingResolver.find_target(ctx)
	if target_id == 0:
		return
	var request := DamageRequest.make(ctx.caster_entity_id, target_id, ctx.ability.id, damage)
	out.append(_damage_resolver.resolve_damage(request, ctx.state).to_dict())
	_projectile_runtime.emit_projectile_event(ctx, target_id)

func _clamp_and_avoid(position: Vector2, map_def: MapDef) -> Vector2:
	var bounds := map_def.get_bounds_rect()
	var out := Vector2(clampf(position.x, bounds.position.x + 28.0, bounds.end.x - 28.0), clampf(position.y, bounds.position.y + 28.0, bounds.end.y - 28.0))
	if CollisionQuery.point_inside_obstacle(out, map_def, 22.0):
		return Vector2.ZERO
	return out
