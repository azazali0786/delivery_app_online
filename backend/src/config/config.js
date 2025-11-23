module.exports = {
  port: process.env.PORT || 3000,
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'delivery_management',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',
    expiresIn: '30d',
  },
  admin: {
    email: process.env.ADMIN_EMAIL || 'azazwinner786@gmail.com',
    password: process.env.ADMIN_PASSWORD || 'Azaz@123',
  },
};