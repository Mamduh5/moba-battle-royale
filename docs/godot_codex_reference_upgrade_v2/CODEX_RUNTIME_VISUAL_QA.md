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

A final report that says "manual rendered UI pass still needed" means the complete-game challenge is not complete.

## No manual visual QA handoff rule

Do not leave rendered UI/readability verification for the user.

Codex must either:

1. perform an interactive rendered UI pass itself, or
2. create and run an automated rendered UI audit that captures screenshots and checks UI/game milestones.

Headless milestone logs alone are not enough to claim complete visual QA.

If neither rendered interaction nor screenshot capture is possible, report the complete-game target as incomplete and name the exact environment blocker.

## Required rendered UI audit artifacts

Codex must produce local QA artifacts under a path such as:

```text
qa_artifacts/rendered_ui/
```

Required captures where tooling allows:

```text
1280x720/main_menu.png
1280x720/mode_select.png
1280x720/3v3_hud_mid_match.png
1280x720/3v3_result.png
1280x720/deathmatch_hud_mid_match.png
1280x720/deathmatch_result.png
1920x1080/main_menu.png
1920x1080/mode_select.png
1920x1080/3v3_hud_mid_match.png
1920x1080/3v3_result.png
1920x1080/deathmatch_hud_mid_match.png
1920x1080/deathmatch_result.png
```

If screenshots are generated but not committed, the final report must list their local paths and summarize findings.

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

At minimum, check these sizes with actual rendered output when possible:

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

If visual interaction is unavailable, Codex must create and run an automated rendered smoke path that captures screenshots or rendered frames and logs screen/state milestones:

```text
menu_loaded
mode_selected
match_loaded
hud_visible
combat_events_seen
match_finished
result_screen_visible
```

## Required UI geometry audit

Where possible, add a debug/audit command that inspects Control node Rect2 bounds for visible UI screens.

The audit should flag:

- overlapping sibling controls that should not overlap,
- text labels whose content exceeds their control bounds,
- buttons with zero or tiny size,
- controls outside the viewport,
- HUD panels intersecting the central gameplay focus area more than intended,
- score/rank labels hidden behind other controls.

The audit may use allowlists for deliberate layout overlap, but it must not ignore all overlap by default.

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
- rendered screenshots or interactive inspection method used
- screenshot/artifact paths if generated
- resolutions checked
- UI overlap/text collision findings
- gameplay readability findings
- console warnings/errors reviewed
- network logs reviewed
- visual issues fixed
- remaining visual limitations
```

If rendered UI inspection was not completed, the final report must say:

```text
Game completion status: incomplete for strict challenge rules, because rendered UI QA was not completed.
```

## What does not count as success

- Only running unit tests.
- Only checking that scripts parse.
- Only running bot-soak without launching or smoke-testing the player-facing flow.
- Only logging milestones without rendered screenshots or interactive rendered inspection.
- Leaving a rendered UI pass for the user.
- Leaving overlapped UI or unreadable HUD for the user to notice.
- Ignoring console errors because the game window opened.
- Claiming multiplayer works without checking join/handshake/input/snapshot logs.
