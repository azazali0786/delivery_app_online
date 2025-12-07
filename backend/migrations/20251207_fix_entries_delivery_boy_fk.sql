-- Fix foreign key constraint for delivery_boy_id in entries table
-- Allow SET NULL so when a delivery boy is deleted, entries are preserved but delivery_boy_id becomes null

ALTER TABLE entries
DROP CONSTRAINT entries_delivery_boy_id_fkey;

ALTER TABLE entries
ADD CONSTRAINT entries_delivery_boy_id_fkey 
FOREIGN KEY (delivery_boy_id) 
REFERENCES delivery_boys(id) 
ON DELETE SET NULL;
