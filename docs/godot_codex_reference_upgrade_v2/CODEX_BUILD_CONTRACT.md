# Codex Build Contract

This document is written as instructions for a coding agent working inside the repository.

## Build the final architecture from the first commit

Do not create disconnected toy systems. Every feature must fit the final stack:

```text
Godot Client <-> Godot Headless Match Server <-> Nakama Backend
```

The client predicts and renders. The match server authoritatively simulates. Nakama owns identity, matchmaking, inventory, progression, economy, leaderboards, and social systems.

## Required behavior when editing the project

Before changing code:

1. Read this file.
2. Read the exact layout and class contract docs.
3. Inspect existing project files.
4. Preserve existing public APIs unless the task explicitly asks to migrate them.
5. Keep PRs small enough to review.

While changing code:

1. Use typed GDScript.
2. Keep gameplay logic out of UI scripts.
3. Keep server truth out of client presentation scripts.
4. Use content JSON definitions for hero, ability, bot, map, and mode values.
5. Add tests or validation scripts for every gameplay rule.
6. Add structured debug output for multiplayer bugs.

Before finishing a task:

1. Run content validation.
2. Run script parse checks.
3. Run unit/integration tests available in the repo.
4. Run the relevant headless command if the feature touches server, bot, or networking code.
5. Report files changed, commands run, and known limitations.

## Do not do these things

Do not:

- Add combat rules directly inside UI nodes.
- Trust client damage, cooldowns, inventory, hero stats, kill credit, objective capture, or match results.
- Create a separate offline combat model that differs from the online model.
- Let bots call special server-only shortcuts unavailable to human input.
- Store production economy or progression state in local files.
- Add unversioned data shapes.
- Change protocol fields without updating schemas and examples.
- Add Godot scene dependencies to shared simulation files.
- Hide important behavior inside editor-only setup that cannot be reviewed in Git.

## Required coding style

Use this style unless the existing project has stricter rules:

```gdscript
class_name DamageResolver
extends RefCounted

func resolve_damage(request: DamageRequest, state: SimulationState) -> DamageResult:
    assert(request != null)
    assert(state != null)
    var result := DamageResult.new()
    return result
```

Rules:

- Use `class_name` for reusable systems.
- Use explicit return types.
- Prefer Resources/RefCounted for pure data/runtime logic.
- Keep Node scripts thin when possible.
- Use `snake_case` for methods and variables.
- Use `PascalCase` for classes.
- Use `SCREAMING_SNAKE_CASE` for constants.
- Avoid global singletons except listed autoloads.
- Do not use stringly typed message names in many places; centralize them in constants.

## Required output format for Codex task completion

Every task completion must include:

```text
Changed files:
- path/to/file.gd: what changed

Commands run:
- command

Validation result:
- pass/fail and why

Notes:
- remaining risks or follow-up tasks
```
