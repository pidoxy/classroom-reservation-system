-- Rule 1, second half  Only ACTIVE bookings block a slot.
-- When a booking is cancelled (or becomes NO_SHOW or COMPLETED) the time is free again,
-- so the no-overlap constraint must apply only where status is CONFIRMED or CHECKED_IN.

DO $$
DECLARE
  room constant uuid := '00000000-0000-4000-8000-0000000000a1';
  final_status text;
BEGIN
  FOREACH final_status IN ARRAY ARRAY['CANCELLED', 'NO_SHOW', 'COMPLETED'] LOOP
    INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
    VALUES (room, 'T-STUDENT-0',
            tstzrange('2030-01-02 10:00+00', '2030-01-02 11:00+00', '[)'),
            'rule-1', 'CONFIRMED', gen_random_uuid());

    UPDATE bookings SET status = final_status WHERE room_id = room;

    BEGIN
      INSERT INTO bookings (room_id, student_id, during, purpose, status, idempotency_key)
      VALUES (room, 'T-STUDENT-1',
              tstzrange('2030-01-02 10:00+00', '2030-01-02 11:00+00', '[)'),
              'rule-1', 'CONFIRMED', gen_random_uuid());
    EXCEPTION WHEN exclusion_violation THEN
      DELETE FROM bookings WHERE room_id = room;
      RAISE EXCEPTION 'FAIL rule 1: a % booking still blocks its slot. The exclusion constraint must apply only where status is CONFIRMED or CHECKED_IN.', final_status;
    END;

    DELETE FROM bookings WHERE room_id = room;
  END LOOP;
  RAISE NOTICE 'PASS rule 1: cancelled, no-show and completed bookings free their slot';
END
$$;
