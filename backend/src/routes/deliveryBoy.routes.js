const express = require('express');
const router = express.Router();
const DeliveryBoyController = require('../controllers/deliveryBoy.controller');
const { authenticateToken, authenticateDeliveryBoy } = require('../middleware/auth.middleware');

// Apply authentication middleware to all delivery boy routes
router.use(authenticateToken);
router.use(authenticateDeliveryBoy);

// Dashboard
router.get('/dashboard', DeliveryBoyController.getDashboard);

// Profile
router.get('/profile', DeliveryBoyController.getProfile);

// Customer Management
router.post('/customers', DeliveryBoyController.createCustomer);
router.get('/customers', DeliveryBoyController.getCustomers);
router.get('/customers/:id', DeliveryBoyController.getCustomerById);

// Entry Management
router.post('/entries', DeliveryBoyController.createEntry);
router.get('/entries', DeliveryBoyController.getEntries);
router.get('/customers/:customer_id/entries', DeliveryBoyController.getCustomerEntries);
router.put('/entries/:id', DeliveryBoyController.updateEntry);
router.patch('/entries/:id/not-delivered', DeliveryBoyController.markNotDelivered);

// Stock Management
router.get('/stock-entries', DeliveryBoyController.getStockEntries);
router.get('/stock-entries/today', DeliveryBoyController.getTodayStock);

// Areas
router.get('/assigned-areas', DeliveryBoyController.getAssignedAreas);

// Reasons
router.get('/reasons', DeliveryBoyController.getReasons);

module.exports = router;