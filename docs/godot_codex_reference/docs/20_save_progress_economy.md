# Save, Progression, and Economy

## Persistent data ownership

Nakama/backend owns persistent data. The client caches for display only.

## Data categories

Persistent:

- account profile
- owned heroes
- owned skins/cosmetics
- currencies
- battle pass/season progress
- hero mastery
- ranked rating
- missions
- settings synced to account

Local-only:

- graphics settings
- sound volume if not synced
- control layout cache
- last selected region
- debug preferences in dev builds

## Reward flow

1. Match server ends match.
2. Match server signs or submits result through trusted backend path.
3. Backend validates match ID, roster, duration, mode, suspicious flags, and result.
4. Backend computes rewards.
5. Backend writes storage/leaderboards/missions.
6. Client fetches updated state.

## Economy rules

Never let the client grant currency, unlock inventory, set rank, or complete missions directly.

## Idempotency

Match result submission must be idempotent. Repeating the same result packet must not duplicate rewards.

## Auditing

Economy-changing operations log:

- player ID
- operation ID
- source match/event
- currency/item changed
- before/after or delta
- server/backend actor
- timestamp
