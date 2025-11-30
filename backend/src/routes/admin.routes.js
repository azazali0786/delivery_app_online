const express = require('express');
const router = express.Router();
const AdminController = require('../controllers/admin.controller');
const { authenticateToken, authenticateAdmin } = require('../middleware/auth.middleware');

// Apply authentication middleware to all admin routes
router.use(authenticateToken);
router.use(authenticateAdmin);

// Dashboard
router.get('/dashboard', AdminController.getDashboard);
router.get('/dashboard/report', AdminController.getDashboardReport);

// Delivery Boy Management
router.post('/delivery-boys', AdminController.createDeliveryBoy);
router.get('/delivery-boys', AdminController.getAllDeliveryBoys);
router.put('/delivery-boys/:id', AdminController.updateDeliveryBoy);
router.delete('/delivery-boys/:id', AdminController.deleteDeliveryBoy);
router.patch('/delivery-boys/:id/toggle-active', AdminController.toggleDeliveryBoyActive);
router.post('/delivery-boys/assign-subareas', AdminController.assignSubAreas);

// Customer Management
router.post('/customers', AdminController.createCustomer);
router.get('/customers', AdminController.getAllCustomers);
router.put('/customers/:id', AdminController.updateCustomer);
router.delete('/customers/:id', AdminController.deleteCustomer);
router.get('/customers/pending-approvals', AdminController.getPendingApprovals);
router.post('/customers/:id/approve', AdminController.approveCustomer);

// Area Management
router.post('/areas', AdminController.createArea);
router.post('/sub-areas', AdminController.createSubArea);
router.get('/areas', AdminController.getAllAreas);
router.put('/areas/:id', AdminController.updateArea);
router.put('/sub-areas/:id', AdminController.updateSubArea);
router.delete('/areas/:id', AdminController.deleteArea);
router.delete('/sub-areas/:id', AdminController.deleteSubArea);

// Reasons Management
router.post('/reasons', AdminController.createReason);
router.get('/reasons', AdminController.getAllReasons);
router.put('/reasons/:id', AdminController.updateReason);
router.delete('/reasons/:id', AdminController.deleteReason);

// Stock Management
router.get('/stock-entries', AdminController.getAllStockEntries);
router.post('/stock-entries', AdminController.createStockEntry);
router.put('/stock-entries/:id', AdminController.updateStockEntry);
router.delete('/stock-entries/:id', AdminController.deleteStockEntry);

// Entry Management
router.get('/entries', AdminController.getAllEntries);
router.delete('/entries/:id', AdminController.deleteEntry);

// Expenses
router.post('/expenses', AdminController.createExpenses);
router.get('/expenses', AdminController.getExpenses);
router.delete('/expenses/by-date', AdminController.deleteExpensesByDate); // ← Move this line UP
router.put('/expenses/:id', AdminController.updateExpense);
router.delete('/expenses/:id', AdminController.deleteExpense);

// Invoice Generation
router.get('/invoice', AdminController.generateInvoice);

module.exports = router;