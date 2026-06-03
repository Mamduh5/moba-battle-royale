# Codex 25-Player Deathmatch Mode Contract

The complete game must include a second game mode beyond 3v3 team arena.

## Required mode

```text
Mode name: 25 Player Deathmatch
Mode type: Free-for-all deathmatch
Teams: none
Max participants: 25
Minimum human players: 1
Bot fill: yes
Win condition: highest score at timer end or first player to score limit
```

This mode is required because the challenge target is a real small game with more than one playable mode, not only a minimal match demo.

## Player and bot fill rules

The match must support any human count from 1 to 25.

Examples:

```text
1 human + 24 bots
2 humans + 23 bots
5 humans + 20 bots
10 humans + 15 bots
24 humans + 1 bot
25 humans + 0 bots
```

The game must not require 25 human players to start deathmatch.

## No-team rules

Deathmatch has no teams.

Required behavior:

- every participant is hostile to every other participant,
- no friendly-fire filtering,
- no team score,
- no team spawn assignment,
- no shared team victory,
- scoreboard ranks individual participants.

## Scoring rules

Default scoring:

```text
kill = +1 score
self-elimination = 0 or -1, depending on mode data
death = tracked but not automatically negative
assist = optional
```

The mode must end by either:

```text
score_limit reached
```

or:

```text
match_timer expired
```

At match end, rank all participants by:

1. score descending,
2. deaths ascending,
3. damage dealt descending,
4. participant ID stable tie-breaker.

## Spawn rules

Deathmatch needs enough spawn points for 25 participants.

If the arena has fewer authored spawn points, the server must generate safe fallback spawn positions inside the map bounds. Spawns must avoid placing a participant directly inside walls or on top of another participant where possible.

Respawn should use a short delay and a temporary invulnerability window.

## Bot behavior rules

Deathmatch bots must use the same `InputFrame` pathway as human players.

Bots should:

- search for nearest viable enemy,
- avoid clustering too tightly,
- attack when in range,
- use abilities when useful,
- retreat or reposition at low health,
- respawn and re-enter combat after death.

Bots must not use team logic in deathmatch.

## UI requirements

The mode select UI must expose both:

```text
3v3 Team Arena
25 Player Deathmatch
```

The deathmatch HUD must show:

- player health,
- ability cooldowns,
- match timer,
- player rank,
- top 5 scoreboard entries,
- player score and deaths.

The result screen must show:

- winner,
- player rank,
- player score/deaths,
- top scoreboard results,
- restart or return-to-menu option.

## Multiplayer requirement

Deathmatch must support friend-capable multiplayer with bot fill.

Acceptable first complete paths:

- one local human plus 24 bots,
- two local/LAN humans plus 23 bots,
- simulated two-client smoke test plus 23 bots.

The server owns participant admission, bot fill, scoring, deaths, respawns, and final ranking.

## Validation and smoke tests

Add command coverage for:

```text
deathmatch-soak --participants 25 --matches 3
```

or include deathmatch cases inside the existing bot-soak command.

Minimum automated checks:

- 1 human + 24 bots configuration can start,
- 2 humans + 23 bots configuration can start or be simulated,
- match reaches result state,
- final ranking contains 25 participants,
- no team fields are required by deathmatch scoring.

## What does not count

- A deathmatch mode that still uses team scoring.
- A 25-player mode that requires 25 real humans.
- Bots that only work in 3v3.
- A scoreboard that only supports two teams.
- A mode entry in JSON with no playable match flow.
