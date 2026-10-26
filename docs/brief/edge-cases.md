# Edge cases

The awkward situations the design must handle. Each one is covered by an [acceptance test](acceptance-tests.md), either directly (`T-E` numbers) or through the requirement test named in the last line.

| ID | Case | What the student sees | What is stored |
| --- | --- | --- | --- |
| E1 | Two students book the same room and time at the same instant | One gets a confirmation; the other gets "Just taken" plus nearby free rooms | One booking |
| E2 | Double click on Book | One confirmation | One booking (same idempotency key) |
| E3 | Network drops after the booking succeeded; app retries | The original confirmation | One booking |
| E4 | Partial overlap: 10:00 to 11:00 exists, request 10:30 to 11:30 | "Just taken" | Nothing new |
| E5 | Back to back: 10:00 to 11:00 exists, request 11:00 to 12:00 | Confirmation | Second booking |
| E6 | Search showed the room free but it was booked seconds ago | "Just taken"; the result list refreshes | Nothing new |
| E7 | Sixth booking in the week | Limit message with count and reset date | Nothing new |
| E8 | Student cancelled earlier bookings this week | Cancelled ones do not count toward the limit | Cancelled rows kept |
| E9 | Second active booking for the same room at a different time | "You already have this room booked" with that booking | Nothing new |
| E10 | Cancel 1 min before start | Cancelled; slot shows in Just released | Status CANCELLED, event row |
| E11 | Cancel after start | "Already started" and a prompt to check in | Nothing changes |
| E12 | No check-in by start + 15 min | Push and email: booking released, no-show recorded | Status NO_SHOW, penalty row, slot in Just released |
| E13 | Third no-show in 30 days | Notice of a 7 day suspension; Book buttons disabled with the end date | `suspended_until` set |
| E14 | Suspended student searches | Normal results with a suspension banner | Nothing |
| E15 | Range off the grid (10:10) or past closing time | Field-level error with allowed values | Nothing |
| E16 | Booking in the past or beyond 14 days | Date picker blocks it; API refuses if bypassed | Nothing |
| E17 | Room deactivated with future bookings | Notice that the booking was cancelled by the system, with alternatives | Status CANCELLED, actor system, reason `ROOM_UNAVAILABLE` |
| E18 | Booking cancelled before its reminder time | No reminder | Reminder row skipped at send time |
| E19 | Notification provider down | Booking confirmed in the app as normal; email arrives later | Outbox row retried |
| E20 | Database primary down | Search still works with a "booking paused" banner; Book and Cancel show "Try again in a few minutes" | Nothing |
| E21 | Same idempotency key sent with a different room | Error; the app makes a new key and retries | Nothing new |
| E22 | Check-in tapped twice | One confirmation | One CHECKED_IN change |

E2, E4, E7, E9, E10, E12 to E14, E16 and E18 are covered by T-R10, T-R6, T-R9, T-R8, T-R11, T-R13 to T-R15, T-R5 and T-R17b.
