#!/usr/bin/env bash
# Start the local PostgreSQL 16 and wait until it accepts connections.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
docker compose up -d db
printf 'Waiting for the database'
for _ in $(seq 1 60); do
  if docker compose exec -T db pg_isready -U postgres -d reservations >/dev/null 2>&1; then
    echo; echo "Ready: postgresql://postgres:postgres@localhost:5432/reservations"; exit 0
  fi
  printf '.'; sleep 1
done
echo; echo "The database did not become ready in 60 seconds." >&2; exit 1
