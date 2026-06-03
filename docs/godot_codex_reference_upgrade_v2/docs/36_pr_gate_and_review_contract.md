# 36 - PR Gate and Review Contract

Every Codex PR must be small, testable, and bound to the architecture.

## PR size

Preferred maximum:

```text
15 files or fewer
600 changed lines or fewer
```

Larger PRs must explain why they cannot be split.

## PR description template

```text
Purpose:
- What feature/fix this implements.

Architecture impact:
- Client/shared/server/backend boundaries touched.

Changed files:
- path: summary

Commands run:
- command and result

Tests added/updated:
- test name and coverage

Risk:
- known limitations or follow-up work
```

## Required gates by touched area

### Content only

Run:

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd validate-content
```

### Shared simulation/combat/abilities

Run:

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd validate-content
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd run-tests --suite all
```

### Network/protocol

Run:

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd protocol-check
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd server-smoke --duration-sec 15
```

### Bots

Run:

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd bot-soak --matches 5 --bots 6
```

### Backend/Nakama

Run:

```bash
docker compose -f backend/nakama/docker-compose.yml up -d
# then run backend tests defined by repository tooling
```

## Rejection criteria

Reject or revise a PR if it:

- trusts client combat results
- adds gameplay behavior only in UI
- creates unvalidated content shape
- adds protocol fields without schemas/examples/tests
- adds online-incompatible offline-only architecture
- bypasses shared input frame path for bots
- cannot be run or validated by command line
- silently ignores errors

## Merge rule

A PR may merge only after:

- required commands pass or missing commands are honestly documented as not yet implemented
- no architecture boundary violation exists
- reviewer can understand changed behavior from diffs
- docs are updated when contracts changed
