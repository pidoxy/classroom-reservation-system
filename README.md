# Classroom Reservation System

A design you can build in any language. Students find a free study or seminar room, book it instantly, and cancel it, across about 300 rooms, with one hard promise: **no room is ever confirmed to two students for overlapping time.**

This repository holds the **contract**, not a solution. The Build Brief says what to build. A schema contract, an OpenAPI file and executable checks say how you will know it is right. You write the implementation in Python, JavaScript, or anything else, and the same checks judge all of them.

It began as a live design session in the AI for Software Engineering cohort at The AI Colony Academy, and is open to anyone who wants to practise building a real system step by step.

## Why it is language-agnostic

| Layer | Written in | Why |
| --- | --- | --- |
| The Brief | Markdown | Anyone can read it |
| The interface | [OpenAPI](spec/openapi.yaml) | Every language has tools for it |
| Policy values | [YAML](spec/policy.yaml) | Data, not code |
| The database | Plain SQL on PostgreSQL | The overlap rule lives in the database, so it holds whatever language sits on top |
| Acceptance tests | [YAML](tests/acceptance/acceptance-tests.yaml) | A list of what must be true |
| Step 1 checks | SQL and `pgbench`, run by bash scripts | No language needed |
| Later checks | HTTP cases ([planned](tests/conformance/README.md)) | Test the running service from outside |

## Quick start

You need Git and either Docker, or PostgreSQL 16 with its client tools (`psql`, `pgbench`).

```bash
git clone https://github.com/<owner>/classroom-reservation-system.git
cd classroom-reservation-system

./scripts/db-up.sh          # starts PostgreSQL 16 in Docker (skip if you run your own)
./scripts/check-step1.sh    # fails at first: you have not built Step 1 yet
```

The database login is a throwaway `postgres` / `postgres` that exists only on your machine. Nothing here needs a real secret.

If you use your own PostgreSQL, set `DATABASE_URL`, for example `postgresql://me:pw@localhost:5432/reservations`. You need the `btree_gist` extension available.

## Your first step

1. Read [docs/brief/README.md](docs/brief/README.md) and then [data model](docs/brief/data-model.md).
2. Read [docs/schema-contract.md](docs/schema-contract.md). It lists the tables, columns and four database rules your schema must hold.
3. Write your schema as SQL files in `db/migrations/` (`001_schema.sql`).
4. Apply it and check it:

   ```bash
   ./scripts/apply-schema.sh
   ./scripts/check-step1.sh
   ```

5. When it exits 0, Step 1 is done. Commit it. Move to Step 2 in [build order](docs/brief/build-order.md).

The checks include a race: 50 clients try to book the same room at once and exactly one must win. That run can take up to about 20 seconds. That is normal.

## Python

```bash
cd implementations/python
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python check_db.py
```

Guide: [docs/languages/python.md](docs/languages/python.md)

## JavaScript

```bash
cd implementations/javascript
npm install
npm run check-db
```

Guide: [docs/languages/javascript.md](docs/languages/javascript.md)

## Another language?

Go, Java, C#, Rust, Ruby, PHP, anything with a PostgreSQL driver and an HTTP server. You only need to honour the contract. Propose a starter with the [new language starter](.github/ISSUE_TEMPLATE/new-language-starter.md) issue.

## What is in here

```text
docs/
  brief/                 The Build Brief, in nine short files
  schema-contract.md     Tables and rules your Step 1 schema must hold
  languages/             Python and JavaScript guides
  working-with-agents.md Using an AI coding agent without losing control
  GUIDELINES.md          How this repository is organised and run
  implementations.md     Index of implementations
spec/                    openapi.yaml and policy.yaml
tests/
  step-1/                SQL and pgbench checks
  acceptance/            Acceptance tests as data
  conformance/           Language-free HTTP cases (to be contributed)
scripts/                 db-up, db-reset, apply-schema, check-step1
db/migrations/           Your schema goes here
implementations/         Starters: python, javascript
```

## The nine steps

| Step | What you build | Checked by |
| --- | --- | --- |
| 1 | Schema and constraints | `./scripts/check-step1.sh` |
| 2 | Auth hand-off and search | Conformance cases |
| 3 | Booking with policy checks and idempotency | Conformance cases |
| 4 | Cancel, my bookings, my standing | Conformance cases |
| 5 | Read replica for search | Conformance cases |
| 6 | Worker: check-in, no-shows, penalties | Conformance cases |
| 7 | Outbox and notifications | Conformance cases |
| 8 | Downtime and failure behaviour | Conformance cases |
| 9 | Load and drills | Load script |

Full detail in [docs/brief/build-order.md](docs/brief/build-order.md).

## Building with an AI agent

Encouraged, with one rule: the agent is never the judge, the checks are. Read [docs/working-with-agents.md](docs/working-with-agents.md). There is deliberately no agent rules file in this repo. In Week 5 of the cohort you write your own.

## Contributing and collaborating

Everyone is welcome: fix a typo, report a Brief problem, write a conformance case, add a language, or review someone's work.

- Start with [CONTRIBUTING.md](CONTRIBUTING.md).
- Repository rules are in [docs/GUIDELINES.md](docs/GUIDELINES.md).
- Be kind: [Code of Conduct](CODE_OF_CONDUCT.md).
- Share your implementation by adding a row to [docs/implementations.md](docs/implementations.md).

## Known notes

- The Brief says booking status has "six values" but lists five: `CONFIRMED`, `CANCELLED`, `CHECKED_IN`, `NO_SHOW`, `COMPLETED`. This repo uses the five. See [schema-contract.md](docs/schema-contract.md).
- The Docker fallback in the scripts is the least exercised path. If it misbehaves, open an issue.

## License

[MIT](LICENSE).
