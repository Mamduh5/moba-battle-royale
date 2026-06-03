# 27 - Network Payload Contracts

The protocol is explicit. Do not invent new field names in feature code. Add new fields here first, then update schemas, examples, encoder, decoder, tests, and version notes.

## Transport assumption

Default transport for Godot client to Godot match server:

```text
WebSocket or ENet transport behind `ServerTransport` and `MatchClient` adapters.
```

Gameplay code must not depend directly on transport implementation.

## Envelope

Every network message uses this envelope:

```json
{
  "protocol_version": "arena-protocol-1",
  "message_type": "player_input",
  "match_id": "match_01HZX...",
  "player_id": "player_01",
  "sequence": 42,
  "client_tick": 120,
  "server_tick": 118,
  "sent_at_ms": 1710000000000,
  "payload": {}
}
```

Required validation:

- `protocol_version` must match server-supported version.
- `message_type` must be known.
- `sequence` must be monotonic per connection for client-to-server gameplay messages.
- `match_id` must match the authenticated session after join.
- `player_id` must match the authenticated session after join.
- `payload` must validate against message-specific shape.

## Message lifecycle

```text
client_hello
server_welcome
join_match
join_accepted / join_rejected
player_input repeated
input_ack repeated
world_snapshot repeated
combat_event_batch repeated when needed
correction when needed
match_finished
```

## Client to server messages

### `client_hello`

Purpose: first protocol handshake.

Payload:

```json
{
  "client_build": "0.1.0-dev",
  "platform": "android",
  "device_class": "mid",
  "preferred_snapshot_rate": 15,
  "compression": "none"
}
```

Server behavior:

- Reject unsupported protocol version.
- Reply with `server_welcome`.

### `join_match`

Purpose: authenticate player into a specific match server room.

Payload:

```json
{
  "nakama_user_id": "uuid-user",
  "session_id": "session_abc",
  "match_token": "signed-token-from-nakama-rpc",
  "selected_hero_id": "hero_guardian",
  "client_region": "sea"
}
```

Server behavior:

- Validate token signature and expiry.
- Validate selected hero is allowed by match config.
- Bind connection to player ID.
- Reply with `join_accepted` or `join_rejected`.

### `player_input`

Payload:

```json
{
  "input_sequence": 8001,
  "client_tick": 1440,
  "move": { "x": 0.75, "y": -0.20 },
  "aim": { "x": 0.90, "y": 0.44 },
  "buttons": {
    "basic_attack": true,
    "ability_1": false,
    "ability_2": false,
    "ultimate": false,
    "interact": false
  },
  "cast_requests": [
    {
      "slot": "basic_attack",
      "ability_id": "ability_guardian_basic",
      "target_entity_id": 0,
      "target_position": { "x": 12.5, "y": 8.0 },
      "aim": { "x": 0.90, "y": 0.44 }
    }
  ]
}
```

Server behavior:

- Clamp movement and aim.
- Reject impossible input rate.
- Queue latest valid input for next simulation ticks.
- Never accept client damage results.

## Server to client messages

### `server_welcome`

Payload:

```json
{
  "server_build": "0.1.0-dev",
  "authoritative_tick_rate": 30,
  "snapshot_rate": 15,
  "supported_compression": ["none"],
  "server_time_ms": 1710000000100
}
```

### `join_accepted`

Payload:

```json
{
  "match_id": "match_01HZX...",
  "player_id": "player_01",
  "team_id": 1,
  "hero_id": "hero_guardian",
  "spawn_entity_id": 1001,
  "server_tick": 0,
  "map_id": "map_sunken_arena",
  "mode_id": "mode_team_arena_3v3"
}
```

### `join_rejected`

Payload:

```json
{
  "reason_code": "invalid_token",
  "message": "Match token is invalid or expired.",
  "retryable": false
}
```

Allowed reason codes:

```text
invalid_protocol
invalid_token
match_full
hero_unavailable
match_started
server_error
```

### `input_ack`

Payload:

```json
{
  "player_id": "player_01",
  "last_processed_input": 8001,
  "server_tick": 1442
}
```

### `world_snapshot`

Payload:

```json
{
  "snapshot_id": 501,
  "server_tick": 1500,
  "last_processed_input_by_player": {
    "player_01": 8001,
    "player_02": 7960
  },
  "entities": [
    {
      "entity_id": 1001,
      "kind": "hero",
      "owner_player_id": "player_01",
      "team_id": 1,
      "hero_id": "hero_guardian",
      "position": { "x": 12.5, "y": 8.0 },
      "velocity": { "x": 2.0, "y": 0.0 },
      "facing": { "x": 1.0, "y": 0.0 },
      "health": { "current": 880, "max": 1000 },
      "status_tags": ["alive"],
      "cooldowns": {
        "basic_attack": 0.0,
        "ability_1": 3.2,
        "ability_2": 0.0,
        "ultimate": 18.0
      }
    }
  ],
  "scoreboard": {
    "team_1": { "kills": 3, "score": 40 },
    "team_2": { "kills": 2, "score": 25 }
  }
}
```

### `state_delta`

Optional after full snapshot support is stable. Do not implement before `world_snapshot` is correct.

Payload:

```json
{
  "base_snapshot_id": 501,
  "snapshot_id": 502,
  "server_tick": 1502,
  "upserts": [],
  "removes": [],
  "events": []
}
```

### `correction`

Payload:

```json
{
  "player_id": "player_01",
  "server_tick": 1500,
  "last_processed_input": 8001,
  "entity_id": 1001,
  "authoritative_state": {
    "position": { "x": 12.2, "y": 7.9 },
    "velocity": { "x": 1.0, "y": 0.0 },
    "health": { "current": 880, "max": 1000 }
  },
  "reason": "position_error"
}
```

### `combat_event_batch`

Payload:

```json
{
  "server_tick": 1510,
  "events": [
    {
      "event_id": "evt_1510_0001",
      "type": "damage_applied",
      "source_entity_id": 1001,
      "target_entity_id": 1002,
      "ability_id": "ability_guardian_basic",
      "amount": 55,
      "health_after": 725
    },
    {
      "event_id": "evt_1510_0002",
      "type": "entity_death",
      "source_entity_id": 1001,
      "target_entity_id": 1002,
      "assist_entity_ids": [1003]
    }
  ]
}
```

### `match_finished`

Payload:

```json
{
  "match_id": "match_01HZX...",
  "server_tick": 54000,
  "winning_team_id": 1,
  "reason": "score_limit",
  "team_results": {
    "1": { "score": 100, "kills": 12, "objective_captures": 4 },
    "2": { "score": 80, "kills": 9, "objective_captures": 2 }
  },
  "player_results": {
    "player_01": { "kills": 5, "deaths": 2, "assists": 3, "damage_dealt": 3200 }
  },
  "result_signature": "server-generated-signature"
}
```

## Versioning rule

Any breaking payload change increments:

```text
arena-protocol-1 -> arena-protocol-2
```

Non-breaking additions are allowed only when the decoder ignores unknown optional fields safely.
