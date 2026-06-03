class_name AbilityRuntime
extends RefCounted

var _damage_resolver := DamageResolver.new()
var _projectiles := ProjectileRuntime.new()
var _area_effects := AreaEffectRuntime.new()

func can_cast(ctx: AbilityContext) -> Array[String]:
	var errors: Array[String] = []
	if ctx == null or ctx.state == null or ctx.content_db == null:
		return ["invalid_context"]
	if not ctx.state.has_entity(ctx.caster_entity_id):
		return ["missing_caster"]
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	if not bool(caster.get("alive", true)):
		errors.append("caster_dead")
	var ability := _get_ability(ctx)
	if ability == null:
		errors.append("missing_ability")
	elif not CooldownTracker.is_ready(caster, ability.slot):
		errors.append("cooldown")
	return errors

func cast(ctx: AbilityContext) -> Array[Dictionary]:
	var errors := can_cast(ctx)
	if not errors.is_empty():
		ctx.state.push_event({
			"type": "ability_denied",
			"source_entity_id": ctx.caster_entity_id,
			"ability_id": ctx.ability_id,
			"slot": ctx.slot,
			"reasons": errors,
		})
		return []
	var ability := _get_ability(ctx)
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	ctx.state.patch_entity(ctx.caster_entity_id, CooldownTracker.start(caster, ability.slot, ability.cooldown_sec))
	var aim: Vector2 = ctx.aim.normalized() if ctx.aim.length_squared() > 0.001 else caster.get("facing", Vector2.RIGHT)
	ctx.state.patch_entity(ctx.caster_entity_id, {"facing": aim})
	ctx.state.push_event({
		"type": "ability_cast",
		"source_entity_id": ctx.caster_entity_id,
		"ability_id": ability.id,
		"slot": ability.slot,
		"vfx_color": ability.vfx_color,
	})
	match ability.effect_type:
		"projectile":
			_cast_projectile(ctx, ability, aim)
		"instant_arc":
			_cast_instant_arc(ctx, ability, aim)
		"dash_strike":
			_cast_dash_strike(ctx, ability, aim)
		"shield_burst":
			_cast_shield_burst(ctx, ability)
		"area_damage":
			_cast_area_damage(ctx, ability, caster.get("position", Vector2.ZERO))
		"target_area":
			_cast_area_damage(ctx, ability, _resolve_target_position(ctx, ability))
		"blink":
			_cast_blink(ctx, ability, aim)
		_:
			_cast_instant_arc(ctx, ability, aim)
	return []

func tick_active_effects(state: SimulationState) -> Array[Dictionary]:
	if state.mode_def == null:
		return []
	var config := SimulationConfig.from_defs(state.mode_def, state.map_def, 30)
	_projectiles.tick(state, config)
	return []

func _get_ability(ctx: AbilityContext) -> AbilityDef:
	return ctx.content_db.get_ability(ctx.ability_id)

func _cast_projectile(ctx: AbilityContext, ability: AbilityDef, aim: Vector2) -> void:
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	var projectile_id := ctx.state.create_entity("projectile", str(caster.get("owner_player_id", "")))
	var start: Vector2 = caster.get("position", Vector2.ZERO) + aim * (float(caster.get("radius", 12.0)) + ability.radius + 4.0)
	ctx.state.patch_entity(projectile_id, {
		"kind": "projectile",
		"source_entity_id": ctx.caster_entity_id,
		"ability_id": ability.id,
		"team_id": int(caster.get("team_id", 0)),
		"position": start,
		"velocity": aim * ability.projectile_speed,
		"radius": ability.radius,
		"damage": int(ability.damage),
		"remaining_ticks": max(1, int(ability.lifetime_sec * 30.0)),
		"visual": {"primary_color": ability.vfx_color, "body_shape": "projectile"},
	})

