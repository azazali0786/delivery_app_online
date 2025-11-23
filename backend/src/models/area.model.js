const { pool } = require('../config/database');

class AreaModel {
  static async createArea(name) {
    const result = await pool.query(
      'INSERT INTO areas (name) VALUES ($1) RETURNING *',
      [name]
    );
    return result.rows[0];
  }

  static async createSubArea(areaId, name) {
    const result = await pool.query(
      'INSERT INTO sub_areas (area_id, name) VALUES ($1, $2) RETURNING *',
      [areaId, name]
    );
    return result.rows[0];
  }

  static async getAllAreas() {
    const result = await pool.query(`
      SELECT 
        a.*,
        COALESCE(
          json_agg(
            json_build_object(
              'id', sa.id,
              'name', sa.name,
              'created_at', sa.created_at
            ) ORDER BY sa.name
          ) FILTER (WHERE sa.id IS NOT NULL),
          '[]'
        ) as sub_areas
      FROM areas a
      LEFT JOIN sub_areas sa ON a.id = sa.area_id
      GROUP BY a.id
      ORDER BY a.name
    `);
    return result.rows;
  }

  static async getAreaById(id) {
    const result = await pool.query(
      'SELECT * FROM areas WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  static async getSubAreaById(id) {
    const result = await pool.query(`
      SELECT sa.*, a.name as area_name
      FROM sub_areas sa
      JOIN areas a ON sa.area_id = a.id
      WHERE sa.id = $1
    `, [id]);
    return result.rows[0];
  }

  static async getSubAreasByArea(areaId) {
    const result = await pool.query(
      'SELECT * FROM sub_areas WHERE area_id = $1 ORDER BY name',
      [areaId]
    );
    return result.rows;
  }

  static async updateArea(id, name) {
    const result = await pool.query(
      'UPDATE areas SET name = $1 WHERE id = $2 RETURNING *',
      [name, id]
    );
    return result.rows[0];
  }

  static async updateSubArea(id, name) {
    const result = await pool.query(
      'UPDATE sub_areas SET name = $1 WHERE id = $2 RETURNING *',
      [name, id]
    );
    return result.rows[0];
  }

  static async deleteArea(id) {
    const result = await pool.query(
      'DELETE FROM areas WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }

  static async deleteSubArea(id) {
    const result = await pool.query(
      'DELETE FROM sub_areas WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }
}

module.exports = AreaModel;