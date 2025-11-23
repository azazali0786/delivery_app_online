const { pool } = require('../config/database');

class StockModel {
  static async create(data) {
    const result = await pool.query(`
      INSERT INTO stock_entries (
        delivery_boy_id, half_ltr_bottles, one_ltr_bottles,
        collected_bottles, entry_date
      ) VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [
      data.delivery_boy_id,
      data.half_ltr_bottles || 0,
      data.one_ltr_bottles || 0,
      data.collected_bottles || 0,
      data.entry_date || new Date().toISOString().split('T')[0]
    ]);
    
    return result.rows[0];
  }

  static async findById(id) {
    const result = await pool.query(`
      SELECT 
        se.*,
        db.name as delivery_boy_name
      FROM stock_entries se
      LEFT JOIN delivery_boys db ON se.delivery_boy_id = db.id
      WHERE se.id = $1
    `, [id]);
    return result.rows[0];
  }

  static async getByDeliveryBoy(deliveryBoyId, startDate = null, endDate = null) {
    let query = `
      SELECT * FROM stock_entries 
      WHERE delivery_boy_id = $1
    `;
    
    const params = [deliveryBoyId];
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

  static async getAll(filters = {}) {
    let query = `
      SELECT 
        se.*,
        db.name as delivery_boy_name
      FROM stock_entries se
      LEFT JOIN delivery_boys db ON se.delivery_boy_id = db.id
      WHERE 1=1
    `;
    
    const params = [];
    let paramCount = 1;

    if (filters.delivery_boy_id) {
      query += ` AND se.delivery_boy_id = $${paramCount}`;
      params.push(filters.delivery_boy_id);
      paramCount++;
    }

    if (filters.start_date) {
      query += ` AND se.entry_date >= $${paramCount}`;
      params.push(filters.start_date);
      paramCount++;
    }

    if (filters.end_date) {
      query += ` AND se.entry_date <= $${paramCount}`;
      params.push(filters.end_date);
      paramCount++;
    }

    query += ' ORDER BY se.entry_date DESC, se.created_at DESC';

    const result = await pool.query(query, params);
    return result.rows;
  }

  static async getTodayStock(deliveryBoyId) {
    const today = new Date().toISOString().split('T')[0];
    const result = await pool.query(
      'SELECT * FROM stock_entries WHERE delivery_boy_id = $1 AND entry_date = $2',
      [deliveryBoyId, today]
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
      UPDATE stock_entries 
      SET ${fields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query(
      'DELETE FROM stock_entries WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }
}

module.exports = StockModel;