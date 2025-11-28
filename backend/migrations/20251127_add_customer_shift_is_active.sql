-- Migration: add is_active and shift to customers
-- Run this against your PostgreSQL database (psql or any client)

BEGIN;

ALTER TABLE customers
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

ALTER TABLE customers
  ADD COLUMN IF NOT EXISTS shift VARCHAR(20);

-- Optional: set defaults for existing rows (customize as needed)
UPDATE customers SET is_active = true WHERE is_active IS NULL;
UPDATE customers SET shift = 'morning' WHERE shift IS NULL;

COMMIT;
