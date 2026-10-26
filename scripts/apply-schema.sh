#!/usr/bin/env bash
# Apply every .sql file in db/migrations/ in name order.
# This is the plain, tool-free way. If your language has a migration tool,
# use that instead, as long as the result matches docs/schema-contract.md.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_db.sh"
shopt -s nullglob
files=("$REPO_ROOT"/db/migrations/*.sql)
if [ ${#files[@]} -eq 0 ]; then
  echo "No .sql files in db/migrations/ yet. Step 1 is yours to build." >&2
  exit 1
fi
for f in "${files[@]}"; do
  echo "Applying $(basename "$f")"
  run_psql < "$f"
done
echo "Schema applied."
