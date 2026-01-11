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
    // Determine current period based on 2 PM cutoff
    const now = new Date();
    const todayDate = now.toISOString().split('T')[0]; // YYYY-MM-DD
    const cutoff = new Date(`${todayDate}T14:00:00`);
    const isEvening = now >= cutoff; // before 2pm -> morning (isEvening=false), after -> evening

    // Get stock entry for the appropriate period (latest before/after 2pm)
    // Use hour extraction to avoid timezone mismatches with ISO strings
    const stockQuery = isEvening
      ? `SELECT half_ltr_bottles, one_ltr_bottles FROM stock_entries WHERE delivery_boy_id = $1 AND DATE(entry_date) = $2 AND EXTRACT(HOUR FROM entry_date) >= 14 ORDER BY entry_date DESC LIMIT 1`
      : `SELECT half_ltr_bottles, one_ltr_bottles FROM stock_entries WHERE delivery_boy_id = $1 AND DATE(entry_date) = $2 AND EXTRACT(HOUR FROM entry_date) < 14 ORDER BY entry_date DESC LIMIT 1`;

    const stockResult = await pool.query(stockQuery, [deliveryBoyId, todayDate]);
    const stock = stockResult.rows[0] || { half_ltr_bottles: 0, one_ltr_bottles: 0 };

    // Get customers assigned to this delivery boy for the current period (include last pending and total pending money)
    const customersResult = await pool.query(`
      SELECT 
        c.id,
        c.permanent_quantity,
        COALESCE((SELECT SUM(e.milk_quantity * e.rate - e.collected_money) FROM entries e WHERE e.customer_id = c.id), 0) as total_pending_money,
        COALESCE((SELECT e.pending_bottles FROM entries e WHERE e.customer_id = c.id ORDER BY e.entry_date DESC LIMIT 1), 0) as last_time_pending_bottles
      FROM customers c
      WHERE c.sub_area_id IN (SELECT sub_area_id FROM delivery_boy_subareas WHERE delivery_boy_id = $1)
        AND c.is_approved = true AND c.is_active = true
        AND (c.shift IS NULL OR LOWER(c.shift) LIKE $2)
    `, [deliveryBoyId, isEvening ? '%e%' : '%m%']);
    const customers = customersResult.rows;

    // Calculate need (based on permanent_quantity) and total pending values
    let needHalf = 0;
    let needOne = 0;
    let totalPending = 0;
    let totalPendingBottles = 0;

    for (const c of customers) {
      const qty = parseFloat(c.permanent_quantity) || 0;
      needOne += Math.floor(qty);
      const rem = qty - Math.floor(qty);
      if (rem >= 0.5) needHalf += 1;

      totalPending += parseFloat(c.total_pending_money) || 0;
      totalPendingBottles += parseInt(c.last_time_pending_bottles) || 0;
    }

    // First: Get the last pending_bottles from before today for each customer
    const lastPendingBeforeTodayQuery = `
      SELECT e.customer_id, e.pending_bottles
      FROM entries e
      WHERE e.delivery_boy_id = $1
        AND DATE(e.entry_date) < $2
      ORDER BY e.entry_date DESC, e.created_at DESC
    `;
    const lastPendingResult = await pool.query(lastPendingBeforeTodayQuery, [deliveryBoyId, todayDate]);
    const lastPendingByCustomer = {};
    for (const row of lastPendingResult.rows) {
      if (!lastPendingByCustomer[row.customer_id]) {
        lastPendingByCustomer[row.customer_id] = row.pending_bottles;
      }
    }

    // Fetch entries for this delivery boy for today and limited to the chosen period
    const entriesQuery = `
      SELECT e.*
      FROM entries e
      WHERE e.delivery_boy_id = $1
        AND DATE(e.entry_date) = $2
        AND (${isEvening ? "EXTRACT(HOUR FROM e.created_at) >= 14" : "EXTRACT(HOUR FROM e.created_at) < 14"})
      ORDER BY e.customer_id ASC, e.created_at ASC
    `;

    const entriesResult = await pool.query(entriesQuery, [deliveryBoyId, todayDate]);
    const entries = entriesResult.rows;

    // Track previous pending for each customer in today's entries
    const prevPendingByCustomer = {};
    for (const e of entries) {
      // Use yesterday's pending for first entry, else chain from previous entry today
      if (!prevPendingByCustomer[e.customer_id]) {
        prevPendingByCustomer[e.customer_id] = lastPendingByCustomer[e.customer_id] || 0;
      }
      e.prev_pending = prevPendingByCustomer[e.customer_id];
      prevPendingByCustomer[e.customer_id] = e.pending_bottles;
    }

    // Aggregations for assigned bottles, payments, and collected bottles
    let assignHalf = 0;
    let assignOne = 0;
    let todayOnline = 0;
    let todayCash = 0;
    let todayPending = 0;
    let todayBottles = 0;
    let todayCollectedBottles = 0;

    for (const e of entries) {
      const qty = parseFloat(e.milk_quantity) || 0;
      assignOne += Math.floor(qty);
      const rem = qty - Math.floor(qty);
      if (rem >= 0.5) assignHalf += 1;

      // bottles derived from quantity
      const bottlesFromQty = Math.floor(qty) + (rem >= 0.5 ? 1 : 0);
      todayBottles += bottlesFromQty;

      const pm = (e.payment_method || '').toLowerCase();
      if (pm === 'online') todayOnline += parseFloat(e.collected_money) || 0;
      else if (pm === 'cash') todayCash += parseFloat(e.collected_money) || 0;

      todayPending += (parseFloat(e.milk_quantity) || 0) * (parseFloat(e.rate) || 0) - (parseFloat(e.collected_money) || 0);

      const prevPending = parseInt(e.prev_pending) || 0;
      const currPending = parseInt(e.pending_bottles) || 0;
      const collectedForEntry = bottlesFromQty + prevPending - currPending;
      todayCollectedBottles += collectedForEntry > 0 ? collectedForEntry : 0;
    }

    // Left in market
    let leftHalf = needHalf - assignHalf;
    let leftOne = needOne - assignOne;
    if (leftHalf < 0) leftHalf = 0;
    if (leftOne < 0) leftOne = 0;

    const result = {
      half_ltr_bottles: stock.half_ltr_bottles || 0,
      one_ltr_bottles: stock.one_ltr_bottles || 0,
      need_half: needHalf,
      need_one: needOne,
      assign_half: assignHalf,
      assign_one: assignOne,
      left_half: leftHalf,
      left_one: leftOne,
      today_online: Number(todayOnline.toFixed(2)),
      today_cash: Number(todayCash.toFixed(2)),
      today_pending: Number(todayPending.toFixed(2)),
      total_pending: Number(totalPending.toFixed(2)),
      total_pending_bottles: totalPendingBottles,
      today_collected_bottles: todayCollectedBottles,
      today_bottles: todayBottles,
      period: isEvening ? 'evening' : 'morning'
    };

    return result;
  }
}

module.exports = DeliveryBoyModel;