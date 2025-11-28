-- Migration: Change sort_number from INTEGER to NUMERIC(10,5)
-- Run this in pgAdmin or psql to update existing database

BEGIN;

-- Alter the column type
ALTER TABLE customers
  ALTER COLUMN sort_number TYPE NUMERIC(10, 5);

COMMIT;
