const express = require('express');
const router = express.Router();
const StockController = require('../controllers/stock.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// Apply authentication middleware
router.use(authenticateToken);

// Stock routes
router.get('/:id', StockController.getStockById);

module.exports = router;