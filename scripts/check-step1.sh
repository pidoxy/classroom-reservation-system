#!/usr/bin/env bash
# Step 1 checks: the database holds the rules, whatever language the rest of the system uses.
#
#   ./scripts/check-step1.sh
#
# Needs a database that already has your schema (see docs/schema-contract.md).
# Set DATABASE_URL to point somewhere else; the default is the Docker database.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_db.sh"
T="$REPO_ROOT/tests/step-1"
failed=0

say_pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
say_fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; failed=$((failed + 1)); }

echo "Step 1: schema and constraints  (database access: $DB_MODE)"

# 1. The tables from the schema contract must exist.
missing=""
for t in students buildings rooms bookings; do
  found=$(run_psql -At -c "SELECT to_regclass('public.$t') IS NOT NULL" 2>&1 </dev/null)
  [ "$found" = "t" ] || missing="$missing $t"
done
if [ -n "$missing" ]; then
  say_fail "missing tables:$missing  (read docs/schema-contract.md, then apply your schema)"
  echo; echo "Step 1 not ready: $failed problem(s)."; exit 1
fi
say_pass "tables exist"

# 2. Fixtures.
if ! out=$(run_psql < "$T/fixtures.sql" 2>&1); then
  say_fail "fixtures could not be inserted. Your tables must accept the columns in docs/schema-contract.md"
  echo "$out" | sed 's/^/        /'
  echo; echo "Step 1 not ready: $failed problem(s)."; exit 1
fi

# 3. The SQL tests. Each prints PASS or FAIL through RAISE.
run_sql_test() {
  local file="$1" label="$2" out
  out=$(run_psql < "$T/$file" 2>&1)
  if echo "$out" | grep -q "PASS"; then
    say_pass "$label"
  else
    say_fail "$label"
    echo "$out" | grep -E "FAIL|ERROR" | head -3 | sed 's/^/        /'
  fi
}
run_sql_test t_r6_partial_overlap.sql   "T-R6   partial overlap is refused, one booking stored"
run_sql_test t_e5_back_to_back.sql      "T-E5   back to back bookings are both accepted"
run_sql_test rule_1_cancelled_frees_slot.sql "Rule 1 only active bookings block a slot"
run_sql_test rule_2_one_active_per_room.sql "Rule 2 one active booking per student per room"
run_sql_test rule_3_idempotency_key.sql "Rule 3 one booking per student and idempotency key"
run_sql_test rule_4_checks.sql          "Rule 4 end after start, valid status"

# 4. T-E1: 50 parallel requests for one slot. This one can take up to 20 seconds,
#    because PostgreSQL resolves the collisions one at a time.
run_psql < "$T/fixtures.sql" >/dev/null 2>&1
bench_out=$(run_pgbench_file step-1/t_e1.pgbench -c 50 -j 10 -t 1 2>&1)
rows=$(run_psql -At -c "SELECT count(*) FROM bookings WHERE room_id = '00000000-0000-4000-8000-0000000000a1'" </dev/null 2>&1)
succeeded=$(echo "$bench_out" | sed -n 's/.*actually processed: \([0-9]*\)\/50.*/\1/p')
run_psql -c "DELETE FROM bookings WHERE room_id = '00000000-0000-4000-8000-0000000000a1'" </dev/null >/dev/null 2>&1
if [ "$rows" = "1" ] && [ "${succeeded:-x}" = "1" ]; then
  say_pass "T-E1   50 parallel requests: 1 stored, 49 refused by the database"
else
  say_fail "T-E1   expected 1 stored and 49 refused; found $rows stored and ${succeeded:-?} accepted"
  echo "$bench_out" | grep -E "ERROR|FATAL" | sort | uniq -c | head -3 | sed 's/^/        /'
fi

echo
if [ "$failed" -eq 0 ]; then
  echo "Step 1 passes. Commit your schema, then move to step 2."
else
  echo "Step 1 not ready: $failed check(s) failing."
  exit 1
fi
