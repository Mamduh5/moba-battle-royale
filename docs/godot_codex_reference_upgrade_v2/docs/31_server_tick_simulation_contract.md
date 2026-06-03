# 31 - Server Tick Simulation Contract

The match server is authoritative. The client may predict for responsiveness, but server snapshots are truth.

## Tick rate

Default authoritative tick rate:

```text
30 ticks per second
```

Default snapshot rate:

```text
15 snapshots per second
```

Do not tie simulation correctness to render frame rate.

## Simulation step order

Every server tick executes this order:

```text
1. Collect latest valid input per player.
2. Generate bot input frames.
3. Apply movement intents.
4. Resolve ability cast requests.
5. Advance projectiles and active area effects.
6. Resolve collisions/hits using server state.
7. Resolve damage/healing/shields/status effects.
8. Resolve deaths and respawns.
9. Resolve objectives and score.
10. Check victory conditions.
11. Emit events.
12. Build snapshot if snapshot interval reached.
```

Codex must not reorder these steps without documenting why and updating tests.

## Input buffering

The server stores a bounded input buffer per player.

Rules:

- Accept monotonic input sequences.
- Drop duplicates.
- Reject or clamp invalid move/aim values.
- Treat missing input as neutral movement and no cast.
- Disconnect or flag clients that exceed abuse thresholds.

## Entity IDs

Entity IDs are server-created integers or stable numeric handles. Clients must not create authoritative entity IDs.

## Randomness

Randomness must be seeded per match.

Use `DeterministicRng` wrapper for gameplay randomness. Do not call global random functions inside combat/ability resolution.

## Floating point rule

Godot floating point behavior is acceptable for MVP server authority because the server is truth. Do not promise lockstep deterministic networking.

Client prediction is an approximation. Server correction handles mismatch.

## Snapshot rule

Snapshots must include enough state to recover client presentation without trusting previous client state.

Minimum fields for hero entities:

```text
entity_id
kind
owner_player_id
team_id
hero_id
position
velocity
facing
health
status_tags
cooldowns
```

## Event rule

Events are for presentation and audit. State must still be recoverable from snapshots.

Examples:

```text
damage_applied
heal_applied
shield_changed
ability_cast_started
ability_cast_rejected
projectile_spawned
entity_death
entity_respawned
objective_captured
match_finished
```

## Anti-cheat rule

Server validates:

- movement speed
- ability cooldown
- ability range
- target existence
- line-of-sight when required
- team rules
- status restrictions
- match phase
- hero ownership via Nakama/loadout before match start

Server ignores:

- client-reported damage
- client-reported hit success
- client-reported kill credit
- client-reported cooldown completion
- client-reported rewards
