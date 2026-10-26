# db/

Your database work lives here.

- `db/migrations/` is where your schema files go, applied in filename order (`001_schema.sql`, `002_policy.sql`, and so on). It starts empty on purpose: writing the Step 1 schema is the first thing you build.
- `./scripts/apply-schema.sh` applies every file in `db/migrations/` to the database.
- `./scripts/db-reset.sh` wipes the local database and starts clean. It refuses to run against anything that is not `localhost`.

The folder is mounted read-only into the Docker container at `/db`, so the container can read your files but never change them.

Do not put real credentials in any file here. The local database uses a throwaway `postgres` / `postgres` login that exists only on your machine.
