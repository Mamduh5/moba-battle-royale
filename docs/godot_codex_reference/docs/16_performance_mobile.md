# Performance and Mobile Readiness

## Targets

Define target budgets per device tier. Start with:

- 60 FPS target on modern devices.
- 30 FPS fallback on low-end devices.
- Stable input response under normal latency.
- Predictable memory usage.
- No unbounded per-frame allocations.

## Client performance rules

- Pool projectiles, hit effects, floating text, and common VFX.
- Avoid heavy logic in `_process` when event-driven updates are possible.
- Use `_physics_process` for gameplay-timed client prediction.
- Cull off-screen VFX and UI markers.
- Batch UI updates when possible.
- Keep shaders/mobile effects simple.
- Profile before adding complex post-processing.

## Server performance rules

- Run fixed tick simulation.
- Avoid scanning all entities for every ability when spatial queries can narrow candidates.
- Use interest management for snapshots.
- Keep replay/event buffers bounded.
- Cap bot decision costs.
- Track average and worst tick duration.

## Network budget

Snapshot size matters on mobile networks. Use:

- delta snapshots
- quantized positions where acceptable
- entity interest filters
- compact IDs
- event batching
- redundant input frames instead of reliable spam

## Asset rules

- Use texture atlases where appropriate.
- Compress assets per platform.
- Keep UI readable on mobile resolutions.
- Support safe areas and notches.
- Provide low/medium/high quality settings.

## Profiling requirement

Any feature that adds persistent per-frame work must include profiling notes before merge.
