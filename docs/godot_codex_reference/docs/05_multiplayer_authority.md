# Multiplayer Authority

## Authority rule

The dedicated match server owns gameplay truth. The client owns input and presentation. Nakama owns account-backed persistent data. No system may bypass this division.

## Server tick

Target simulation rate: 30 Hz.

Each tick:

1. Gather queued player inputs.
2. Gather bot inputs.
3. Validate commands.
4. Advance movement.
5. Resolve abilities, projectiles, status effects, objectives, deaths, respawns.
6. Produce gameplay events.
7. Build snapshots for interested clients.
8. Persist rolling replay/event buffers.

## Client prediction

Clients may predict local movement for responsiveness. Prediction is limited to movement and non-authoritative cast windup visuals. Damage, hits, cooldown completion, CC state, rewards, and scoring are not predicted as final truth.

When the server sends correction:

- Rewind local predicted movement state to the acknowledged tick.
- Reapply pending local inputs.
- Smooth visual position if correction is small.
- Snap if correction exceeds threshold or entity is in forced movement.

## Input commands

Inputs are commands, not facts. A command says what the player attempted, not what happened.

Example:

```json
{
  "type": "input_frame",
  "player_id": "p_123",
  "seq": 1842,
  "client_tick": 8821,
  "move": {"x": 0.35, "y": -0.94},
  "aim": {"x": 0.80, "y": -0.60},
  "pressed": ["ability_1"],
  "held": ["basic_attack"],
  "released": []
}
```

The server computes final movement, cast result, hit result, and state change.

## Snapshots

Snapshots contain server-selected state:

- server tick
- acknowledged input sequence per player
- visible entity states
- health/resource values
- active status effects
- ability state summary
- objective state
- compact event list

Do not send full private state unless the client is authorized to know it.

## Interest management

Filter snapshots by visibility, distance, team permissions, spectator permissions, and mode rules. This matters for fog of war, hidden traps, invisible entities, jungle vision, and spectator tools.

## Reconnect

A disconnected player remains reserved for a reconnect window. During this window:

- The server keeps the player entity alive or applies mode-specific AFK behavior.
- A bot may temporarily control the entity if the mode allows.
- Reconnected clients receive a full state snapshot and resume from server state.
- Duplicate sessions are rejected or replace old sessions according to token policy.

## Disconnect and AFK

The server handles disconnects consistently:

- ranked: stricter penalties and reconnect priority
- casual: bot fill allowed
- custom: host-configured rules
- training: local pause allowed if single-player

## Match result

The match result is signed or submitted through a trusted server path. Clients can display results but cannot persist them.
