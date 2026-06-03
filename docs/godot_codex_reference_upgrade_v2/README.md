# Canonical Codex Reference Pack

This folder is the active implementation contract for Codex work in this repository.

Global entry point:

```text
docs/CODEX.md
```

Single-prompt complete-game challenge entry point:

```text
docs/godot_codex_reference_upgrade_v2/CODEX_ONE_PROMPT_BUILD.md
```

Complete-game definition:

```text
docs/godot_codex_reference_upgrade_v2/CODEX_COMPLETE_GAME_CONTRACT.md
```

The legacy v1 folder was removed and must not be recreated:

```text
docs/godot_codex_reference/
```

## Mandatory reading order for normal Codex work

1. `CODEX_BUILD_CONTRACT.md`
2. `CODEX_COMPLETE_GAME_CONTRACT.md`
3. `docs/24_exact_repository_layout.md`
4. `docs/25_godot_class_contracts.md`
5. `docs/26_cli_command_contract.md`
6. `docs/27_network_payload_contracts.md`
7. `docs/28_nakama_runtime_contract.md`
8. `docs/30_first_30_codex_tasks.md`
9. `CODEX_ACCEPTANCE_GATES.md`
10. `CODEX_FAILURE_RECOVERY.md`

## Scope

Build a complete scoped 2D/2.5D hero arena / MOBA-lite game in Godot 4.x using typed GDScript.

The required challenge result is a finished small game, not a mockup, not a prototype, and not a partial vertical slice.

The selected architecture is:

- Godot client.
- Godot headless authoritative match server.
- Nakama-compatible backend boundary.
- Shared simulation code between client and server where safe.
- Server-authoritative combat, cooldowns, damage, deaths, respawns, scoring, objectives, and match results.
- Bots that generate the same input frames as human clients.
- Player-facing main menu, arena match, HUD, pause, and result screens.

## Non-negotiable rule

Do not replace this with a local-only prototype architecture. When a feature is built before networking exists, it must still use the final boundaries: input frames, simulation ticks, data-driven abilities, shared content validation, authoritative state ownership, and automated validation.

The required game path must not depend on the user manually finishing scene wiring or tests after Codex completes the prompt.
