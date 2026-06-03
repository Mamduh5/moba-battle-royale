# 29 - Content Examples and Data Rules

Gameplay content is data-driven. Scripts implement mechanics; JSON defines values.

## Required content types

```text
content/heroes/*.json
content/abilities/*.json
content/modes/*.json
content/maps/*.json
content/bots/*.json
```

## ID rules

- IDs are lowercase snake case.
- IDs are stable after release.
- Do not reuse deleted IDs for different content.
- Cross references must validate.

Examples:

```text
hero_guardian
ability_guardian_basic
mode_team_arena_3v3
map_sunken_arena
bot_profile_normal
```

## Hero rule

Hero JSON defines identity, role, base stats, ability slots, presentation references, and server gameplay tags.

It does not define UI layout. It does not define client-only damage.

## Ability rule

Ability JSON defines cast shape, cooldown, range, targeting, projectile/effect, damage/heal/shield, status effects, and tags.

It does not define trusted client hit results.

## Map rule

Map JSON defines map ID, scene path, spawn groups, objective anchors, nav hints, and arena bounds.

It does not replace collision shapes in Godot scenes. It references them.

## Mode rule

Mode JSON defines team size, score limit, match duration, respawn rules, objective rules, bot fill rules, and ranked/casual settings.

## Bot profile rule

Bot JSON defines reaction time, aggression, aim error, objective preference, retreat thresholds, and ability usage weights.

Bots must output `InputFrame` objects, not direct state mutations.

## Validation requirements

`validate-content` must check:

- Required fields exist.
- IDs match file names where practical.
- Numeric values are finite.
- Cooldowns are non-negative.
- Health/speed/range values are within safe configured bounds.
- Ability IDs referenced by heroes exist.
- Map IDs referenced by modes exist.
- Bot hero references exist.
- Scene paths exist when the milestone includes scene assets.

## Example files in this upgrade

Copy these examples into the real project only if no equivalent content exists:

```text
content_examples/heroes/hero_guardian.json
content_examples/abilities/ability_guardian_basic.json
content_examples/abilities/ability_guardian_dash.json
content_examples/modes/mode_team_arena_3v3.json
content_examples/maps/map_sunken_arena.json
content_examples/bots/bot_profile_normal.json
```

## Balance rule

Balance changes must be isolated in content JSON unless a new mechanic is required.

If a task asks to change Guardian's basic attack damage, Codex must change:

```text
content/abilities/ability_guardian_basic.json
```

not `DamageResolver.gd`.
