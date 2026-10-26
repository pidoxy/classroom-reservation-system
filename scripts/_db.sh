#!/usr/bin/env bash
# Shared helpers. Sourced by the other scripts; not run directly.
#
# Uses the psql and pgbench on your machine when they exist. If they do not,
# it falls back to the ones inside the Docker container from docker-compose.yml.
# Either way you need nothing installed for a particular programming language.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATABASE_URL="${DATABASE_URL:-postgresql://postgres:postgres@localhost:5432/reservations}"

if command -v psql >/dev/null 2>&1 && command -v pgbench >/dev/null 2>&1; then
  DB_MODE="local"
elif command -v docker >/dev/null 2>&1 && (cd "$REPO_ROOT" && docker compose ps --status running db 2>/dev/null | grep -q db); then
  DB_MODE="docker"
else
  echo "Cannot find psql and pgbench, and the Docker database is not running." >&2
  echo "Either install the PostgreSQL client tools, or run: ./scripts/db-up.sh" >&2
  exit 2
fi

# run_psql [psql args]   reads SQL from standard input.
run_psql() {
  if [ "$DB_MODE" = "local" ]; then
    psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 "$@"
  else
    (cd "$REPO_ROOT" && docker compose exec -T db psql -U postgres -d reservations -X -q -v ON_ERROR_STOP=1 "$@")
  fi
}

# run_pgbench_file <path relative to tests/> [pgbench args]
run_pgbench_file() {
  local rel="$1"; shift
  if [ "$DB_MODE" = "local" ]; then
    pgbench "$DATABASE_URL" -n -f "$REPO_ROOT/tests/$rel" "$@"
  else
    (cd "$REPO_ROOT" && docker compose exec -T db pgbench -U postgres -d reservations -n -f "/tests/$rel" "$@")
  fi
}
