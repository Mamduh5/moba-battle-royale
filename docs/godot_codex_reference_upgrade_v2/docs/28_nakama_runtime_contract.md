# 28 - Nakama Runtime Contract

Nakama owns backend services. Godot match server owns real-time combat simulation.

Do not move authoritative damage simulation into Nakama runtime unless the architecture is intentionally changed in a documented migration. Nakama may validate and sign match tokens, validate final results, write storage, and grant rewards.

## Runtime language

Use **Go runtime modules** for production backend logic unless the repository already standardizes on TypeScript.

Reason:

- Strong typing.
- Good performance.
- Clear deployment artifact.
- Suitable for result validation and server-side economy logic.

If TypeScript runtime is selected instead, create `docs/NAKAMA_RUNTIME_LANGUAGE_DECISION.md` and update all module paths.

## Required Nakama module layout

```text
backend/nakama/
  go.mod
  go.sum
  main.go
  modules/
    auth.go
    matchmaking.go
    match_tokens.go
    match_results.go
    progression.go
    inventory.go
    leaderboards.go
    parties.go
    admin_debug.go
  config/
    local.yml
    dev.yml
    staging.yml
    prod.yml
  migrations/
  tests/
```

## Required RPCs

### `rpc_get_player_profile`

Input:

```json
{}
```

Output:

```json
{
  "user_id": "uuid-user",
  "display_name": "Player",
  "level": 12,
  "owned_heroes": ["hero_guardian"],
  "currencies": { "soft": 1200, "premium": 0 }
}
```

### `rpc_start_matchmaking`

Input:

```json
{
  "queue": "arena_3v3_ranked",
  "region": "sea",
  "selected_hero_id": "hero_guardian",
  "party_id": ""
}
```

Output:

```json
{
  "ticket": "matchmaker-ticket-id"
}
```

Validation:

- User owns selected hero or hero is free rotation.
- Queue exists.
- Region is allowed.
- Party members satisfy queue limits.

### `rpc_cancel_matchmaking`

Input:

```json
{
  "ticket": "matchmaker-ticket-id"
}
```

Output:

```json
{
  "cancelled": true
}
```

### `rpc_issue_match_token`

Called by matchmaker acceptance flow or trusted match orchestration.

Input:

```json
{
  "match_id": "match_01HZX...",
  "user_id": "uuid-user",
  "player_id": "player_01",
  "team_id": 1,
  "selected_hero_id": "hero_guardian",
  "match_server_host": "127.0.0.1",
  "match_server_port": 24560
}
```

Output:

```json
{
  "match_id": "match_01HZX...",
  "player_id": "player_01",
  "team_id": 1,
  "match_token": "signed-token",
  "expires_at_ms": 1710000600000,
  "match_server_host": "127.0.0.1",
  "match_server_port": 24560
}
```

Token claims:

```json
{
  "iss": "nakama",
  "aud": "godot-match-server",
  "match_id": "match_01HZX...",
  "user_id": "uuid-user",
  "player_id": "player_01",
  "team_id": 1,
  "hero_id": "hero_guardian",
  "exp_ms": 1710000600000
}
```

The token must be signed with a secret available only to Nakama and trusted match servers.

### `rpc_submit_match_result`

Called by Godot match server, not by clients.

Input:

```json
{
  "match_id": "match_01HZX...",
  "server_id": "server-sea-001",
  "started_at_ms": 1710000000000,
  "finished_at_ms": 1710000900000,
  "mode_id": "mode_team_arena_3v3",
  "map_id": "map_sunken_arena",
  "winning_team_id": 1,
  "team_results": {},
  "player_results": {},
  "server_signature": "signature"
}
```

Output:

```json
{
  "accepted": true,
  "reward_grants": {
    "uuid-user": { "soft": 50, "xp": 120 }
  },
  "leaderboard_updates": ["arena_3v3_ranked"]
}
```

Validation:

- Caller is a trusted match server.
- Match ID is known and not already finalized.
- Players match the original roster.
- Duration is within expected bounds.
- Result signature is valid.
- Rewards are calculated server-side only.

## Required storage collections

```text
player_profile/{user_id}
player_inventory/{user_id}
player_loadout/{user_id}
player_progression/{user_id}
match_history/{match_id}
queue_config/{queue_id}
hero_rotation/{rotation_id}
server_registry/{server_id}
```

## Required leaderboard IDs

```text
arena_3v3_ranked_mmr
arena_3v3_ranked_wins
arena_3v3_ranked_kills
arena_3v3_ranked_damage
```

## Matchmaker properties

Required query/index properties:

```json
{
  "queue": "arena_3v3_ranked",
  "region": "sea",
  "party_size": 1,
  "mmr_bucket": 12,
  "selected_hero_role": "tank",
  "client_build": "0.1.0-dev"
}
```

## Server registry

Match servers register heartbeat records in Nakama storage or an external service.

```json
{
  "server_id": "server-sea-001",
  "region": "sea",
  "host": "127.0.0.1",
  "port": 24560,
  "capacity_matches": 20,
  "active_matches": 3,
  "build": "0.1.0-dev",
  "last_heartbeat_ms": 1710000000000
}
```

## Local development

Use Docker Compose for local Nakama, Postgres, and optional Prometheus/Grafana later.

Local secrets may be kept in `.env.local`, but never committed.

Required local flow:

```text
1. Start Nakama stack.
2. Start Godot match server headless.
3. Client logs in to Nakama.
4. Client requests matchmaking or local dev match.
5. Nakama issues match token.
6. Client connects to Godot match server.
7. Match server validates token and runs match.
8. Match server submits result to Nakama.
9. Nakama writes rewards/history/leaderboards.
```
