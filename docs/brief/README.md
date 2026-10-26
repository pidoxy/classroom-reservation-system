# Build Brief: Classroom Reservation System

This is the written design that the cohort produced in a live design session (17 October 2026). It is precise enough that a person or an AI agent can build the system from it. Read it in order, or jump to the part you need.

| Part | What it answers |
| --- | --- |
| [Requirements](requirements.md) | What the system must do (R1 to R20) and the policy values |
| [Data model](data-model.md) | What is stored, how it links, and the rules the database always holds |
| [Interfaces](interfaces.md) | What each call takes, returns and refuses, plus quality targets |
| [Edge cases](edge-cases.md) | The awkward situations (E1 to E22) and what should happen |
| [System design](system-design.md) | The six parts and what each one owns |
| [Decisions](decisions.md) | What we chose, what we rejected, and why |
| [Acceptance tests](acceptance-tests.md) | How we know each requirement is met (T-R and T-E) |
| [Build order](build-order.md) | Nine steps, each finished with its tests passing |

## Purpose

A web and mobile service that lets the university's 30,000+ students find a free study or seminar room, book it instantly, and cancel it, across roughly 300 bookable rooms.

**Problem it solves.** Today students walk between buildings looking for empty rooms, two groups turn up for the same room, and rooms sit empty because someone reserved and never came.

**How we will know it works.**

- No room is ever confirmed to two students for overlapping time. Zero tolerance.
- Search answers in under one second for 95% of requests at peak load.
- A booking nobody checks in to is released within 15 minutes of its start, and other students can see and take it.
- Students get a reminder before every booking and a notice before planned downtime.

## Assumptions

- **A1.** University sign-in (SSO) exists. It issues a signed token carrying the student id. The service trusts that id and never accepts one from the request body.
- **A2.** The room catalogue (name, building, type, capacity, amenities, opening hours) comes from facilities data and is loaded by an import. Editing it is out of scope.
- **A3.** The campus uses one time zone. All rooms share it.
- **A4.** Proximity means distance between buildings, from a fixed table of building coordinates. No live GPS.
- **A5.** University email and app push are available as notification channels.
- **A6.** "Growth of 700 to 800 per year" means new students per year. Rooms grow slowly. *Open question: confirm whether this was rooms or bookings.*
- **A7.** Peak load estimate, to be confirmed with real data: about 50 searches and 5 booking writes per second during exam weeks.
- **A8.** Students are adults with one account each. Group bookings are made by one student on behalf of the group.

## Out of scope

Payments, approvals, recurring bookings, admin tools (room catalogue editing, overrides, reports), staff and lecturer bookings, waitlists, penalty appeals, ending a booking early, and hardware check-in (door QR codes or sensors).

## Using the Brief with an AI agent

The Brief is written so it can be handed to an agent as context. See [working with AI agents](../working-with-agents.md) for how to scope a step, what to ask the agent to show you, and what to check before you accept its work.
