const { pool } = require('../config/database');

class ReasonModel {
  static async create(reason) {
    const result = await pool.query(
      'INSERT INTO reasons (reason) VALUES ($1) RETURNING *',
      [reason]
    );
    return result.rows[0];
  }

  static async getAll() {
    const result = await pool.query(
      'SELECT * FROM reasons ORDER BY created_at ASC'
    );
    return result.rows;
  }

  static async findById(id) {
    const result = await pool.query(
      'SELECT * FROM reasons WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  static async update(id, reason) {
    const result = await pool.query(
      'UPDATE reasons SET reason = $1 WHERE id = $2 RETURNING *',
      [reason, id]
    );
    return result.rows[0];
  }

  static async delete(id) {
    const result = await pool.query(
      'DELETE FROM reasons WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }
}

module.exports = ReasonModel;