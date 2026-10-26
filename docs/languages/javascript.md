# JavaScript guide

Everything you need to build this service in JavaScript (Node). The contract does not change: you are implementing [`spec/openapi.yaml`](../../spec/openapi.yaml) on top of the database from Step 1.

## Setup

You need Node 20 or newer and a running database (see the root [README](../../README.md)).

```bash
cd implementations/javascript
npm install
npm run check-db
```

## Talking to the database

The starter uses [node-postgres](https://node-postgres.com) (`pg`). The connection string comes from the `DATABASE_URL` environment variable, defaulting to the local throwaway database.

```js
import pg from "pg";
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
const { rows } = await pool.query("select count(*) from rooms");
```

Always use parameters, never string concatenation:

```js
await pool.query("select * from bookings where student_id = $1", [studentId]);
```

## Catching the database's refusals

Step 3 turns database errors into the Brief's refusal codes. node-postgres errors carry a `code` and a `constraint`. The exclusion constraint is `23P01` (`exclusion_violation`) and unique indexes are `23505` (`unique_violation`). Check `err.constraint` to choose between `SLOT_TAKEN`, `ALREADY_BOOKED_THIS_ROOM` and an idempotent replay.

## Choosing a web framework

Any works. Express, Fastify and Hono are common choices. The built-in `node:http` module is enough for a first pass. Fastify can validate against a schema, which pairs well with [`spec/openapi.yaml`](../../spec/openapi.yaml). Your choice does not change the tests.

## Habits that help

- Format with Prettier and lint with ESLint.
- Test with the built-in runner (`node --test`) for your own unit tests. The repo's acceptance checks are separate and language-free.
- Use one connection per transaction from the pool, and always release it.
- Keep settings (policy values) in the database, not in constants. Requirement R20 says changing the weekly limit needs no deploy.

## Working with an agent

See [working with agents](../working-with-agents.md).
