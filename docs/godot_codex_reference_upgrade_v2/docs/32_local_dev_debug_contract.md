# 32 - Local Development and Debug Contract

A multiplayer bug is not fixed until it can be observed, reproduced, and validated headlessly.

## Required local modes

### Offline simulation mode

Runs `SimulationWorld` without sockets.

Use for:

- damage tests
- ability tests
- bot tests
- objective tests
- soak tests

### Local server mode

Runs Godot headless match server with local transport.

Use for:

- handshake tests
- input/snapshot tests
- reconnect tests
- bot fill tests

### Full local stack mode

Runs Nakama + match server + client.

Use for:

- login
- matchmaking
- token issue
- match result submit
- progression write

## Required debug fields

Every structured log line from multiplayer code should include when available:

```json
{
  "category": "network",
  "event": "snapshot_sent",
  "match_id": "match_01",
  "player_id": "player_01",
  "entity_id": 1001,
  "server_tick": 1500,
  "client_tick": 1497,
  "sequence": 8001,
  "fields": {}
}
```

## Required trace files

When trace is enabled, write JSON Lines files:

```text
logs/traces/match_<match_id>_server.jsonl
logs/traces/match_<match_id>_client_<player_id>.jsonl
```

Trace event types:

```text
input_received
input_rejected
input_applied
ability_cast_accepted
ability_cast_rejected
damage_applied
snapshot_sent
snapshot_received
correction_sent
correction_applied
match_finished
result_submitted
```

## Debug commands

### Snapshot diff

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd snapshot-diff --a logs/a.json --b logs/b.json
```

### Replay trace

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd replay-trace --trace logs/traces/match_001_server.jsonl
```

These commands may be added after the first 30 tasks, but all trace formats should be designed now.

## Debug overlay

Client debug overlay should show:

```text
connection state
ping estimate
server tick
client tick
snapshot delay
last input sequence
last acknowledged input
corrections per minute
packet loss estimate if available
entity count
```

The overlay is client-only and must not change gameplay state.

## Bug report minimum

Every multiplayer bug report must include:

```text
build version
protocol version
match id
player id
server region
server tick range
client logs
server logs
trace file if available
steps to reproduce
expected result
actual result
```
