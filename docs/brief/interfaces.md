# Interfaces

All calls are HTTPS JSON and carry the SSO token in the `Authorization` header. Every call can also refuse with `401 UNAUTHENTICATED` (missing or expired token) and `503 SERVICE_UNAVAILABLE` (see [failure behaviour](system-design.md#failure-behaviour)). Times are ISO 8601 with offset.

The machine-readable version is [`spec/openapi.yaml`](../../spec/openapi.yaml). The two should always agree; if they do not, open an issue.

Reads can be served from the read replica. Writes always go to the primary.

## Operations

| Operation | Input | Success | Refusals and meaning |
| --- | --- | --- | --- |
| **Search rooms** (read) `GET /rooms/search` | `date`, `start`, `end`; optional `min_capacity`, `type`, `name`, `amenities[]`, `purpose`, `near_building`, `duration` | 200: rooms free for the whole range, each with building, distance, capacity, amenities, and an `as_of` time | 400 `INVALID_RANGE`: end not after start, or off the grid. 400 `OUT_OF_HORIZON`: in the past or beyond 14 days. 400 `UNKNOWN_FILTER`: amenity or building not found. |
| **Available soon** (read) `GET /rooms/available-soon` | optional `within` (minutes, max 120), `near_building` | 200: rooms free now or soon, soonest first | 400 `INVALID_WINDOW` |
| **Just released** (read) `GET /rooms/released` | optional `near_building` | 200: slots freed by cancel or no-show, newest first | none beyond the common ones |
| **My bookings** (read) `GET /me/bookings` | optional `status` (upcoming, past) | 200: own bookings, soonest first | none beyond the common ones |
| **My standing** (read) `GET /me/standing` | none | 200: `used_this_week`, `weekly_limit`, `no_shows_30d`, `suspended_until` | none beyond the common ones |
| **Book** (write) `POST /bookings` | `room_id`, `start`, `end`, `purpose`; header `Idempotency-Key` (UUID from the client) | 201: booking with id and status CONFIRMED. Same key repeated: 200 with the same booking | 409 `SLOT_TAKEN`: another active booking overlaps. 409 `ALREADY_BOOKED_THIS_ROOM`: student already holds an active booking for this room. 422 `WEEKLY_LIMIT_REACHED`: returns used, limit, `resets_at`. 403 `SUSPENDED`: returns `suspended_until`. 422 `OFF_GRID`, `DURATION_NOT_ALLOWED`, `OUTSIDE_OPENING_HOURS`, `IN_PAST`, `OUT_OF_HORIZON`: the range breaks a policy. 404 `ROOM_NOT_FOUND`: unknown or inactive room. 422 `IDEMPOTENCY_KEY_REUSED`: same key sent with a different body. |
| **Cancel** (write) `POST /bookings/{id}/cancel` | booking id | 200: status CANCELLED. Repeat on an already cancelled booking: 200, same result | 404 `NOT_FOUND`: no such booking, or not yours (the two are not told apart). 409 `ALREADY_STARTED`: start time has passed. 409 `NOT_CANCELLABLE`: booking is NO_SHOW or COMPLETED. |
| **Check in** (write) `POST /bookings/{id}/check-in` | booking id | 200: status CHECKED_IN. Repeat: 200, same result | 404 `NOT_FOUND`. 409 `TOO_EARLY`: more than 10 min before start. 409 `RELEASED`: already marked no-show. 409 `NOT_ACTIVE`: cancelled or completed. |
| **Announcements** (read) `GET /announcements` | none | 200: current and upcoming downtime notices | none beyond the common ones |

### Which refusals are safe to retry

Only `503 SERVICE_UNAVAILABLE` (and timeouts), and only with the **same** `Idempotency-Key`, because a repeat with the same key returns the first booking. Never retry the 409, 403, 404 and 422 refusals: the student has to change something. `401` means sign in again.

## Quality targets

| Target | Measure |
| --- | --- |
| Search speed | p95 under 1 s end to end, under 300 ms in the service, at 50 searches per second |
| Booking speed | p95 under 1 s at 5 bookings per second |
| Booking correctness | Zero overlapping active bookings, ever. Checked by a nightly query that must return no rows |
| Search freshness | Results at most 5 s old; each response carries `as_of` |
| Repeat safety | A repeated booking request never creates a second booking |
| Reminder timing | Sent within 2 min of the target time |
| No-show release | Within 1 min after start + 15 min |
| Availability | 99.5% of term-time hours (07:00 to 22:00); planned downtime announced at least 24 h ahead |
| Notification delivery | At least once, de-duplicated by key; a provider outage never blocks a booking |
