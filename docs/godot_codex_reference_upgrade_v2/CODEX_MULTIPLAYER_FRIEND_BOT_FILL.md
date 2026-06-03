# Codex Multiplayer Friend and Bot-Fill Contract

The complete game must support playing with a friend when networking is available, while filling missing team slots with bots.

## Required multiplayer shape

The game mode remains 3v3 team arena.

Human player counts may be:

```text
1 human + 5 bots
2 humans + 4 bots
3 humans + 3 bots
4 humans + 2 bots
5 humans + 1 bot
6 humans + 0 bots
```

The game must not require six human players to start a match.

## Friend play requirement

At minimum, the architecture must support:

1. host or local match server starts,
2. first player joins,
3. second player can join by local network address, invite code, room code, or dev join token,
4. both human players are assigned to valid teams,
5. empty slots are filled by bots,
6. match starts,
7. humans and bots submit the same input-frame shape,
8. server simulation owns truth for all players and bots,
9. match ends normally and all connected players receive the result.

## Local-first requirement

For the one-prompt challenge, internet matchmaking is not required.

Acceptable complete-game multiplayer targets:

- LAN join by IP/port,
- local host plus second client on the same machine if supported,
- room code backed by local development adapter,
- Nakama-backed assignment if local Nakama is available.

The required path is not ranked matchmaking. It is friend-capable multiplayer with bot fill.

## Bot-fill rules

Bots fill every empty slot before match start.

Bot fill must be deterministic and server-owned:

- server chooses empty slots,
- server assigns bot IDs,
- server assigns bot heroes,
- server creates bot input frames,
- bots use the same `InputFrame` route as humans,
- bots do not directly mutate combat state.

## Team assignment rules

Default assignment should keep teams as balanced as possible.

Examples:

```text
1 human: human on Team A, 2 bots Team A, 3 bots Team B
2 humans: prefer one human per team unless party/team setting says same team
2 humans same-party cooperative mode: both on Team A, 1 bot Team A, 3 bots Team B
```

The implementation may expose a simple setting:

```text
friend_team_mode = split | together
```

If no UI exists for this yet, default to `together` for invited friend play and use bots to balance the opposing team.

## Minimum UI requirement

The complete game must expose one clear way to start friend-capable play:

- Host Match,
- Join Match,
- Local IP/Port or Room Code field,
- Start With Bots or Auto Fill Bots.

If visual UI cannot be fully completed in the environment, an automated smoke command must verify the same flow with two simulated clients and bot fill.

## Required tests or smoke checks

Add at least one command path or documented test for:

```text
1 human + 5 bots
2 humans + 4 bots
```

The two-human test may use simulated clients if a second physical player is not available.

## What does not count

- A multiplayer protocol with no way for a friend to join.
- A 3v3 match that requires six humans.
- Bots that only work in offline mode.
- Friend play that bypasses server authority.
- Client-owned bot spawning.
