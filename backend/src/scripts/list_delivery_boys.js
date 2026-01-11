const { pool } = require('../config/database');

(async () => {
    try {
        const res = await pool.query('SELECT id, name, email, is_active FROM delivery_boys ORDER BY id LIMIT 20');
        console.log(res.rows);
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
})();