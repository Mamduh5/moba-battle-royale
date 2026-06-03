# Canonical Codex Reference Pack

This folder is the active implementation contract for Codex work in this repository.

Global entry point:

```text
docs/CODEX.md
```

Single-prompt challenge entry point:

```text
docs/godot_codex_reference_upgrade_v2/CODEX_ONE_PROMPT_BUILD.md
```

The older folder below is deprecated and must not be used as the build contract:

```text
docs/godot_codex_reference/
```

## Mandatory reading order for normal Codex work

1. `CODEX_BUILD_CONTRACT.md`
2. `docs/24_exact_repository_layout.md`
3. `docs/25_godot_class_contracts.md`
4. `docs/26_cli_command_contract.md`
5. `docs/27_network_payload_contracts.md`
6. `docs/28_nakama_runtime_contract.md`
7. `docs/30_first_30_codex_tasks.md`
8. `CODEX_ACCEPTANCE_GATES.md`
9. `CODEX_FAILURE_RECOVERY.md`

## Scope

Build a production-shaped 2D/2.5D hero arena / MOBA-lite system in Godot 4.x using typed GDScript.

The selected architecture is:

- Godot client.
- Godot headless authoritative match server.
- Nakama for identity, matchmaking, storage, leaderboards, progression, party/social, and match result validation.
- Shared simulation code between client and server where safe.
- Server-authoritative combat, cooldowns, damage, deaths, scoring, objectives, and match results.
- Bots that generate the same input frames as human clients.

## Non-negotiable rule

Do not replace this with a local-only prototype architecture. When a feature is built before networking exists, it must still use the final boundaries: input frames, simulation ticks, data-driven abilities, shared content validation, and authoritative state ownership.
