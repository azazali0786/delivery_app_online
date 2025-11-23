const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/auth.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// Login
router.post('/login', AuthController.login);

// Verify token
router.get('/verify', authenticateToken, AuthController.verifyToken);

module.exports = router;