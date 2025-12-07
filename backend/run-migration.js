require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'delivery_management',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD ? process.env.DB_PASSWORD.replace(/"/g, '') : undefined,
});

async function runMigration() {
    try {
        console.log('Running migration to make sub_area_id nullable...');

        // Drop NOT NULL constraint
        await pool.query(`
      ALTER TABLE customers
      ALTER COLUMN sub_area_id DROP NOT NULL;
    `);

        console.log('✅ Migration completed successfully!');
        console.log('✅ sub_area_id column is now nullable');
        process.exit(0);
    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        process.exit(1);
    }
}

runMigration();
