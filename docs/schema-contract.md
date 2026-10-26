# Schema contract

Step 1 of the [build order](brief/build-order.md) is the database schema. You design it, in any tool and any language. This page is the **contract** your schema must honour so the shared tests in `tests/step-1/` can check it.

The contract fixes names and types. It does not fix how you create them. Plain SQL files, a Python migration tool, a JavaScript one, or an ORM are all fine, as long as the result matches.

## Database

PostgreSQL 16, with the `btree_gist` extension (needed for the no-overlap rule):

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;
```

## Tables and columns

Use plural, lower snake case table names and the column names below. Types are the ones the tests rely on.

| Table | Column | Type | Notes |
| --- | --- | --- | --- |
| `students` | `student_id` | `text` | Primary key. Comes from university sign-in. |
| | `email` | `text` | |
| | `display_name` | `text` | |
| | `suspended_until` | `timestamptz` | Nullable. |
| `buildings` | `building_id` | `text` | Primary key. |
| | `name` | `text` | |
| | `zone` | `text` | |
| | `latitude`, `longitude` | `double precision` | |
| `rooms` | `room_id` | `uuid` | Primary key. |
| | `code` | `text` | Unique, for example `ENG-201`. |
| | `building_id` | `text` | References `buildings`. |
| | `name` | `text` | |
| | `type` | `text` | One of `study`, `seminar`, `other`. |
| | `capacity` | `integer` | |
| | `opens_at`, `closes_at` | `time` | Campus local time. |
| | `is_active` | `boolean` | |
| `bookings` | `booking_id` | `uuid` | Primary key. **Must default** to a generated UUID. |
| | `room_id` | `uuid` | References `rooms`. |
| | `student_id` | `text` | References `students`. |
| | `during` | `tstzrange` | The booking as one half-open range, `[start, end)`. |
| | `purpose` | `text` | |
| | `status` | `text` | One of `CONFIRMED`, `CANCELLED`, `CHECKED_IN`, `NO_SHOW`, `COMPLETED`. |
| | `idempotency_key` | `uuid` | |
| | `checked_in_at` | `timestamptz` | Nullable. |
| | `cancelled_at` | `timestamptz` | Nullable. |
| | `created_at` | `timestamptz` | **Must default** to `now()`. |

The other entities in the [data model](brief/data-model.md) (`amenities`, `room_amenities`, `booking_events`, `penalties`, `notifications`, `announcements`, `policy`) are yours to name in the same style. The step 1 tests do not touch them yet.

### Two rules about extra columns

1. Any column you add beyond the table above must be nullable or have a default. The test fixtures only fill the columns listed here.
2. Every column listed above may be `NOT NULL`. The fixtures fill all of them.

## What the database must hold

These four rules come straight from the [Build Brief](brief/data-model.md#rules-that-must-always-hold). They live in the database, not in application code.

1. **No two active bookings for the same room overlap.** An exclusion constraint on `(room_id =, during &&)`, only where `status` is active (`CONFIRMED` or `CHECKED_IN`). Ranges are half-open, so 10:00 to 11:00 and 11:00 to 12:00 do not clash. A cancelled, no-show or completed booking frees its slot.
2. **A student has at most one active booking per room.** A partial unique index on `(student_id, room_id)`, only where `status` is active.
3. **One booking per student and idempotency key.** A unique index on `(student_id, idempotency_key)`.
4. **End after start, and a valid status.** A check that the range is not empty, and a check (or enum) limiting `status` to the five values above.

## Checking your work

```bash
./scripts/db-up.sh          # start PostgreSQL 16 in Docker (skip if you have your own)
# ... apply your schema (for plain SQL: put files in db/migrations/ and run ./scripts/apply-schema.sh)
./scripts/check-step1.sh    # the shared tests
```

The checks cover T-R6, T-E1 and T-E5 from the Brief, plus one check for each of the four rules above, because a constraint written without its "only where active" condition can pass the first three and still be wrong.

## A note on the Brief

The Brief says the status is "one of the six values" but lists five: `CONFIRMED`, `CANCELLED`, `CHECKED_IN`, `NO_SHOW` and `COMPLETED`. This repository uses the five. If you think a sixth is missing, open an issue.
