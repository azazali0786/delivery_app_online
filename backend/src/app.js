const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth.routes');
const adminRoutes = require('./routes/admin.routes');
const deliveryBoyRoutes = require('./routes/deliveryBoy.routes');
const customerRoutes = require('./routes/customer.routes');
const entryRoutes = require('./routes/entry.routes');
const stockRoutes = require('./routes/stock.routes');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();

// 👉 ADD THIS LINE (global counter object)
const apiCallCount = {};

// 👉 Request logger + counter middleware (put BEFORE routes)
app.use((req, res, next) => {
  const key = `${req.method} ${req.originalUrl}`;

  if (!apiCallCount[key]) {
    apiCallCount[key] = 0;
  }
  apiCallCount[key]++;

  console.log(`${key} → ${apiCallCount[key]} calls`);

  next();
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/delivery-boy', deliveryBoyRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/entries', entryRoutes);
app.use('/api/stock', stockRoutes);

// (optional) Debug route to see counts in browser/postman
app.get('/api/debug/api-calls', (req, res) => {
  res.json(apiCallCount);
});

// Temporary: Debug delivery boy dashboard by id (UNPROTECTED) — remove in production
const DeliveryBoyModel = require('./models/deliveryBoy.model');
app.get('/api/debug/delivery-boy/:id/dashboard', async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    const stats = await DeliveryBoyModel.getDashboardStats(id);
    res.json(stats);
  } catch (err) {
    next(err);
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use(errorHandler);

module.exports = app;
