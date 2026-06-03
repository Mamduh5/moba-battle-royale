# Implementation Agenda

This agenda is a build sequence for the complete target architecture. It is not a disposable prototype path. Each step uses production boundaries from the start.

## Stream A: Project foundation

1. Create repository layout from `docs/01_architecture.md`.
2. Pin Godot version and document local setup.
3. Add typed GDScript conventions and static checks.
4. Add content folder and schema validation runner.
5. Add logging wrapper with structured event output.
6. Add build environment config for local, staging, production.
7. Add test runner entry points.

Acceptance gate:

- Project opens in Godot.
- Headless test command runs.
- Content validator runs.
- Documentation path exists inside repo.

## Stream B: Shared simulation core

1. Implement entity ID service.
2. Implement entity registry.
3. Implement simulation clock.
4. Implement movement component.
5. Implement health/resource component.
6. Implement event bus for server gameplay events.
7. Implement deterministic replay event recording.
8. Implement simulation tests for movement and health.

Acceptance gate:

- Headless simulation can spawn entities, move them, damage them, kill them, and record events.

## Stream C: Abilities and combat

1. Implement ability data loading.
2. Implement ability validation pipeline.
3. Implement cooldown/charge state.
4. Implement damage resolver.
5. Implement projectile runtime.
6. Implement area effect runtime.
7. Implement status effect runtime.
8. Implement ability rejection reasons.
9. Add tests for valid/invalid casts, projectile hits, cooldowns, status effects.

Acceptance gate:

- A hero can cast a basic attack and two skills in headless simulation with server-owned results.

## Stream D: Client match presentation

1. Implement client boot flow.
2. Implement input collection abstraction.
3. Implement world view and entity view binding by entity ID.
4. Implement camera rig.
5. Implement HUD state binding.
6. Implement local feedback for ability press/reject/confirm.
7. Implement debug overlay.

Acceptance gate:

- Client can display simulation snapshots and send input intent without owning gameplay truth.

## Stream E: Dedicated server networking

1. Implement server CLI config parser.
2. Implement connection handshake.
3. Implement match token validation interface.
4. Implement input frame receive path.
5. Implement snapshot send path.
6. Implement input ack and correction messages.
7. Implement reconnect policy.
8. Add network contract tests.

Acceptance gate:

- Two local clients can connect to a headless server, move, cast, receive snapshots, and reconcile corrections.

## Stream F: Bots

1. Implement bot registry.
2. Implement perception snapshot.
3. Implement blackboard.
4. Implement utility scoring.
5. Implement movement planner.
6. Implement ability planner.
7. Implement bot input emitter.
8. Add bot-vs-bot soak command.

Acceptance gate:

- A full bot match completes headlessly with no manual editor interaction.

## Stream G: Nakama integration

1. Add Nakama Godot client plugin or SDK wrapper.
2. Implement auth flow.
3. Implement profile fetch.
4. Implement matchmaker ticket flow.
5. Implement match assignment parsing.
6. Implement signed match token validation on server.
7. Implement match result submission interface.
8. Add local Docker Compose integration.

Acceptance gate:

- Local client authenticates, queues, receives assignment, joins server, completes match, and fetches updated result state.

## Stream H: Modes, maps, objectives

1. Implement mode data schema.
2. Implement map data schema.
3. Implement team arena mode.
4. Implement capture objective mode.
5. Implement lane/tower/minion systems.
6. Implement jungle camps or neutral boss.
7. Implement custom room rules.
8. Add bot hints per map.

Acceptance gate:

- At least three modes run through the same match lifecycle and result packet shape.

## Stream I: Quality, performance, and release

1. Add replay runner.
2. Add load test runner.
3. Add mobile performance budget checks.
4. Add release export presets.
5. Add crash/log upload path.
6. Add server compatibility gates.
7. Add release checklist automation.

Acceptance gate:

- Staging build runs full online flow with logs, replay capture, and release checklist signed off.
