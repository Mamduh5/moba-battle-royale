#!/usr/bin/env bash
set -euo pipefail

cd infra
docker compose -f docker-compose.nakama.reference.yml up
