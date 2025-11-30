-- Migration: create expenses table
CREATE TABLE IF NOT EXISTS expenses (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  expense_date DATE NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW())
);
