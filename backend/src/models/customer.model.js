const { pool } = require('../config/database');

class CustomerModel {
  static async create(data, createdBy = null) {
    const result = await pool.query(`
      INSERT INTO customers (
        name, phone_number, address, whatsapp_number, location_link,
        latitude, longitude, permanent_quantity, sub_area_id,
        sort_number, is_approved, pending_approval, is_active, shift
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING *
    `, [
      data.name,
      data.phone_number,
      data.address,
      data.whatsapp_number || null,
      data.location_link || null,
      data.latitude || null,
      data.longitude || null,
      data.permanent_quantity || 0,
      data.sub_area_id,
      data.sort_number ? parseFloat(data.sort_number) : null,
      false,
      true,
      data.is_active !== undefined ? data.is_active : true,
      data.shift || null
    ]);

    return result.rows[0];
  }

  static async findById(id) {
    const result = await pool.query(`
      SELECT 
        c.*,
        sa.name as sub_area_name,
        a.name as area_name,
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
      WHERE c.id = $1
    `, [id]);
    return result.rows[0];
  }

  static async getByDeliveryBoy(deliveryBoyId, filters = {}) {
    let query = `
      SELECT 
        c.*,
        sa.name as sub_area_name,
        a.name as area_name,
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
        ) as last_time_pending_bottles,
        COALESCE(
          (SELECT e.is_delivered 
           FROM entries e 
           WHERE e.customer_id = c.id 
           AND e.entry_date = CURRENT_DATE
           ORDER BY e.entry_date DESC 
           LIMIT 1),
          null
        ) as today_delivery_status
      FROM customers c
      LEFT JOIN sub_areas sa ON c.sub_area_id = sa.id
      LEFT JOIN areas a ON sa.area_id = a.id
      WHERE c.sub_area_id IN (
        SELECT sub_area_id FROM delivery_boy_subareas WHERE delivery_boy_id = $1
      ) AND c.is_approved = true AND c.is_active = true
    `;

    const params = [deliveryBoyId];
    let paramCount = 2;

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

    if (filters.delivery_status) {
      if (filters.delivery_status === 'delivered') {
        query += ` AND EXISTS (
          SELECT 1 FROM entries e 
          WHERE e.customer_id = c.id 
          AND e.entry_date = CURRENT_DATE 
          AND e.is_delivered = true
        )`;
      } else if (filters.delivery_status === 'pending') {
        query += ` AND NOT EXISTS (
          SELECT 1 FROM entries e 
          WHERE e.customer_id = c.id 
          AND e.entry_date = CURRENT_DATE
        )`;
      } else if (filters.delivery_status === 'notDelivered') {
        query += ` AND EXISTS (
          SELECT 1 FROM entries e 
          WHERE e.customer_id = c.id 
          AND e.entry_date = CURRENT_DATE 
          AND e.is_delivered = false
        )`;
      }
    }

    if (filters.search) {
      query += ` AND (c.name ILIKE $${paramCount} OR c.phone_number ILIKE $${paramCount})`;
      params.push(`%${filters.search}%`);
      paramCount++;
    }

    query += ' ORDER BY c.sort_number ASC, c.created_at DESC';

    const result = await pool.query(query, params);
    return result.rows;
  }

  static async update(id, data) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.keys(data).forEach(key => {
      if (data[key] !== undefined && key !== 'id') {
        fields.push(`${key} = $${paramCount}`);
        values.push(data[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) return null;

    values.push(id);
    const query = `
      UPDATE customers 
      SET ${fields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query(
      'DELETE FROM customers WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }

  static async getCustomerEntries(customerId, startDate = null, endDate = null) {
    let query = `
      SELECT * FROM entries 
      WHERE customer_id = $1
    `;

    const params = [customerId];
    let paramCount = 2;

    if (startDate) {
      query += ` AND entry_date >= $${paramCount}`;
      params.push(startDate);
      paramCount++;
    }

    if (endDate) {
      query += ` AND entry_date <= $${paramCount}`;
      params.push(endDate);
      paramCount++;
    }

    query += ' ORDER BY entry_date DESC';

    const result = await pool.query(query, params);
    return result.rows;
  }
}

module.exports = CustomerModel;