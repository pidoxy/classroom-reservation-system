#!/usr/bin/env bash
# Throw away everything in the LOCAL database and start clean.
# Refuses to run against anything that is not on this machine.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_db.sh"
case "$DATABASE_URL" in
  *@localhost:*|*@127.0.0.1:*|*@\[::1\]:*) ;;
  *) echo "Refusing: DATABASE_URL does not point at localhost." >&2; exit 1 ;;
esac
echo "This deletes every table in the local database."
read -r -p "Type 'reset' to continue: " answer
[ "$answer" = "reset" ] || { echo "Cancelled."; exit 1; }
echo "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" | run_psql
echo "Database reset."
