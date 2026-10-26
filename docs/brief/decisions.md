# Decisions and rejected options

Every choice here has a reason, a rejected alternative, and a condition that would make us change our minds. If you want to change one, open an issue that says which condition has changed.

| Decision | Why | Rejected | What would change it |
| --- | --- | --- | --- |
| Bookings are time ranges on a 30 min grid | One row per booking; any length on the grid; overlap is one constraint | Pre-generated slot rows per room per day (300 rooms x 30 slots x 14 days to maintain; grid changes need a migration) | Never needing variable lengths |
| Overlap rule enforced by a database exclusion constraint | Correct under any concurrency, any number of service copies, any bug | Check-then-insert in code (race between check and insert); a lock in Redis (extra part, and still not the source of truth) | Moving off PostgreSQL |
| Availability derived, not stored | One source of truth; 300 rooms make the query cheap | A stored availability table (two truths that drift) | Search p95 over 1 s with tens of thousands of rooms |
| Search reads from a read replica, up to 5 s stale | Requirement allows it; keeps search load off the primary | A cache layer (not needed at 300 rooms) | p95 over 1 s at peak: add a short-lived cache |
| One service, not microservices | Smallest thing; one team; one deploy | Separate search, booking and notification services | Separate teams or very different scaling needs |
| Idempotency key stored on the booking | Makes retries and double clicks safe at the source | Relying on the app disabling the button (fails on network retries) | None foreseen |
| Notifications via an outbox table and worker | Written in the same transaction as the booking, so none are lost; no broker to run | A message broker (another stateful part) | Volume beyond what one worker can poll |
| In-app check-in to detect no-shows | No hardware; works on day one | Door QR codes or sensors (cost, installation) | Abuse: students checking in from elsewhere |
| Cancelled bookings kept as a status | Audit, limits, penalties and Just released all need them | Hard delete | Retention policy requires purging after a set period |
| "One booking per student per room" means one **active** booking per room | Most literal reading that still lets students return to a room later | One booking per room ever; one booking at a time across all rooms | Product owner reads it differently |
| Weekly limit counted by booking start, Monday to Sunday campus time; cancelled excluded | Predictable for students; cancelling should not be punished | Rolling 7 days | Students gaming week boundaries |

## The rule for adding complexity

Start simple. Add complexity only when a requirement justifies it. Every addition is stated as:

> We are adding ___ because ___ is measured or estimated at ___, and it costs us ___.
