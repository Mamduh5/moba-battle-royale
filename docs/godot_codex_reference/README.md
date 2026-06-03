# Godot Codex Reference Pack

This pack is a drop-in reference folder for a Godot project that will be developed with heavy code-agent support. Place this folder at:

```text
<project-root>/docs/codex_reference/
```

Start with these files, in order:

1. `CODEX_START_HERE.md`
2. `MASTER_E2E_SYSTEM_GUIDE.md`
3. `docs/01_architecture.md`
4. `docs/05_multiplayer_authority.md`
5. `docs/11_implementation_agenda.md`
6. `checklists/pr_acceptance_checklist.md`

## Fixed direction

Build a production-oriented top-down hero arena / MOBA-lite game in Godot 4.x. The system uses:

- Godot 4.x as the client and match-server engine.
- Typed GDScript as the default gameplay language.
- A Godot dedicated headless match server as the simulation authority.
- Nakama for accounts, sessions, matchmaking, social features, leaderboards, storage, and live operations metadata.
- Authoritative server rules for combat, movement validation, cooldowns, projectiles, scoring, rewards, and match completion.
- Bots that run through the same input-command path as human players.
- Local, staging, and production workflows that share the same architecture.

## Non-negotiable rules

- The client is never trusted for gameplay truth.
- The match server owns the simulation state.
- The backend owns identity, matchmaking, progression, inventory, rewards, social data, and persistence.
- Gameplay code must not depend on UI nodes.
- UI must not directly mutate authoritative gameplay state.
- Temporary offline-only implementations are not allowed inside production paths.
- Every new system must include debug visibility, test coverage, and a rollback/removal path.

## Pack contents

- `MASTER_E2E_SYSTEM_GUIDE.md`: full system guide.
- `CODEX_START_HERE.md`: agent-facing operating rules.
- `docs/`: architecture, gameplay, networking, bots, backend, build, debug, testing, and release docs.
- `schemas/`: JSON schemas for hero data, ability data, match events, and network messages.
- `checklists/`: PR, debug, release, multiplayer, and balance checklists.
- `templates/`: task, bug report, feature spec, and implementation plan templates.
- `infra/`: reference Docker Compose and deployment notes.
- `scripts/`: shell command references for local development.

Generated on 2026-06-03.
