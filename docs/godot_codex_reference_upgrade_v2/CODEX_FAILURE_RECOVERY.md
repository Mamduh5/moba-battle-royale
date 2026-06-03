# Codex Failure Recovery

Use this file when the environment cannot run Godot, Docker, Nakama, or other required tools.

The goal is to preserve the final architecture and produce an honest, useful partial implementation.

## General rule

Do not fake success. Do not replace the target architecture with a simpler demo. Complete the highest-value text-reviewable work and report the blocker.

## If Godot is unavailable

Still do:

- create the expected `.gd` scripts,
- keep scripts typed,
- add command router files,
- add JSON content and schemas,
- run JSON parsing or other available static checks,
- document exact Godot commands that should be run locally.

Do not claim:

- scripts parse in Godot,
- scenes run,
- headless server starts,
- bot soak passes.

Report:

```text
Godot unavailable: created implementation files and static JSON checks only. Godot parse/runtime validation remains required.
```

## If Docker or Nakama is unavailable

Still do:

- add `infra/nakama/` or equivalent local stack config,
- add environment examples without secrets,
- add Nakama client/server boundary scripts,
- add RPC contract docs or runtime module placeholders,
- add tests that can run without the service where feasible.

Do not claim:

- login works,
- matchmaking works,
- result submission works,
- storage writes work.

Report:

```text
Nakama unavailable: backend boundary/config created, live integration not executed.
```

## If scene editing is risky

Still do:

- create scripts,
- create minimal text-safe scenes only when confident,
- document required Godot editor wiring in `docs/SCENE_WIRING_NOTES.md`.

Do not perform large fragile `.tscn` edits just to appear complete.

## If one-pass scope is too large

Prefer this completion order:

1. Layout and docs mapping.
2. Content examples and validation.
3. Protocol models.
4. Simulation state and tick loop.
5. Movement/damage/cooldowns/basic ability.
6. Bot input path.
7. MatchRoom bot-only lifecycle.
8. CLI command router.
9. Client skeleton.
10. Nakama boundary.

Stop at the last coherent boundary and report the next task.

## If existing files conflict with the contract

Do not duplicate systems blindly.

Create or update:

```text
docs/PROJECT_LAYOUT_MAPPING.md
```

The mapping must state:

- existing path,
- contract path,
- whether an adapter was added,
- whether migration is still required.

## Final honesty rule

The final report must separate:

- completed,
- partially completed,
- not attempted,
- blocked by environment,
- intentionally deferred by one-prompt scope.
