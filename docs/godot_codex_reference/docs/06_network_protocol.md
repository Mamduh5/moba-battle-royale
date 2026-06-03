# Network Protocol

## Protocol goals

The protocol must be compact, debuggable, versioned, and resilient to bad clients. Use typed message schemas. Keep message handling centralized.

## Message categories

Client to server:

- `hello`
- `auth_match_token`
- `load_complete`
- `input_frame`
- `ability_cast_request`
- `ping`
- `emote_request`
- `surrender_vote`
- `reconnect_request`

Server to client:

- `hello_ack`
- `auth_result`
- `match_config`
- `full_snapshot`
- `delta_snapshot`
- `combat_event_batch`
- `input_ack`
- `correction`
- `server_notice`
- `match_result`
- `disconnect_reason`

## Version header

Every connection handshake includes:

- protocol version
- client build version
- content manifest hash
- platform
- player ID
- session ID
- match token

Reject incompatible versions early with a clear reason.

## Input reliability

Input frames should tolerate packet loss. Send recent input frames redundantly. Include sequence numbers. Server acknowledges latest processed sequence. The client keeps a ring buffer for prediction and reconciliation.

## Event reliability

Critical events must be reliable or replayable through snapshots:

- death
- respawn
- objective capture
- match phase transition
- score update
- item purchase/use
- ability cooldown reset if not derivable from snapshot

Visual-only events can be lossy.

## Rate limiting

Rate-limit client messages by type:

- input frames: high rate, compact, validated
- ability cast: tied to input sequence and cooldown rules
- emotes/pings: limited
- chat: backend moderation path
- reconnect: limited

Repeated invalid commands increase a suspicion score and can trigger server actions.

## Serialization

Start with JSON only for debug tooling and local iteration if necessary. Move active match traffic to a compact binary or PackedByteArray serializer once message shapes stabilize. Keep a debug decoder for logs.

## Error handling

Every rejection includes:

- reason code
- server tick
- correlation ID when tied to a client request
- optional user-facing feedback key

Never fail silently in network code.
