-- T-R6  Partial overlap.
-- Given an active booking 10:00 to 11:00 on room A,
-- when another student books A from 10:30 to 11:00,
-- then the database refuses it (exclusion violation) and one booking is stored.

DO $$
DECLARE
  room constant uuid := '00000000-0000-4000-8000-0000000000a1';
  refused boolean := false;
  stored integer;
BEGIN
  INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
  VALUES (room, 'T-STUDENT-0',
          tstzrange('2030-01-02 10:00+00', '2030-01-02 11:00+00', '[)'),
          'T-R6', 'CONFIRMED', gen_random_uuid());

  BEGIN
    INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
    VALUES (room, 'T-STUDENT-1',
            tstzrange('2030-01-02 10:30+00', '2030-01-02 11:00+00', '[)'),
            'T-R6', 'CONFIRMED', gen_random_uuid());
  EXCEPTION WHEN exclusion_violation THEN
    refused := true;
  END;

  SELECT count(*) INTO stored FROM bookings WHERE room_id = room;

  DELETE FROM bookings WHERE room_id = room;

  IF NOT refused THEN
    RAISE EXCEPTION 'FAIL T-R6: the overlapping booking was accepted. Expected an exclusion violation (SQLSTATE 23P01).';
  END IF;
  IF stored <> 1 THEN
    RAISE EXCEPTION 'FAIL T-R6: expected 1 stored booking, found %', stored;
  END IF;
  RAISE NOTICE 'PASS T-R6: partial overlap refused, 1 booking stored';
END
$$;
