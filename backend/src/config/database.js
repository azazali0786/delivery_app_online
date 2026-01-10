const { Pool } = require('pg');
const config = require('./config');
const bcrypt = require('bcryptjs');

const pool = new Pool(config.database);

// Test database connection
pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('❌ Unexpected error on idle client', err);
  process.exit(-1);
});

// Initialize database tables
async function initializeDatabase() {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // Create admins table
    await client.query(`
      CREATE TABLE IF NOT EXISTS admins (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) DEFAULT 'Admin',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create areas table
    await client.query(`
      CREATE TABLE IF NOT EXISTS areas (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create sub_areas table
    await client.query(`
      CREATE TABLE IF NOT EXISTS sub_areas (
        id SERIAL PRIMARY KEY,
        area_id INTEGER REFERENCES areas(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create delivery_boys table
    await client.query(`
      CREATE TABLE IF NOT EXISTS delivery_boys (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        address TEXT,
        phone_number1 VARCHAR(20),
        phone_number2 VARCHAR(20),
        adhar_number VARCHAR(20),
        driving_licence_number VARCHAR(50),
        pan_number VARCHAR(20),
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create expenses table
    await client.query(`
      CREATE TABLE IF NOT EXISTS expenses (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        amount NUMERIC(12,2) NOT NULL DEFAULT 0,
        expense_date DATE NOT NULL,
        created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW())
      )
    `);

    // Create delivery_boy_subareas junction table
    await client.query(`
      CREATE TABLE IF NOT EXISTS delivery_boy_subareas (
        id SERIAL PRIMARY KEY,
        delivery_boy_id INTEGER REFERENCES delivery_boys(id) ON DELETE CASCADE,
        sub_area_id INTEGER REFERENCES sub_areas(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(delivery_boy_id, sub_area_id)
      )
    `);

    // Create customers table
    await client.query(`
      CREATE TABLE IF NOT EXISTS customers (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        phone_number VARCHAR(20) NOT NULL,
        address TEXT,
        whatsapp_number VARCHAR(20),
        location_link TEXT,
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        permanent_quantity DECIMAL(10, 2) DEFAULT 0,
        sub_area_id INTEGER REFERENCES sub_areas(id),
        sort_number NUMERIC(10, 5),
        is_approved BOOLEAN DEFAULT false,
        pending_approval BOOLEAN DEFAULT true,
        is_active BOOLEAN DEFAULT true,
        shift VARCHAR(20),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create entries table
    await client.query(`
      CREATE TABLE IF NOT EXISTS entries (
        id SERIAL PRIMARY KEY,
        customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
        delivery_boy_id INTEGER REFERENCES delivery_boys(id) ON DELETE SET NULL,
        milk_quantity DECIMAL(10, 2) DEFAULT 0,
        collected_money DECIMAL(10, 2) DEFAULT 0,
        pending_bottles INTEGER DEFAULT 0,
        rate DECIMAL(10, 2) DEFAULT 0,
        payment_method VARCHAR(20) DEFAULT 'cash',
        is_delivered BOOLEAN DEFAULT true,
        not_delivered_reason VARCHAR(255),
        entry_date DATE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create stock_entries table
    await client.query(`
      CREATE TABLE IF NOT EXISTS stock_entries (
        id SERIAL PRIMARY KEY,
        delivery_boy_id INTEGER REFERENCES delivery_boys(id) ON DELETE CASCADE,
        half_ltr_bottles INTEGER DEFAULT 0,
        one_ltr_bottles INTEGER DEFAULT 0,
        collected_bottles INTEGER DEFAULT 0,
        entry_date TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create reasons table
    await client.query(`
      CREATE TABLE IF NOT EXISTS reasons (
        id SERIAL PRIMARY KEY,
        reason TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Insert default admin if not exists
    const hashedPassword = await bcrypt.hash(config.admin.password, 10);
    await client.query(`
      INSERT INTO admins (email, password, name)
      VALUES ($1, $2, $3)
      ON CONFLICT (email) DO NOTHING
    `, [config.admin.email, hashedPassword, 'Admin']);

    // Insert default reasons if not exists
    const defaultReasons = [
      'Not present in home',
      'Customer refused',
      'Customer on vacation',
      'Gate locked',
      'Other'
    ];

    for (const reason of defaultReasons) {
      await client.query(`
        INSERT INTO reasons (reason)
        SELECT $1
        WHERE NOT EXISTS (SELECT 1 FROM reasons WHERE reason = $1)
      `, [reason]);
    }

    await client.query('COMMIT');
    console.log('✅ Database tables created successfully');
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error creating database tables:', error);
    throw error;
  } finally {
    client.release();
  }
}

module.exports = { pool, initializeDatabase };