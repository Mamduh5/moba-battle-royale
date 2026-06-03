# PR Acceptance Checklist

Use this checklist before merging changes.

## Architecture

- [ ] Change follows documented layer boundaries.
- [ ] Client does not gain new gameplay authority.
- [ ] Server remains source of truth for gameplay outcomes.
- [ ] Backend remains source of truth for persistent rewards/data.
- [ ] No temporary production-path workaround was added.

## Code quality

- [ ] GDScript is typed where practical.
- [ ] Public methods have return types.
- [ ] New systems have clear owners.
- [ ] Magic numbers moved to config/data.
- [ ] Errors use explicit reason codes or result objects.

## Data

- [ ] Content schemas updated if shape changed.
- [ ] Content validation passes.
- [ ] New IDs follow naming rules.
- [ ] Data references resolve.

## Multiplayer

- [ ] Message contracts updated if needed.
- [ ] Client messages are validated server-side.
- [ ] Snapshot/reconnect behavior considered.
- [ ] Protocol/content compatibility considered.

## Debug/test

- [ ] Tests added or manual verification documented.
- [ ] Debug overlay/logging/replay support considered.
- [ ] Failure modes are visible in logs.

## Docs

- [ ] Relevant docs updated.
- [ ] Task agenda updated if scope changed.
