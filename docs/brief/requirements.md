# Requirements

Each requirement is numbered and testable, and has at least one [acceptance test](acceptance-tests.md) with the same number. Values in square brackets are policy values from the table at the end, never fixed in code (see R20).

## Search

- **R1.** A student can search rooms by date and time range, and filter by minimum capacity, room type (study, seminar, other), room name, amenities, purpose, booking duration and proximity to a chosen building.
- **R2.** Search returns only rooms that are open and free for the whole requested range. Results may be up to [5 s] old.
- **R3.** A student can see an "Available soon" list: rooms free now or within the next [2 h], soonest first.
- **R4.** A student can see their own upcoming bookings and their standing: bookings used this week, the weekly limit, recent no-shows, and any suspension end date.

## Book

- **R5.** A student can book one room for one time range. Start and end fall on the [30 min] grid, the duration is between [30 min] and [3 h], inside the room's opening hours, and no more than [14 days] ahead.
- **R6.** A booking is confirmed only if no other active booking for that room overlaps it. This check is exact and never uses stale data.
- **R7.** No approval step. A valid booking is confirmed at once.
- **R8.** A student may hold at most one active booking per room at any time.
- **R9.** A student may make at most [5] bookings per calendar week (Monday to Sunday, campus time). Cancelled bookings do not count; no-shows do.
- **R10.** A repeated booking request (double click, network retry) with the same idempotency key creates at most one booking and returns the same result.

## Cancel, check in, release

- **R11.** A student can cancel their own booking any time before it starts. The time is freed at once.
- **R12.** A student checks in from the app between [10 min] before and [15 min] after the start.
- **R13.** A booking with no check-in by start + [15 min] becomes a no-show. The rest of its time is released automatically.
- **R14.** Cancelled and no-show slots appear in a "Just released" list for [2 h] or until the slot starts.
- **R15.** [3] no-shows in a rolling [30 days] suspend booking for [7 days]. Search still works while suspended.

## Notify

- **R16.** The student is notified when a booking is confirmed, cancelled, released as a no-show, and when a suspension starts.
- **R17.** A reminder is sent [60 min] before each active booking (the allowed range is 30 to 60 min). None is sent for a cancelled booking.
- **R18.** Students with bookings inside a planned downtime window, and all active users, are notified of the downtime in advance, and the app shows a banner.

## Scale and speed

- **R19.** Search answers in under 1 s at p95 at expected peak load (see [quality targets](interfaces.md#quality-targets)).
- **R20.** Every policy value in brackets is held in one policy table and read by the service, so changing a limit needs no code change.

## Policy values (proposed defaults)

The same values are in machine-readable form in [`spec/policy.yaml`](../../spec/policy.yaml).

| Policy | Default | Notes |
| --- | --- | --- |
| Time grid | 30 min | Start and end must sit on it |
| Duration | 30 min to 3 h | Per booking |
| Booking horizon | 14 days | How far ahead |
| Weekly limit | 5 bookings | Per student, per calendar week |
| Reminder | 60 min before start | Allowed range 30 to 60 min |
| Check-in window | 10 min before to 15 min after start | Needed to detect no-shows |
| No-show threshold | 3 in 30 days | Triggers suspension |
| Suspension | 7 days | Booking blocked, search allowed |
| Just-released list | 2 h | Or until slot start |
| Search staleness | at most 5 s | Booking is always exact |
