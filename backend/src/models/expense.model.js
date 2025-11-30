const { pool } = require('../config/database');

class ExpenseModel {
    static async create(expense) {
        const result = await pool.query(`
      INSERT INTO expenses (name, amount, expense_date)
      VALUES ($1, $2, $3)
      RETURNING *
    `, [expense.name, expense.amount, expense.expense_date]);
        return result.rows[0];
    }

    static async createMany(expenses) {
        if (!Array.isArray(expenses) || expenses.length === 0) return [];
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const inserted = [];
            for (const e of expenses) {
                const res = await client.query(`
          INSERT INTO expenses (name, amount, expense_date)
          VALUES ($1, $2, $3)
          RETURNING *
        `, [e.name, e.amount, e.expense_date]);
                inserted.push(res.rows[0]);
            }
            await client.query('COMMIT');
            return inserted;
        } catch (err) {
            await client.query('ROLLBACK');
            throw err;
        } finally {
            client.release();
        }
    }

    static async getByDateRange(startDate, endDate) {
        const params = [];
        let query = 'SELECT * FROM expenses WHERE 1=1';
        if (startDate) {
            params.push(startDate);
            query += ` AND expense_date >= $${params.length}`;
        }
        if (endDate) {
            params.push(endDate);
            query += ` AND expense_date <= $${params.length}`;
        }
        query += ' ORDER BY expense_date DESC, created_at DESC';
        const result = await pool.query(query, params);
        return result.rows;
    }

    static async getTotalAmount(startDate = null, endDate = null) {
        const params = [];
        let query = 'SELECT COALESCE(SUM(amount),0) as total FROM expenses WHERE 1=1';
        if (startDate) {
            params.push(startDate);
            query += ` AND expense_date >= $${params.length}`;
        }
        if (endDate) {
            params.push(endDate);
            query += ` AND expense_date <= $${params.length}`;
        }
        const result = await pool.query(query, params);
        return parseFloat(result.rows[0].total);
    }

    static async update(id, data) {
        const fields = [];
        const values = [];
        let idx = 1;
        if (data.name !== undefined) {
            fields.push(`name = $${idx++}`);
            values.push(data.name);
        }
        if (data.amount !== undefined) {
            fields.push(`amount = $${idx++}`);
            values.push(data.amount);
        }
        if (data.expense_date !== undefined) {
            fields.push(`expense_date = $${idx++}`);
            values.push(data.expense_date);
        }
        if (fields.length === 0) return null;
        values.push(id);
        const query = `UPDATE expenses SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    static async delete(id) {
        const result = await pool.query('DELETE FROM expenses WHERE id = $1 RETURNING *', [id]);
        return result.rows[0];
    }

    static async deleteByDate(date) {
        const result = await pool.query('DELETE FROM expenses WHERE expense_date = $1 RETURNING *', [date]);
        return result.rows;
    }
}

module.exports = ExpenseModel;
