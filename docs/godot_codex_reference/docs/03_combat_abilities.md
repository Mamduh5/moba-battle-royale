# Combat and Abilities

## Ability pipeline

Every ability request follows this pipeline:

1. Client sends `AbilityCastRequest` with player ID, input sequence, ability slot, aim vector or target ID, client tick, and optional cast position hint.
2. Server resolves the controlled entity.
3. Server validates alive state, silence/stun/root restrictions, resource cost, cooldown, charges, range, line of sight, target filtering, and mode restrictions.
4. Server starts cast state or rejects with a reason code.
5. Server applies cast time, windup, projectile spawn, area effect, instant hit, channel, summon, or movement behavior.
6. Server emits combat events and snapshots.
7. Client displays prediction feedback and then reconciles to authoritative events.

## Ability data

Each ability must declare:

- ID and display key.
- Slot: basic, skill_1, skill_2, ultimate, passive, item.
- Targeting type.
- Range, width, radius, speed, lifetime, cast time, backswing, channel duration.
- Resource cost.
- Cooldown and charges.
- Behavior module.
- Status effects applied.
- Damage/heal formulas.
- Interrupt rules.
- Client presentation keys.
- Server validation flags.

## Targeting types

Supported targeting types:

- self
- unit target
- point target
- direction skillshot
- cone
- line
- circle area
- ground zone
- vector dash
- lock-on projectile
- passive trigger

## Damage model

Damage uses a structured packet:

```text
DamageIntent
  source_entity_id
  target_entity_id
  ability_id
  base_amount
  damage_type
  scaling_tags
  can_crit
  can_lifesteal
  ignores_shield
  source_position
  hit_tick
```

Final damage is produced by `DamageResolver`. UI can display results, but never calculates authoritative outcomes.

## Projectiles

Projectiles are server simulation entities. A projectile owns position, velocity, lifetime, radius, hit mask, pierce count, bounce rules, owner ID, team ID, and behavior ID.

Clients may spawn immediate cosmetic projectile views for responsiveness, but the server projectile controls hits.

## Area effects

Area effects are server entities with shape, duration, tick interval, team filter, status effects, and objective interaction rules. They support culling for network snapshots.

## Cooldowns

Cooldown state is server-owned. The client displays the last known authoritative cooldown state plus local cosmetic anticipation. A server correction must always override the client display.

## Rejection reasons

Ability rejection codes must be explicit:

- not_alive
- stunned
- silenced
- rooted
- on_cooldown
- no_charges
- insufficient_resource
- out_of_range
- invalid_target
- blocked_line_of_sight
- invalid_state
- server_rate_limited

The client maps these codes to UI/audio feedback.
