# Testing and QA

## Test categories

### Data validation tests

Validate every content file against schemas. Reject invalid IDs, missing references, broken numeric ranges, missing presentation fallbacks, and unregistered behavior modules.

### Unit tests

Test formulas, cooldowns, damage resolver, status effect stacking, target filters, timers, serialization, and ID generation.

### Simulation tests

Run headless match logic without the client. Spawn heroes, execute commands, advance ticks, assert state.

### Network contract tests

Validate message schema compatibility. Test version mismatches, malformed payloads, missing fields, unknown opcodes, rate limits, and rejection reasons.

### Replay tests

Run recorded input/event streams. Verify final state checksums and key event timelines.

### Bot soak tests

Run many bot matches headlessly. Report crashes, stuck states, match length outliers, ability usage, objective behavior, and server tick performance.

### Integration tests

Run local Nakama, authenticate, queue, allocate match, connect to server, complete match, submit result, fetch profile changes.

### Manual QA

Manual test passes cover:

- mobile controls
- ability aiming
- UI readability
- latency feel
- reconnect flow
- device performance
- tutorial/training usability
- store/inventory views

## Merge requirement

A gameplay change requires at least one automated test or a clear manual verification path in the PR checklist. Multiplayer changes require contract tests or a replay case.

## Golden scenarios

Maintain golden scenarios:

- one player basic movement
- one player cast each targeting type
- two players duel
- projectile collision
- area effect tick
- status effect stack/expire
- death and respawn
- objective capture
- bot duel
- bot team match
- reconnect during match
- match result submission

## Regression handling

When a bug is fixed, add a replay, test fixture, or content validation case that fails before the fix and passes after the fix.
