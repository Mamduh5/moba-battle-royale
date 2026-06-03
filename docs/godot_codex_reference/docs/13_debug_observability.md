# Debugging and Observability

## Logging

Use structured logs. Each log entry includes:

- timestamp
- environment
- build version
- match ID when available
- player ID when available
- entity ID when available
- server tick when available
- event type
- severity
- correlation ID
- payload

Avoid raw print spam in production systems. Use `Log.debug`, `Log.info`, `Log.warn`, `Log.error` wrappers.

## Client debug overlay

The client debug overlay shows:

- FPS
- client build
- protocol version
- content version
- ping/RTT
- packet loss estimate
- snapshot delay
- local input sequence
- last acknowledged input
- reconciliation count
- entity count
- ability rejection reason
- current match phase

Enable through debug flag only.

## Server debug dashboard

Server logs/reporting expose:

- match ID
- uptime
- current tick
- player count
- bot count
- entity count
- average tick time
- max tick time
- command queue length
- snapshot size
- invalid command count
- disconnect/reconnect count

## Replay capture

Replay capture records:

- match config
- content manifest hash
- initial roster
- input commands
- server events
- periodic state checksums
- match result

Use replay files to reproduce desyncs, bot issues, suspicious clients, and balance bugs.

## Debug commands

Supported local/admin debug commands:

- dump entity state
- dump player state
- dump cooldowns
- dump active effects
- force bot goal in custom match
- force match phase transition in custom match
- write replay snapshot
- toggle hitbox visualization on client

Debug commands must be unavailable in normal ranked/casual clients.

## Common failure playbooks

### Player rubber-banding

Inspect input ack, RTT, reconciliation count, movement validation failures, and client frame time.

### Ability feels delayed

Inspect cast request timestamp, server receive tick, validation time, snapshot/event delivery, and local feedback mapping.

### Damage mismatch

Inspect server DamageIntent, modifiers, shields, status effects, final damage event, and client display event.

### Bot stuck

Inspect bot current goal, path target, navigation output, collision state, and last invalidated plan reason.

### Match result missing

Inspect server result submission, backend response, retry policy, match ID, and server signature.
