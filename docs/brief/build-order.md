# Build order

Nine steps. Each step ends with its tests passing before the next one starts. Do not skip ahead: each step stands on the one before it.

| Step | What you build | Tests that must pass | How to check |
| --- | --- | --- | --- |
| 1 | **Schema and constraints.** Tables, the exclusion constraint, unique indexes, check constraints, policy table, seed of 300 rooms | T-R6, T-E1, T-E5, run as direct SQL against the database | `./scripts/check-step1.sh` |
| 2 | **Auth hand-off and search on the primary.** Token check, `GET /rooms/search`, `/rooms/available-soon` | T-R1, T-R2, T-R3 | [conformance cases](../../tests/conformance/README.md) (to be added) |
| 3 | **Booking.** `POST /bookings` with policy checks, idempotency, weekly limit, one-per-room, suspension check | T-R5 to T-R10, T-R20, T-E1, T-E3, T-E15, T-E21 | conformance cases |
| 4 | **Cancel and my bookings.** Cancel, `/me/bookings`, `/me/standing` | T-R4, T-R11, T-E8, T-E11 | conformance cases |
| 5 | **Read replica for search.** Route reads to the replica; add `as_of` | T-R2 freshness, T-E6 | conformance cases |
| 6 | **Worker: check-in, no-shows, penalties.** Check-in endpoint, no-show sweep, completion, penalties, suspension, Just released list | T-R12 to T-R15, T-E22 | conformance cases |
| 7 | **Outbox and notifications.** Outbox rows written in booking transactions; worker sends confirmations, cancellations and reminders with retries | T-R16, T-R17, T-R17b, T-E19 | conformance cases |
| 8 | **Downtime and failure behaviour.** Announcements, banners, primary-down handling, room deactivation | T-R18, T-E17, T-E20 | conformance cases |
| 9 | **Load and drills.** Load test, nightly overlap check, failover drill | T-R19 and every quality target | load script (to be added) |

## Why this order

Step 1 comes first because everything else depends on the database refusing a double booking. If the rule lives only in application code, two requests can both check, both see a free slot, and both save. It is the foundation poured before the walls go up.

Each later step adds one capability and can be verified alone. That is what makes a step small enough to review in one sitting, and clear enough to hand to an AI agent with a check that can fail.

The full list of tests is in [acceptance tests](acceptance-tests.md), and as data in [`tests/acceptance/acceptance-tests.yaml`](../../tests/acceptance/acceptance-tests.yaml).
