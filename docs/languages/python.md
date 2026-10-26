# Python guide

Everything you need to build this service in Python. The contract does not change: you are implementing [`spec/openapi.yaml`](../../spec/openapi.yaml) on top of the database from Step 1.

## Setup

You need Python 3.11 or newer and a running database (see the root [README](../../README.md)).

```bash
cd implementations/python
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python check_db.py
```

## Talking to the database

The starter uses [psycopg 3](https://www.psycopg.org/psycopg3/). The connection string comes from the `DATABASE_URL` environment variable, defaulting to the local throwaway database.

```python
import psycopg

with psycopg.connect(DATABASE_URL) as conn:
    row = conn.execute("select count(*) from rooms").fetchone()
```

Always use parameters, never string formatting:

```python
conn.execute("select * from bookings where student_id = %s", (student_id,))
```

## Catching the database's refusals

Step 3 turns database errors into the Brief's refusal codes. In psycopg the exclusion constraint raises `psycopg.errors.ExclusionViolation`, and the unique indexes raise `psycopg.errors.UniqueViolation`. Check which constraint fired (`err.diag.constraint_name`) to choose between `SLOT_TAKEN`, `ALREADY_BOOKED_THIS_ROOM` and an idempotent replay.

## Choosing a web framework

Any works. FastAPI gives you an OpenAPI document you can compare against [`spec/openapi.yaml`](../../spec/openapi.yaml). Flask and Django are fine. The standard library `http.server` is enough for a first pass. Your choice does not change the tests.

## Habits that help

- Format with `ruff format` and lint with `ruff check`.
- Test with `pytest` for your own unit tests. The repo's acceptance checks are separate and language-free.
- Keep SQL in files or constants you can read, not scattered through handlers.
- Keep settings (policy values) in the database, not in constants. Requirement R20 says changing the weekly limit needs no deploy.

## Working with an agent

See [working with agents](../working-with-agents.md).
