-- Remove delivery_boy_id from customers table
-- Customers should only be linked to sub_areas, not directly to delivery_boys
-- Delivery boys are linked to sub_areas, so they can see customers in their assigned sub_areas

-- Step 1: Drop the foreign key constraint on delivery_boy_id
ALTER TABLE customers
DROP CONSTRAINT IF EXISTS customers_delivery_boy_id_fkey;

-- Step 2: Drop the delivery_boy_id column if it exists
ALTER TABLE customers
DROP COLUMN IF EXISTS delivery_boy_id;

ALTER TABLE customers
ALTER COLUMN sub_area_id DROP NOT NULL;

CREATE INDEX IF NOT EXISTS idx_customers_sub_area_id ON customers(sub_area_id);

CREATE INDEX IF NOT EXISTS idx_entries_customer_id ON entries(customer_id);
CREATE INDEX IF NOT EXISTS idx_entries_delivery_boy_id ON entries(delivery_boy_id);
CREATE INDEX IF NOT EXISTS idx_entries_entry_date ON entries(entry_date);

CREATE INDEX IF NOT EXISTS idx_delivery_boy_subareas_delivery_boy_id ON delivery_boy_subareas(delivery_boy_id);
CREATE INDEX IF NOT EXISTS idx_delivery_boy_subareas_sub_area_id ON delivery_boy_subareas(sub_area_id);
