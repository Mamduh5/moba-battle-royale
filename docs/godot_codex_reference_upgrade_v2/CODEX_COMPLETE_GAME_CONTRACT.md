# Codex Complete Game Contract

This project is being used for a one-prompt challenge: build a complete game in one prompt.

Complete means a scoped, playable, internally coherent game with no hidden manual-work dependency. It does not mean a massive commercial MOBA with years of content. It means Codex must finish a small but real Godot hero-arena game that can be launched, played, validated, and judged from repository output.

## Product definition

Build a complete top-down hero arena game:

```text
Title working name: Arena Royale
Genre: 2D/2.5D top-down hero arena / MOBA-lite
Core match: 3v3 team arena with bots filling empty slots
Session length: 3 to 5 minutes
Win condition: team score limit or match timer
Primary platform: desktop first, mobile-ready input boundaries
Engine: Godot 4.x
Language: typed GDScript
```

The game must feel like a finished small game, not an engine test scene.

## Required complete game loop

A complete run includes:

1. boot application,
2. load content,
3. show main menu,
4. start local match or connect to local match server,
5. select or auto-assign hero/loadout,
6. load arena,
7. spawn player and bots,
8. play until victory/loss,
9. show result screen,
10. allow restart or return to menu,
11. produce logs and validation output.

No step may depend on the user manually wiring nodes after Codex finishes.

## Minimum gameplay content

Implement at least:

- 3 heroes with distinct stats and ability sets,
- 1 arena map with spawn points, objective positions, walls/obstacles, and safe bounds,
- 1 complete mode: 3v3 team arena,
- 3 abilities per hero: basic attack, mobility or defensive skill, ultimate or high-impact skill,
- health, damage, cooldowns, deaths, respawn, score, timer, match end,
- bots that can move, attack, use abilities, retreat, and pursue objectives,
- HUD for health, cooldowns, team score, timer, ping/connection state when applicable,
- main menu, match loading state, pause/escape menu, result screen,
- consistent simple art style using available assets or generated primitive/vector shapes.

Simple art is acceptable only when it is cohesive and intentionally styled. Do not label it placeholder, mock, temporary, or prototype inside user-facing game screens.

## Architecture requirement

The finished game must preserve the final architecture boundaries:

```text
Godot client <-> Godot headless authoritative match server <-> Nakama backend boundary
```

For one-prompt completion, the game must be playable even when external services are unavailable. That means:

- local bot match must be complete and playable,
- local headless server path must exist,
- Nakama integration files/config/contracts must exist,
- if Nakama cannot run in the environment, provide a local dev auth/match assignment fallback that uses the same interface and is clearly non-production.

The fallback is allowed only as a development adapter. It must not replace the Nakama boundary or fake production integration success.

## No mock/prototype rule

Do not produce:

- a scene that only demonstrates movement,
- a partial vertical slice with missing screens,
- a local-only prototype that bypasses server-authoritative systems,
- TODO-only networking or bot files,
- UI that requires manual editor setup after completion,
- gameplay that works only by manually spawning nodes in the editor,
- fake passing tests,
- undocumented stubs in production paths.

If an external tool cannot run, implement the code path and report the exact blocker. Do not say the game is fully verified when it is not.

## Completion bar

The one-prompt result is acceptable only when repository output supports all of these:

- playable local game loop,
- bot-filled match from menu to result screen,
- authoritative simulation path,
- data-driven heroes and abilities,
- automated content validation,
- automated protocol checks,
- automated bot-soak or headless match run path,
- no manual scene wiring required for the minimum game path,
- honest final report.

## Automated proof requirement

Codex must attempt to run all available checks before final response:

```text
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- validate-content
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- protocol-check
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- bot-soak --matches 3
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- run-tests
```

If Godot is unavailable, Codex must run available non-Godot checks such as JSON validation and repository consistency checks, then report Godot as unavailable.

## Definition of done

The challenge is done when Codex can truthfully report:

```text
The repository contains a complete scoped Godot hero-arena game. The local game path is playable from menu to match to result screen. Bots fill teams. Gameplay is data-driven and server-authoritative. Validation commands exist and were run where tooling was available. Remaining limitations are listed honestly.
```

Do not weaken this definition to make the task easier.
