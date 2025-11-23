const express = require('express');
const router = express.Router();
const EntryController = require('../controllers/entry.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// Apply authentication middleware
router.use(authenticateToken);

// Entry routes
router.get('/:id', EntryController.getEntryById);

module.exports = router;