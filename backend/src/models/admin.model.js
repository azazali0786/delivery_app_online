const { pool } = require('../config/database');

class AdminModel {
  static async findByEmail(email) {
    const result = await pool.query(
      'SELECT * FROM admins WHERE email = $1',
      [email]
    );
    return result.rows[0];
  }

  static async findById(id) {
    const result = await pool.query(
      'SELECT id, email, name, created_at FROM admins WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  static async getAllDeliveryBoys(filters = {}) {
    let query = `
      SELECT 
        db.*,
        COALESCE(
          json_agg(
            DISTINCT jsonb_build_object(
              'sub_area_id', sa.id,
              'sub_area_name', sa.name,
              'area_id', a.id,
              'area_name', a.name
            )
          ) FILTER (WHERE sa.id IS NOT NULL),
          '[]'
        ) as sub_areas
      FROM delivery_boys db
      LEFT JOIN delivery_boy_subareas dbs ON db.id = dbs.delivery_boy_id
      LEFT JOIN sub_areas sa ON dbs.sub_area_id = sa.id
      LEFT JOIN areas a ON sa.area_id = a.id
      WHERE 1=1
    `;
    
    const params = [];
    let paramCount = 1;

    if (filters.area_id) {
      query += ` AND a.id = $${paramCount}`;
      params.push(filters.area_id);
      paramCount++;
    }

    if (filters.sub_area_id) {
      query += ` AND sa.id = $${paramCount}`;
      params.push(filters.sub_area_id);
      paramCount++;
    }

    if (filters.search) {
      query += ` AND (db.name ILIKE $${paramCount} OR db.address ILIKE $${paramCount})`;
      params.push(`%${filters.search}%`);
      paramCount++;
    }

    query += ' GROUP BY db.id ORDER BY db.created_at DESC';

    const result = await pool.query(query, params);
    return result.rows;
  }

  static async getAllCustomers(filters = {}) {
    let query = `
      SELECT 
        c.*,
        sa.name as sub_area_name,
        a.name as area_name,
        db.name as delivery_boy_name,
        COALESCE(
          (SELECT SUM(e.milk_quantity * e.rate - e.collected_money) 
           FROM entries e 
           WHERE e.customer_id = c.id),
          0
        ) as total_pending_money,
        COALESCE(
          (SELECT e.pending_bottles 
           FROM entries e 
           WHERE e.customer_id = c.id 
           ORDER BY e.entry_date DESC 
           LIMIT 1),
          0
        ) as last_time_pending_bottles
      FROM customers c
      LEFT JOIN sub_areas sa ON c.sub_area_id = sa.id
      LEFT JOIN areas a ON sa.area_id = a.id
      LEFT JOIN delivery_boys db ON c.delivery_boy_id = db.id
      WHERE c.is_approved = true
    `;

    const params = [];
    let paramCount = 1;

    if (filters.delivery_boy_id) {
      query += ` AND c.delivery_boy_id = $${paramCount}`;
      params.push(filters.delivery_boy_id);
      paramCount++;
    }

    if (filters.area_id) {
      query += ` AND a.id = $${paramCount}`;
      params.push(filters.area_id);
      paramCount++;
    }

    if (filters.sub_area_id) {
      query += ` AND c.sub_area_id = $${paramCount}`;
      params.push(filters.sub_area_id);
      paramCount++;
    }

    if (filters.min_pending_money) {
      query += ` AND (SELECT SUM(e.milk_quantity * e.rate - e.collected_money) 
                      FROM entries e 
                      WHERE e.customer_id = c.id) > $${paramCount}`;
      params.push(filters.min_pending_money);
      paramCount++;
    }

    if (filters.min_pending_bottles) {
      query += ` AND (SELECT e.pending_bottles 
                      FROM entries e 
                      WHERE e.customer_id = c.id 
                      ORDER BY e.entry_date DESC 
                      LIMIT 1) > $${paramCount}`;
      params.push(filters.min_pending_bottles);
      paramCount++;
    }

    if (filters.search) {
      query += ` AND (c.name ILIKE $${paramCount} OR c.phone_number ILIKE $${paramCount})`;
      params.push(`%${filters.search}%`);
      paramCount++;
    }

    if (filters.permanent_quantity_order) {
      query += ` ORDER BY c.permanent_quantity ${filters.permanent_quantity_order === 'asc' ? 'ASC' : 'DESC'}`;
    } else {
      query += ' ORDER BY c.sort_number ASC, c.created_at DESC';
    }

    const result = await pool.query(query, params);
    return result.rows;
  }

  static async getPendingApprovals() {
    const result = await pool.query(`
      SELECT 
        c.*,
        db.name as delivery_boy_name
      FROM customers c
      LEFT JOIN delivery_boys db ON c.delivery_boy_id = db.id
      WHERE c.pending_approval = true AND c.is_approved = false
      ORDER BY c.created_at DESC
    `);
    return result.rows;
  }

  // Add this method to your AdminModel class in admin.model.js

static async getAllEntries(filters = {}) {
  let query = `
    SELECT 
      e.*,
      c.name as customer_name,
      c.phone_number as customer_phone,
      c.address as customer_address,
      db.id as delivery_boy_id,
      db.name as delivery_boy_name,
      sa.name as sub_area_name,
      a.name as area_name
    FROM entries e
    LEFT JOIN customers c ON e.customer_id = c.id
    LEFT JOIN delivery_boys db ON c.delivery_boy_id = db.id
    LEFT JOIN sub_areas sa ON c.sub_area_id = sa.id
    LEFT JOIN areas a ON sa.area_id = a.id
    WHERE 1=1
  `;

  const params = [];
  let paramCount = 1;

  if (filters.delivery_boy_id) {
    query += ` AND c.delivery_boy_id = $${paramCount}`;
    params.push(filters.delivery_boy_id);
    paramCount++;
  }

  if (filters.customer_id) {
    query += ` AND e.customer_id = $${paramCount}`;
    params.push(filters.customer_id);
    paramCount++;
  }

  if (filters.date) {
    query += ` AND e.entry_date = $${paramCount}`;
    params.push(filters.date);
    paramCount++;
  }

  if (filters.start_date) {
    query += ` AND e.entry_date >= $${paramCount}`;
    params.push(filters.start_date);
    paramCount++;
  }

  if (filters.end_date) {
    query += ` AND e.entry_date <= $${paramCount}`;
    params.push(filters.end_date);
    paramCount++;
  }

  if (filters.payment_method) {
    query += ` AND e.payment_method = $${paramCount}`;
    params.push(filters.payment_method);
    paramCount++;
  }

  if (filters.is_delivered !== undefined) {
    query += ` AND e.is_delivered = $${paramCount}`;
    params.push(filters.is_delivered);
    paramCount++;
  }

  query += ' ORDER BY e.entry_date DESC, e.created_at DESC';

  const result = await pool.query(query, params);
  return result.rows;
}

  static async approveCustomer(customerId, subAreaId, sortNumber) {
    const result = await pool.query(`
      UPDATE customers 
      SET is_approved = true, 
          pending_approval = false,
          sub_area_id = $2,
          sort_number = $3
      WHERE id = $1
      RETURNING *
    `, [customerId, subAreaId, sortNumber]);
    return result.rows[0];
  }

  static async getDashboardStats() {
    const totalDeliveryBoys = await pool.query(
      'SELECT COUNT(*) as count FROM delivery_boys WHERE is_active = true'
    );
    
    const totalCustomers = await pool.query(
      'SELECT COUNT(*) as count FROM customers WHERE is_approved = true'
    );
    
    const pendingApprovals = await pool.query(
      'SELECT COUNT(*) as count FROM customers WHERE pending_approval = true'
    );

    const totalPendingMoney = await pool.query(`
      SELECT COALESCE(SUM(milk_quantity * rate - collected_money), 0) as total
      FROM entries
    `);

    return {
      total_delivery_boys: parseInt(totalDeliveryBoys.rows[0].count),
      total_customers: parseInt(totalCustomers.rows[0].count),
      pending_approvals: parseInt(pendingApprovals.rows[0].count),
      total_pending_money: parseFloat(totalPendingMoney.rows[0].total)
    };
  }
}

module.exports = AdminModel;