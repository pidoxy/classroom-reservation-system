-- T-E5  Back to back.
-- Given a booking 10:00 to 11:00 on room A,
-- when another student books A from 11:00 to 12:00,
-- then it is accepted. Ranges are half-open, so the end of one is the start of the next.

DO $$
DECLARE
  room constant uuid := '00000000-0000-4000-8000-0000000000a1';
  stored integer;
BEGIN
  INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
  VALUES (room, 'T-STUDENT-0',
          tstzrange('2030-01-02 10:00+00', '2030-01-02 11:00+00', '[)'),
          'T-E5', 'CONFIRMED', gen_random_uuid());

  BEGIN
    INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
    VALUES (room, 'T-STUDENT-1',
            tstzrange('2030-01-02 11:00+00', '2030-01-02 12:00+00', '[)'),
            'T-E5', 'CONFIRMED', gen_random_uuid());
  EXCEPTION WHEN exclusion_violation THEN
    DELETE FROM bookings WHERE room_id = room;
    RAISE EXCEPTION 'FAIL T-E5: a back to back booking was refused. Use half-open ranges, [start, end).';
  END;

  SELECT count(*) INTO stored FROM bookings WHERE room_id = room;
  DELETE FROM bookings WHERE room_id = room;

  IF stored <> 2 THEN
    RAISE EXCEPTION 'FAIL T-E5: expected 2 stored bookings, found %', stored;
  END IF;
  RAISE NOTICE 'PASS T-E5: back to back bookings both accepted';
END
$$;
