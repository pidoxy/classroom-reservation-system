-- Rule 4  The end is after the start, and status is one of the allowed values.

DO $$
DECLARE
  room constant uuid := '00000000-0000-4000-8000-0000000000a1';
  empty_refused boolean := false;
  status_refused boolean := false;
BEGIN
  -- An empty range (start equals end) has no length and must be refused.
  BEGIN
    INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
    VALUES (room, 'T-STUDENT-0',
            tstzrange('2030-01-02 10:00+00', '2030-01-02 10:00+00', '[)'),
            'rule-4', 'CONFIRMED', gen_random_uuid());
  EXCEPTION WHEN check_violation THEN
    empty_refused := true;
  END;

  -- A status outside the allowed list must be refused (check constraint or enum).
  BEGIN
    INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
    VALUES (room, 'T-STUDENT-0',
            tstzrange('2030-01-02 10:00+00', '2030-01-02 11:00+00', '[)'),
            'rule-4', 'PENDING', gen_random_uuid());
  EXCEPTION WHEN check_violation OR invalid_text_representation THEN
    status_refused := true;
  END;

  DELETE FROM bookings WHERE room_id = room;

  IF NOT empty_refused THEN
    RAISE EXCEPTION 'FAIL rule 4: a booking with no length was accepted';
  END IF;
  IF NOT status_refused THEN
    RAISE EXCEPTION 'FAIL rule 4: the status PENDING was accepted';
  END IF;
  RAISE NOTICE 'PASS rule 4: end after start, and status limited to allowed values';
END
$$;
