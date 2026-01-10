-- Migration: Change stock_entries.entry_date from DATE to TIMESTAMP
BEGIN;

ALTER TABLE stock_entries
  ALTER COLUMN entry_date TYPE TIMESTAMP USING entry_date::timestamp;

COMMIT;
