# Conformance cases (steps 2 to 9)

Step 1 is checked with plain SQL. Steps 2 to 9 are checked through HTTP, so the same cases work against a service written in any language.

## The idea

A conformance case is a request and the response it must get, written in a tool that speaks HTTP and not any programming language. The cases read the base URL from a variable, so you point them at your service on `http://localhost:8000` and run them.

The tool is not fixed yet. [Hurl](https://hurl.dev) is the leading candidate because cases are plain text files and run from one binary. Other options are welcome through an issue.

## What a case looks like (sketch)

```
# T-R6: overlapping booking is refused
POST {{base_url}}/bookings
Authorization: Bearer {{token_student_b}}
Idempotency-Key: {{new_uuid}}
{ "room_id": "{{room_a}}", "start": "...", "end": "..." }

HTTP 409
[Asserts]
jsonpath "$.error" == "SLOT_TAKEN"
```

## How to contribute a case

1. Pick a test from [`../acceptance/acceptance-tests.yaml`](../acceptance/acceptance-tests.yaml) that has no case yet.
2. Write one file per test, named by its id (`T-R6.hurl`).
3. Check it fails against a service that breaks the rule, and passes against one that keeps it.
4. Open a pull request. See [CONTRIBUTING.md](../../CONTRIBUTING.md).

Cases that need a controllable clock (check-in window, no-show sweep, reminders) need a way to set "now". Proposals for a standard, language-free way to do that are very welcome.