func _cast_instant_arc(ctx: AbilityContext, ability: AbilityDef, aim: Vector2) -> void:
	var target_id := TargetingResolver.find_enemy_in_arc(ctx.state, ctx.caster_entity_id, aim, ability.range, ability.radius)
	if target_id == 0:
		return
	var request := DamageRequest.create(ctx.caster_entity_id, target_id, ability.id, int(ability.damage), ctx.state.server_tick)
	_damage_resolver.resolve_damage(request, ctx.state)

func _cast_dash_strike(ctx: AbilityContext, ability: AbilityDef, aim: Vector2) -> void:
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	var previous: Vector2 = caster.get("position", Vector2.ZERO)
	var desired := previous + aim * ability.dash_distance
	var solved := CollisionQuery.solve_position(previous, desired, float(caster.get("radius", 12.0)), ctx.state.map_def)
	ctx.state.patch_entity(ctx.caster_entity_id, {"position": solved, "velocity": (solved - previous) / max(0.05, ability.cooldown_sec)})
	ctx.state.push_event({
		"type": "dash",
		"source_entity_id": ctx.caster_entity_id,
		"ability_id": ability.id,
		"from": {"x": previous.x, "y": previous.y},
		"to": {"x": solved.x, "y": solved.y},
		"vfx_color": ability.vfx_color,
	})
	for target_id in TargetingResolver.find_enemies_in_radius(ctx.state, ctx.caster_entity_id, solved, ability.radius):
		var request := DamageRequest.create(ctx.caster_entity_id, target_id, ability.id, int(ability.damage), ctx.state.server_tick)
		_damage_resolver.resolve_damage(request, ctx.state)

func _cast_shield_burst(ctx: AbilityContext, ability: AbilityDef) -> void:
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	var shield := float(caster.get("shield", 0.0)) + ability.shield
	ctx.state.patch_entity(ctx.caster_entity_id, {"shield": shield})
	_cast_area_damage(ctx, ability, caster.get("position", Vector2.ZERO))

func _cast_area_damage(ctx: AbilityContext, ability: AbilityDef, center: Vector2) -> void:
	_area_effects.emit_area_event(ctx.state, ctx.caster_entity_id, ability, center)
	for target_id in TargetingResolver.find_enemies_in_radius(ctx.state, ctx.caster_entity_id, center, ability.radius):
		var request := DamageRequest.create(ctx.caster_entity_id, target_id, ability.id, int(ability.damage), ctx.state.server_tick)
		_damage_resolver.resolve_damage(request, ctx.state)

func _cast_blink(ctx: AbilityContext, ability: AbilityDef, aim: Vector2) -> void:
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	var previous: Vector2 = caster.get("position", Vector2.ZERO)
	var desired := previous + aim * ability.dash_distance
	var solved := CollisionQuery.solve_position(previous, desired, float(caster.get("radius", 12.0)), ctx.state.map_def)
	ctx.state.patch_entity(ctx.caster_entity_id, {"position": solved, "velocity": Vector2.ZERO})
	ctx.state.push_event({
		"type": "blink",
		"source_entity_id": ctx.caster_entity_id,
		"ability_id": ability.id,
		"from": {"x": previous.x, "y": previous.y},
		"to": {"x": solved.x, "y": solved.y},
		"vfx_color": ability.vfx_color,
	})

func _resolve_target_position(ctx: AbilityContext, ability: AbilityDef) -> Vector2:
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	var caster_pos: Vector2 = caster.get("position", Vector2.ZERO)
	var target := ctx.target_position
	if target == Vector2.ZERO:
		target = caster_pos + (ctx.aim.normalized() if ctx.aim.length_squared() > 0.001 else Vector2.RIGHT) * min(ability.range, 320.0)
	var offset := target - caster_pos
	if offset.length() > ability.range:
		target = caster_pos + offset.normalized() * ability.range
	return CollisionQuery.clamp_to_bounds(target, ability.radius, ctx.state.map_def)
