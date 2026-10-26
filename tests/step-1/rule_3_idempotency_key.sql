-- Rule 3  One booking per (student_id, idempotency_key).

DO $$
DECLARE
  room constant uuid := '00000000-0000-4000-8000-0000000000a1';
  key constant uuid := '11111111-1111-4111-8111-111111111111';
  refused boolean := false;
BEGIN
  INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
  VALUES (room, 'T-STUDENT-0',
          tstzrange('2030-01-02 10:00+00', '2030-01-02 11:00+00', '[)'),
          'rule-3', 'CONFIRMED', key);

  BEGIN
    INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
    VALUES (room, 'T-STUDENT-0',
            tstzrange('2030-01-02 14:00+00', '2030-01-02 15:00+00', '[)'),
            'rule-3', 'CANCELLED', key);
  EXCEPTION WHEN unique_violation THEN
    refused := true;
  END;

  IF NOT refused THEN
    DELETE FROM bookings WHERE room_id = room;
    RAISE EXCEPTION 'FAIL rule 3: the same student and idempotency key created two bookings';
  END IF;

  -- A different student may use the same key value.
  INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
  VALUES (room, 'T-STUDENT-1',
          tstzrange('2030-01-02 12:00+00', '2030-01-02 13:00+00', '[)'),
          'rule-3', 'CONFIRMED', key);

  DELETE FROM bookings WHERE room_id = room;
  RAISE NOTICE 'PASS rule 3: one booking per student and idempotency key';
END
$$;
