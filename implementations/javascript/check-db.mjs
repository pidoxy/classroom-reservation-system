// Connection check for the JavaScript starter.
// Run it to prove your Node can reach the database and see the Step 1 tables.
// It does not build anything. Your service code goes next to it.
//
//   npm run check-db
import pg from "pg";

const connectionString =
  process.env.DATABASE_URL ?? "postgresql://postgres:postgres@localhost:5432/reservations";
const expected = ["students", "buildings", "rooms", "bookings"];

const client = new pg.Client({ connectionString, connectionTimeoutMillis: 5000 });

try {
  await client.connect();
} catch (err) {
  console.log(`Cannot connect: ${err.message}`);
  console.log("Is the database running? Try: ./scripts/db-up.sh");
  process.exit(1);
}

try {
  const version = await client.query("select version()");
  console.log(version.rows[0].version);
  const tables = await client.query(
    "select table_name from information_schema.tables where table_schema = 'public'"
  );
  const found = new Set(tables.rows.map((r) => r.table_name));
  const missing = expected.filter((t) => !found.has(t));
  if (missing.length) {
    console.log(`Connected. Step 1 tables not there yet: ${missing.join(", ")}`);
    console.log("That is expected before you finish Step 1. See docs/brief/build-order.md.");
  } else {
    console.log("Connected. All Step 1 tables exist. Run ./scripts/check-step1.sh next.");
  }
} finally {
  await client.end();
}
