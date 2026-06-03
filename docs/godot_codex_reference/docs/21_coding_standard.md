# Coding Standard

## GDScript style

Use typed GDScript. Prefer clear names over abbreviations. Keep scripts small and cohesive.

Required:

- explicit return types on public functions
- typed exported variables
- typed arrays/dictionaries where practical
- constants for string IDs used in code
- no magic numbers inside gameplay formulas
- no hidden node path dependencies without validation

## File naming

Use PascalCase for scenes/classes and snake_case for data IDs.

Examples:

```text
PlayerEntity.gd
AbilityRuntime.gd
DamageResolver.gd
hero_knight.json
ability_fire_orb.json
```

## Function ownership

A function should have one reason to change. Large feature scripts must be split into runtime, data, validation, and presentation pieces.

## Error handling

Use explicit result objects or reason codes for recoverable gameplay/network failures. Do not rely on silent null returns.

## Signals

Use signals for event notification, not for hiding control flow across unrelated systems. Critical gameplay state transitions should be traceable from code.

## Comments

Comment intent and constraints, not obvious syntax. Add comments for authority boundaries, network assumptions, deterministic requirements, and balance-sensitive formulas.

## Forbidden patterns

- UI script directly changing health/damage/cooldowns.
- Client code setting authoritative position.
- Stringly typed message payloads spread across scripts.
- Gameplay data hardcoded inside scene-only scripts.
- Temporary offline-only gameplay paths merged into production directories.
- Multiple systems writing the same state without a clear owner.
