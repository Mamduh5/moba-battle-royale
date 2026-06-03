# Infrastructure Reference

This folder contains reference infrastructure notes. Copy and adapt into the project-level `infra/` folder when implementation begins.

## Local stack

Local development uses:

- Godot editor for client testing.
- Godot headless process for dedicated match server.
- Nakama through Docker Compose.
- CockroachDB or PostgreSQL for Nakama local persistence.

## Staging/production stack

Staging and production preserve the same boundaries:

- client build
- dedicated match server export/image
- Nakama backend
- database
- logs/replay storage
- monitoring/metrics

## Secrets

Use environment variables or deployment secrets. Do not commit real keys.

## Match server allocation

For full scale, add an allocator/coordinator that receives match assignments from backend services and starts dedicated match server processes or containers with a signed roster payload.
