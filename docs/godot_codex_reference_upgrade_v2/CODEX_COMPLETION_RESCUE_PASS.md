# Codex Completion Rescue Pass

Use this file after a previous one-prompt run produced a mostly working project but left strict challenge failures.

This pass must not rebuild the project from scratch. It must inspect the existing implementation, identify failed acceptance gates, fix them, rerun checks, and report honestly.

## Known failure classes from the first run

The previous result is incomplete if any of these remain true:

- rendered UI/readability QA was left for the user,
- visual smoke only logged milestones and did not inspect rendered output,
- friend play is only a simulated second session inside one local process,
- server transport exists only as a stub,
- live Nakama/Postgres stack was not started or health-checked,
- Docker Compose was only syntax-validated,
- backend RPCs compile but were not called against a running local service,
- final report says complete while listing required game-path work as next task.

## Rescue pass priority order

Fix in this order:

1. rendered UI QA and screenshot/artifact generation,
2. UI geometry audit for overlap/text clipping/control bounds,
3. real local/LAN friend transport path,
4. two-client friend smoke check with bot fill,
5. live Nakama/Postgres startup and health checks where Docker is available,
6. backend RPC calls against running local service,
7. final report correction and strict completion status.

## Rendered UI QA requirement

Do not ask the user to do a manual rendered UI pass.

Codex must create or run a real rendered QA path that produces evidence. Acceptable evidence:

- screenshots captured from the running Godot game,
- offscreen rendered viewport captures,
- automated UI geometry audit plus screenshots,
- interactive rendered inspection performed by Codex with notes.

Required artifact path:

```text
qa_artifacts/rendered_ui/
```

Required screens at 1280x720 and 1920x1080:

```text
main_menu
mode_select
3v3_hud_mid_match
3v3_result
deathmatch_hud_mid_match
deathmatch_result
```

If rendered output cannot be captured, the challenge remains incomplete. Do not call it complete.

## UI geometry audit requirement

Add or run a command such as:

```text
ui-audit --resolution 1280x720
ui-audit --resolution 1920x1080
```

The audit must check visible Control nodes for:

- controls outside viewport,
- zero-size or tiny buttons,
- text clipping where measurable,
- unintended overlapping buttons/labels/panels,
- HUD blocking core gameplay area,
- result screen value collisions,
- deathmatch scoreboard covering the local player.

Allowlist only intentional overlap. Do not globally ignore overlap.

## Real friend networking requirement

A simulated second human in the same process is useful for tests but does not satisfy friend-capable multiplayer by itself.

The game needs one real friend-capable path:

- Host Match starts a listener or local match server endpoint,
- Join Match connects to that endpoint using IP/port, room code, or dev token,
- input travels through a transport boundary rather than direct in-process calls,
- snapshots/results travel back through the same transport boundary,
- missing slots are filled by bots server-side,
- a two-client smoke check proves the path.

Acceptable transports for the rescue pass:

- Godot ENetMultiplayerPeer,
- Godot WebSocketMultiplayerPeer,
- StreamPeerTCP wrapper,
- another concrete Godot-supported local transport.

A `ServerTransport` class whose methods are empty does not count.

## Friend smoke test requirement

Add or run a command such as:

```text
friend-smoke --mode 3v3_team_arena --humans 2
friend-smoke --mode 25_player_deathmatch --humans 2
```

The smoke test must prove:

- host/server starts,
- two client sessions connect through the transport path or a faithful in-process transport test double,
- both receive player IDs,
- bot fill reaches mode max participants,
- both clients submit input frames,
- snapshots are received,
- match reaches result state or a shortened deterministic result condition.

If a faithful transport test double is used, still implement the real transport class and document how to launch it.

## Live backend requirement

If Docker is available, Codex must start the local backend stack, not only validate Compose syntax.

Required attempts:

```text
docker compose -f infra/nakama/docker-compose.yml up -d
docker compose -f infra/nakama/docker-compose.yml ps
```

Then run a health/RPC check against local Nakama where possible.

If Docker is unavailable or fails to start, Codex must:

- report the exact Docker blocker,
- keep the local development adapter,
- avoid claiming live backend validation passed.

## Backend RPC validation requirement

When Nakama is running, call or test the local RPCs for:

- player profile,
- start matchmaking or match assignment,
- issue match token,
- submit match result.

Do not count Go compile alone as live backend validation.

## Final report rule

The final report must classify each strict gate as:

```text
passed
failed
blocked by external environment
not attempted
```

If any required gate is failed or not attempted, the game completion status must be:

```text
Incomplete for strict challenge rules
```

Do not write "complete" while also listing a required gate as future/manual work.
