-- Delete any reviews with null userId (shouldn't exist but clean up)
DELETE FROM reviews WHERE "userId" IS NULL;
-- Make userId nullable to avoid TypeORM sync issues
ALTER TABLE reviews ALTER COLUMN "userId" DROP NOT NULL;
