"""Connection check for the Python starter.

Run it to prove your Python can reach the database and see the Step 1 tables.
It does not build anything. Your service code goes next to it.

    python check_db.py
"""
import os
import sys

import psycopg

DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/reservations"
)
EXPECTED_TABLES = ["students", "buildings", "rooms", "bookings"]


def main() -> int:
    try:
        conn = psycopg.connect(DATABASE_URL, connect_timeout=5)
    except psycopg.OperationalError as err:
        print(f"Cannot connect: {err}")
        print("Is the database running? Try: ./scripts/db-up.sh")
        return 1

    with conn, conn.cursor() as cur:
        cur.execute("select version()")
        print(cur.fetchone()[0])
        cur.execute(
            "select table_name from information_schema.tables where table_schema = 'public'"
        )
        found = {row[0] for row in cur.fetchall()}

    missing = [t for t in EXPECTED_TABLES if t not in found]
    if missing:
        print(f"Connected. Step 1 tables not there yet: {', '.join(missing)}")
        print("That is expected before you finish Step 1. See docs/brief/build-order.md.")
    else:
        print("Connected. All Step 1 tables exist. Run ./scripts/check-step1.sh next.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
