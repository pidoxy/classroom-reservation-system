-- Rule 2  A student has at most one active booking per room.
-- A cancelled booking does not count: the rule applies only while status is active
-- (CONFIRMED or CHECKED_IN), so the student can return to the room later.

DO $$
DECLARE
  room constant uuid := '00000000-0000-4000-8000-0000000000a1';
  refused boolean := false;
BEGIN
  INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
  VALUES (room, 'T-STUDENT-0',
          tstzrange('2030-01-02 10:00+00', '2030-01-02 11:00+00', '[)'),
          'rule-2', 'CONFIRMED', gen_random_uuid());

  BEGIN
    INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
    VALUES (room, 'T-STUDENT-0',
            tstzrange('2030-01-03 10:00+00', '2030-01-03 11:00+00', '[)'),
            'rule-2', 'CONFIRMED', gen_random_uuid());
  EXCEPTION WHEN unique_violation THEN
    refused := true;
  END;

  IF NOT refused THEN
    DELETE FROM bookings WHERE room_id = room;
    RAISE EXCEPTION 'FAIL rule 2: a second active booking for the same student and room was accepted';
  END IF;

  UPDATE bookings SET status = 'CANCELLED', cancelled_at = now() WHERE room_id = room;

  BEGIN
    INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
    VALUES (room, 'T-STUDENT-0',
            tstzrange('2030-01-03 10:00+00', '2030-01-03 11:00+00', '[)'),
            'rule-2', 'CONFIRMED', gen_random_uuid());
  EXCEPTION WHEN unique_violation THEN
    DELETE FROM bookings WHERE room_id = room;
    RAISE EXCEPTION 'FAIL rule 2: the unique index also counts cancelled bookings. It must apply only where status is active.';
  END;

  DELETE FROM bookings WHERE room_id = room;
  RAISE NOTICE 'PASS rule 2: one active booking per student per room, cancelled ones do not count';
END
$$;
