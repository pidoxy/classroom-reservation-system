-- Step 1 fixtures. Safe to run repeatedly.
--
-- These rows exist only to give the step 1 tests something to book.
-- They use the column names in docs/schema-contract.md and fill every
-- column the Build Brief lists, so your schema may mark those NOT NULL.
-- Any column you add beyond the Brief must be nullable or have a default.

DELETE FROM bookings WHERE room_id = '00000000-0000-4000-8000-0000000000a1';

INSERT INTO buildings (building_id, name, zone, latitude, longitude)
VALUES ('T-BLD', 'Test Building', 'test', 6.5160, 3.3890)
ON CONFLICT DO NOTHING;

INSERT INTO rooms (room_id, code, building_id, name, type, capacity, opens_at, closes_at, is_active)
VALUES ('00000000-0000-4000-8000-0000000000a1', 'T-A1', 'T-BLD', 'Test Room A1',
        'study', 8, '08:00', '22:00', true)
ON CONFLICT DO NOTHING;

INSERT INTO students (student_id, email, display_name)
SELECT 'T-STUDENT-' || n, 't-student-' || n || '@example.test', 'Test Student ' || n
FROM generate_series(0, 49) AS n
ON CONFLICT DO NOTHING;
