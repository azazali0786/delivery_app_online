-- Migration: Remove transaction_photo column from entries table
-- Run this in pgAdmin or psql to remove the transaction_photo column

BEGIN;

ALTER TABLE entries
  DROP COLUMN IF EXISTS transaction_photo;

COMMIT;
