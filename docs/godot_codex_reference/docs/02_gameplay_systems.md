# Gameplay Systems

## Core principles

Gameplay is data-driven, server-authoritative, testable in headless mode, and observable in replays. Each system has one owner and one event vocabulary.

## Entity model

Every match entity has:

- `entity_id`: stable server-assigned ID.
- `entity_type`: hero, projectile, minion, tower, objective, zone, pickup, summon.
- `team_id`: neutral, team_a, team_b, or mode-specific team.
- `owner_player_id`: optional player owner.
- `position`: authoritative world position.
- `facing`: authoritative aim/facing vector.
- `state_tags`: server-owned gameplay state tags.
- `components`: movement, health, combat, ability, objective, AI, visibility as applicable.

## Movement

Movement resolves on the server. Clients submit movement intent. The server clamps and validates movement based on move speed, crowd-control state, collision, map bounds, slow zones, dashes, knockbacks, and movement locks.

Movement abilities use explicit movement modes:

- normal locomotion
- dash
- blink
- knockback
- pull
- root
- airborne/unstoppable

Each mode declares whether input is accepted, collision is respected, and interrupts are allowed.

## Health and death

Health is server-owned. Damage events calculate final damage on the server using source stats, target stats, modifiers, shields, armor/resistance, invulnerability, team rules, and status tags.

Death emits a structured event with killer, victim, assists, damage timeline reference, location, and match objective impact. Respawn is mode-driven.

## Resources

Supported resource types:

- health
- mana/energy/ammo
- shield
- ultimate charge
- mode-specific score resources

Each resource declares server regeneration, max value, spend rules, and UI presentation mapping.

## Status effects

Status effects are server-owned timed modifiers. Each effect includes:

- effect ID
- source entity
- target entity
- stack policy
- duration
- tick interval
- gameplay tags added/removed
- stat modifiers
- cleanse/dispel rules
- visual/audio presentation key

Do not implement status effects as scattered timers inside hero scripts.

## Objectives

Modes compose objective systems:

- elimination scoring
- capture area control
- payload/escort movement
- crystal/base damage
- tower destruction
- minion wave pressure
- neutral boss buff
- resource turn-in

Objective systems emit match events and never directly write UI state.

## Rewards

The match server produces an authoritative match result packet. Nakama or backend runtime validates and persists progression, rewards, rating changes, missions, and inventory changes.

Never award persistent rewards from the client.
