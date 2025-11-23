const express = require('express');
const router = express.Router();
const CustomerController = require('../controllers/customer.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// Apply authentication middleware
router.use(authenticateToken);

// Customer routes
router.get('/:id', CustomerController.getCustomerById);
router.get('/:id/entries', CustomerController.getCustomerEntries);

module.exports = router;