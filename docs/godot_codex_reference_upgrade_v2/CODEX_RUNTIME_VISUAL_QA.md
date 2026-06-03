# Codex Runtime and Visual QA Contract

The complete-game challenge is not satisfied by code that only compiles. Codex must run and inspect the game as a player-facing product.

This file covers issues that automated script checks may miss: UI overlap, text collisions, unreadable HUD, broken scaling, missing feedback, console errors, network problems, and bad gameplay flow.

## Required mindset

A passing build is not enough.

Codex must verify:

```text
build works -> game launches -> UI is readable -> gameplay is understandable -> console is clean enough -> network path behaves -> match can finish -> result is shown
```

If visual or runtime issues are found, Codex must debug and retry instead of leaving them for the user.

## Required visual checks

Codex must inspect the player-facing game for:

- text overlap,
- text clipped outside panels,
- buttons overlapping other buttons,
- HUD covering important gameplay,
- scoreboard blocking combat,
- cooldown icons unreadable,
- health bars too small or hidden,
- menu labels misaligned,
- result screen values colliding,
- 25-player deathmatch clutter hiding the local player,
- UI scale breaking at different window sizes,
- missing hover/focus/pressed feedback where applicable,
- player-facing debug text that should not be visible,
- player-facing words like placeholder, mock, prototype, TODO, unfinished.

## Required resolution checks

At minimum, check or simulate these sizes:

```text
1280x720
1920x1080
mobile/tall-ish layout if supported
```

The game does not need final mobile polish, but it must not become unreadable or unusable at common desktop sizes.

## Required gameplay-view checks

Codex must verify from the game view, not only from scripts:

- local player is visually obvious,
- allies/enemies are readable in 3v3,
- nearby enemies are readable in 25-player deathmatch,
- projectiles and ability effects are visible,
- hits and deaths provide feedback,
- respawn is understandable,
- score/timer/rank changes are visible,
- result screen reflects the actual match outcome,
- restart or return-to-menu works.

If visual interaction is unavailable, Codex must create and run an automated visual smoke path that at least captures or logs screen/state milestones:

```text
menu_loaded
mode_selected
match_loaded
hud_visible
combat_events_seen
match_finished
result_screen_visible
```

## Required console and debugger checks

Codex must inspect relevant runtime output:

- Godot output console,
- parse errors,
- missing resource warnings,
- autoload errors,
- scene instantiation errors,
- null reference errors,
- signal connection errors,
- physics/collision warnings that affect gameplay,
- failed content load messages,
- backend/local-adapter errors,
- server transport errors.

Do not ignore repeating warnings if they indicate broken gameplay, broken UI, missing scenes, missing assets, invalid content, or network failure.

## Required network checks

For friend-capable multiplayer and local server paths, Codex must inspect:

- host/server start logs,
- join request logs,
- handshake result,
- player ID assignment,
- bot-fill assignment,
- input frame receive logs,
- snapshot send/receive logs,
- disconnect/error logs,
- match result broadcast/submission logs.

If a browser/web export or web debug path is used, inspect browser developer console and network/devtools where available. For native Godot, inspect Godot logs and project network debug output instead.

## Required multiplayer smoke checks

Codex must attempt or simulate:

```text
1 human + bots
2 humans/simulated clients + bots
3v3 Team Arena bot fill
25 Player Deathmatch bot fill
```

The goal is to catch problems that pure bot-soak may miss, such as bad join UI, missing room code, input not reaching server, or snapshots not appearing on the client.

## Required UI/gameplay retry loop

For every visual/runtime issue:

```text
observe issue -> identify scene/script/resource -> patch -> rerun -> verify resolved
```

Examples:

```text
HUD overlaps score -> adjust anchors/containers -> rerun 1280x720 and 1920x1080
local player hard to see in deathmatch -> add outline/marker -> rerun deathmatch smoke
join button does nothing -> inspect signal/log -> patch connection -> rerun join flow
snapshot received but actors not visible -> inspect EntityViewBinder -> patch -> rerun client
```

## Required final report additions

The final report must include:

```text
Runtime/visual QA:
- resolutions checked
- UI overlap/text collision findings
- gameplay readability findings
- console warnings/errors reviewed
- network logs reviewed
- visual issues fixed
- remaining visual limitations
```

## What does not count as success

- Only running unit tests.
- Only checking that scripts parse.
- Only running bot-soak without launching or smoke-testing the player-facing flow.
- Leaving overlapped UI or unreadable HUD for the user to notice.
- Ignoring console errors because the game window opened.
- Claiming multiplayer works without checking join/handshake/input/snapshot logs.
