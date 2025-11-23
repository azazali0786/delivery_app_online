const { pool } = require('../config/database');

class EntryModel {
  static async create(data) {
    const result = await pool.query(`
      INSERT INTO entries (
        customer_id, delivery_boy_id, milk_quantity, collected_money,
        pending_bottles, rate, payment_method, transaction_photo,
        is_delivered, not_delivered_reason, entry_date
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *
    `, [
      data.customer_id,
      data.delivery_boy_id,
      data.milk_quantity || 0,
      data.collected_money || 0,
      data.pending_bottles || 0,
      data.rate || 0,
      data.payment_method || 'cash',
      data.transaction_photo || null,
      data.is_delivered !== undefined ? data.is_delivered : true,
      data.not_delivered_reason || null,
      data.entry_date || new Date().toISOString().split('T')[0]
    ]);
    
    return result.rows[0];
  }

  static async findById(id) {
    const result = await pool.query(`
      SELECT 
        e.*,
        c.name as customer_name,
        c.phone_number as customer_phone,
        db.name as delivery_boy_name
      FROM entries e
      LEFT JOIN customers c ON e.customer_id = c.id
      LEFT JOIN delivery_boys db ON e.delivery_boy_id = db.id
      WHERE e.id = $1
    `, [id]);
    return result.rows[0];
  }

  static async getByCustomer(customerId, startDate = null, endDate = null) {
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

  static async getByDeliveryBoy(deliveryBoyId, date = null) {
    let query = `
      SELECT 
        e.*,
        c.name as customer_name,
        c.phone_number as customer_phone,
        c.address as customer_address
      FROM entries e
      LEFT JOIN customers c ON e.customer_id = c.id
      WHERE e.delivery_boy_id = $1
    `;
    
    const params = [deliveryBoyId];

    if (date) {
      query += ' AND e.entry_date = $2';
      params.push(date);
    }

    query += ' ORDER BY e.entry_date DESC, e.created_at DESC';

    const result = await pool.query(query, params);
    return result.rows;
  }

  static async getTodayEntry(customerId) {
    const today = new Date().toISOString().split('T')[0];
    const result = await pool.query(
      'SELECT * FROM entries WHERE customer_id = $1 AND entry_date = $2',
      [customerId, today]
    );
    return result.rows[0];
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
      UPDATE entries 
      SET ${fields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query(
      'DELETE FROM entries WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }
}

module.exports = EntryModel;