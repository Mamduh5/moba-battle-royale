# Security and Anti-Cheat

## Security principle

The server validates all gameplay-changing requests. The backend validates all persistent rewards. The client is treated as untrusted.

## Common client attacks and defenses

### Speed hack

Defense: server clamps movement by authoritative speed, tick delta, status state, and collision. Excess movement requests are rejected and logged.

### Cooldown bypass

Defense: cooldowns and charges live on server. Ability requests are rejected when cooldown state disallows cast.

### Damage injection

Defense: clients never submit damage as trusted state. Server creates DamageIntent and final DamageEvent.

### Position teleport

Defense: clients submit movement intent only. Server ignores position claims except optional debug hints.

### Reward fraud

Defense: rewards derive from server-signed match results and backend validation.

### Replay/duplicate messages

Defense: sequence numbers, timestamps, session IDs, and token expiration. Drop stale or duplicated commands.

### Token theft

Defense: short-lived match tokens, session binding, TLS in production, revoke/replace duplicate session policy.

## Suspicion scoring

Track suspicious behavior:

- invalid command rate
- impossible input timing
- repeated ability violations
- protocol mismatches
- session/token anomalies
- reconnect abuse

Suspicion score informs logs, moderation, and possible automatic match removal. Avoid false-positive bans without review data.

## Secrets

Never commit:

- Nakama server keys
- signing keys
- production database credentials
- analytics secrets
- store signing credentials
- platform private keys

Use environment variables or deployment secret stores.

## Admin features

Admin commands require authorization. Every admin action is logged with actor ID, match ID, command, payload, result, and timestamp.
