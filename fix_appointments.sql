-- Drop FK constraints on appointments that reference barber_profiles and customer_profiles
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT conname FROM pg_constraint
           WHERE conrelid = 'appointments'::regclass AND contype = 'f'
  LOOP
    EXECUTE 'ALTER TABLE appointments DROP CONSTRAINT "' || r.conname || '"';
  END LOOP;
END $$;

-- Change userId column from uuid to varchar to accept Firebase UIDs
ALTER TABLE appointments ALTER COLUMN "userId" TYPE varchar USING "userId"::varchar;
ALTER TABLE appointments ALTER COLUMN "userId" DROP NOT NULL;
