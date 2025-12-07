-- Fix foreign key constraint for delivery_boy_id in customers table
-- Allow cascading delete so when a delivery boy is deleted, customers are either deleted or reassigned

ALTER TABLE customers
DROP CONSTRAINT customers_delivery_boy_id_fkey;

ALTER TABLE customers
ADD CONSTRAINT customers_delivery_boy_id_fkey 
FOREIGN KEY (delivery_boy_id) 
REFERENCES delivery_boys(id) 
ON DELETE SET NULL;
