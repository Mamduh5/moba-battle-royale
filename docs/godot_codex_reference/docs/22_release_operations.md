# Release and Operations

## Environments

Use three environments:

- local: developer machine and local Docker services
- staging: production-like test environment
- production: live players

Environment config is explicit. No code path guesses environment based on hostname.

## Versioning

Version all release-critical contracts:

- client build
- server build
- protocol version
- content manifest
- live config version
- backend module version

## Deployment units

Deployment units:

- client build
- dedicated match server image/export
- Nakama modules/config
- database migrations
- live config
- content package

## Rollback

Each release must define rollback steps:

- disable mode through live config
- stop new matchmaking tickets
- drain match servers
- rollback server image
- rollback content manifest
- rollback backend module when safe

## Monitoring

Track:

- auth failure rate
- matchmaking time
- match allocation failures
- server crash rate
- average match duration
- disconnect/reconnect rate
- invalid command rate
- result submission failures
- reward write failures
- latency by region

## Incident response

For live incidents:

1. Freeze deployment.
2. Identify affected version/content/mode.
3. Disable affected queue if necessary.
4. Preserve logs and replays.
5. Roll back or patch.
6. Write post-incident notes.
7. Add regression tests or alerts.
