const { pool } = require('../config/database');
const bcrypt = require('bcryptjs');

class DeliveryBoyModel {
  static async create(data) {
    const hashedPassword = await bcrypt.hash(data.password, 10);

    const result = await pool.query(`
      INSERT INTO delivery_boys (
        name, email, password, address, phone_number1, phone_number2,
        adhar_number, driving_licence_number, pan_number
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `, [
      data.name,
      data.email,
      hashedPassword,
      data.address,
      data.phone_number1,
      data.phone_number2,
      data.adhar_number,
      data.driving_licence_number,
      data.pan_number
    ]);

    return result.rows[0];
  }

  static async findByEmail(email) {
    const result = await pool.query(
      'SELECT * FROM delivery_boys WHERE email = $1',
      [email]
    );
    return result.rows[0];
  }

  static async findById(id) {
    const result = await pool.query(
      'SELECT * FROM delivery_boys WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  static async update(id, data) {
    const fields = [];
    const values = [];
    let paramCount = 1;

    Object.keys(data).forEach(key => {
      if (data[key] !== undefined && key !== 'id' && key !== 'password') {
        fields.push(`${key} = $${paramCount}`);
        values.push(data[key]);
        paramCount++;
      }
    });

    if (fields.length === 0) return null;

    values.push(id);
    const query = `
      UPDATE delivery_boys 
      SET ${fields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query(
      'DELETE FROM delivery_boys WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }

  static async toggleActive(id) {
    const result = await pool.query(`
      UPDATE delivery_boys 
      SET is_active = NOT is_active
      WHERE id = $1
      RETURNING *
    `, [id]);
    return result.rows[0];
  }

  static async assignSubAreas(deliveryBoyId, subAreaIds) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Remove existing assignments
      await client.query(
        'DELETE FROM delivery_boy_subareas WHERE delivery_boy_id = $1',
        [deliveryBoyId]
      );

      // Add new assignments
      for (const subAreaId of subAreaIds) {
        await client.query(`
          INSERT INTO delivery_boy_subareas (delivery_boy_id, sub_area_id)
          VALUES ($1, $2)
        `, [deliveryBoyId, subAreaId]);
      }

      await client.query('COMMIT');
      return true;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  static async getAssignedSubAreas(deliveryBoyId) {
    const result = await pool.query(`
      SELECT 
        sa.id as sub_area_id,
        sa.name as sub_area_name,
        a.id as area_id,
        a.name as area_name
      FROM delivery_boy_subareas dbs
      JOIN sub_areas sa ON dbs.sub_area_id = sa.id
      JOIN areas a ON sa.area_id = a.id
      WHERE dbs.delivery_boy_id = $1
    `, [deliveryBoyId]);
    return result.rows;
  }

  static async getDashboardStats(deliveryBoyId) {
    const today = new Date().toISOString().split('T')[0];

    // Get today's stock
    const stockResult = await pool.query(`
      SELECT half_ltr_bottles, one_ltr_bottles
      FROM stock_entries
      WHERE delivery_boy_id = $1 AND entry_date = $2
    `, [deliveryBoyId, today]);

    const stock = stockResult.rows[0] || { half_ltr_bottles: 0, one_ltr_bottles: 0 };

    // Get today's deliveries
    const deliveriesResult = await pool.query(`
      SELECT 
        COUNT(*) as total_deliveries,
        COALESCE(SUM(milk_quantity), 0) as total_milk,
        COALESCE(SUM(collected_money), 0) as total_collected_money,
        COALESCE(SUM(CASE WHEN is_delivered = false THEN milk_quantity ELSE 0 END), 0) as pending_deliveries
      FROM entries
      WHERE delivery_boy_id = $1 AND entry_date = $2
    `, [deliveryBoyId, today]);

    // Get total left bottles
    const bottlesResult = await pool.query(`
      SELECT COALESCE(SUM(pending_bottles), 0) as total_left_bottles
      FROM entries e
      WHERE e.delivery_boy_id = $1
      AND e.id IN (
        SELECT MAX(id) FROM entries GROUP BY customer_id
      )
    `, [deliveryBoyId]);

    return {
      half_ltr_bottles: stock.half_ltr_bottles,
      one_ltr_bottles: stock.one_ltr_bottles,
      total_milk_for_delivery: stock.half_ltr_bottles * 0.5 + stock.one_ltr_bottles,
      today_total_delivered: parseFloat(deliveriesResult.rows[0].total_milk),
      today_pending_delivery: parseFloat(deliveriesResult.rows[0].pending_deliveries),
      today_collected_money: parseFloat(deliveriesResult.rows[0].total_collected_money),
      total_left_bottles: parseInt(bottlesResult.rows[0].total_left_bottles)
    };
  }
}

module.exports = DeliveryBoyModel;