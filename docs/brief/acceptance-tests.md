# Acceptance tests

IDs match requirements (`T-R`) and edge cases (`T-E`). Unless stated, the student is signed in, not suspended, under the weekly limit, and the time is a weekday at 09:00.

The same list as data is in [`tests/acceptance/acceptance-tests.yaml`](../../tests/acceptance/acceptance-tests.yaml), with the build step each test belongs to.

| ID | Given | When | Then |
| --- | --- | --- | --- |
| T-R1 | Rooms A (cap 4, projector), B (cap 10, whiteboard), C (cap 10, projector) are free tomorrow 14:00 to 16:00 | Student searches that range with min_capacity 8 and amenity projector | Only C is returned |
| T-R2 | Room A has a booking 14:00 to 15:00 tomorrow | Student searches 14:30 to 15:30 | A is not returned; response has `as_of` within 5 s |
| T-R3 | Room A free from 09:30, room B free from 10:30 | Student opens Available soon | A listed before B; rooms free only after 11:00 absent |
| T-R4 | Student has 2 upcoming bookings and 3 used this week | Student opens My bookings and My standing | 2 bookings soonest first; used 3, limit 5 |
| T-R5 | Room open 08:00 to 22:00 | Student books 10:00 to 13:00 | 201, status CONFIRMED |
| T-R5b | Same room | Student books 10:00 to 13:30 | 422 `DURATION_NOT_ALLOWED` |
| T-R6 | Active booking 10:00 to 11:00 on room A | Another student books A 10:30 to 11:00 | 409 `SLOT_TAKEN`; one booking stored |
| T-R7 | Valid request | Student books | Status is CONFIRMED immediately; no pending state exists |
| T-R8 | Student holds an active booking on A tomorrow | Student books A for the day after | 409 `ALREADY_BOOKED_THIS_ROOM` |
| T-R9 | Student has 5 non-cancelled bookings starting this week | Student books a sixth this week | 422 `WEEKLY_LIMIT_REACHED` with `resets_at` = next Monday 00:00 |
| T-R10 | None | Two identical POSTs with the same key 50 ms apart | First 201, second 200 with the same booking id; one row |
| T-R11 | Booking starts in 2 h | Student cancels | 200 CANCELLED; a search for that slot now returns the room |
| T-R12 | Booking starts at 10:00 | Student checks in at 09:52 | 200 CHECKED_IN |
| T-R12b | Same | Student checks in at 09:45 | 409 `TOO_EARLY` |
| T-R13 | Booking 10:00 to 12:00, no check-in | Clock reaches 10:16 | Status NO_SHOW; room searchable 10:30 to 12:00; penalty row written |
| T-R14 | T-R13 has happened | Another student opens Just released | The 10:30 to 12:00 slot for that room is listed |
| T-R15 | Student has 2 no-shows in the last 30 days | A third no-show is recorded | `suspended_until` = now + 7 days; POST /bookings returns 403 `SUSPENDED`; search returns 200 |
| T-R16 | None | Student books, then cancels | Two notifications in the outbox, each sent once |
| T-R17 | Booking at 15:00 | Clock reaches 14:00 | One reminder sent between 14:00 and 14:02 |
| T-R17b | Booking at 15:00 cancelled at 13:30 | Clock reaches 14:00 | No reminder sent |
| T-R18 | Downtime announced for Saturday 02:00 to 04:00; student has a booking Saturday 03:00 | Announcement is published | Student notified; banner shown on app open; `GET /announcements` lists it |
| T-R19 | Database seeded with 300 rooms and 14 days of realistic bookings | Load test at 50 searches per second for 10 min | Search p95 under 1 s |
| T-R20 | Weekly limit policy changed from 5 to 3 | Student with 3 bookings this week books again | 422 `WEEKLY_LIMIT_REACHED`, with no deploy |
| T-E1 | Room A free 10:00 to 11:00 | 50 parallel requests from 50 students for A 10:00 to 11:00 | Exactly one 201; 49 `SLOT_TAKEN`; one row |
| T-E3 | Booking created; response lost | App retries with the same key | 200 with the original booking |
| T-E5 | Booking 10:00 to 11:00 on A | Another student books A 11:00 to 12:00 | 201 |
| T-E6 | Replica lags 3 s; A just booked on the primary | Search shows A; student books A | 409 `SLOT_TAKEN` |
| T-E8 | Student made 5 bookings this week and cancelled 2 | Student books again | 201 |
| T-E11 | Booking started 5 min ago | Student cancels | 409 `ALREADY_STARTED` |
| T-E15 | None | Student books 10:10 to 11:10 | 422 `OFF_GRID` |
| T-E17 | Room A has 3 future bookings | Room A deactivated by import | All 3 CANCELLED with actor system; 3 notifications queued |
| T-E19 | Notification provider returns errors | Student books | 201; outbox row retried until the provider recovers; sent once |
| T-E20 | Primary stopped | Student searches, then books | Search 200 with banner; book 503 `SERVICE_UNAVAILABLE` |
| T-E21 | Key K used to book room A | Same key K sent for room B | 422 `IDEMPOTENCY_KEY_REUSED` |
| T-E22 | Booking inside check-in window | Check-in sent twice | Both 200; one state change event |

## Step 1 extras

Step 1 is checked by T-R6, T-E1 and T-E5, plus one extra check for each of the four database rules (see [schema contract](../schema-contract.md)). They exist because a constraint written without its "only where active" condition can pass the three Brief tests and still be wrong.
