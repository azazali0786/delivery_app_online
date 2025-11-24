const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config/config');
const AdminModel = require('../models/admin.model');
const DeliveryBoyModel = require('../models/deliveryBoy.model');

class AuthController {
  static async login(req, res, next) {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }

      // Check if admin
      const admin = await AdminModel.findByEmail(email);
      if (admin) {
        const isValidPassword = await bcrypt.compare(password, admin.password);
        if (!isValidPassword) {
          return res.status(401).json({ error: 'Invalid credentials' });
        }

        const token = jwt.sign(
          { id: admin.id, email: admin.email, role: 'admin' },
          config.jwt.secret,
          { expiresIn: config.jwt.expiresIn }
        );

        return res.json({
          token,
          user: {
            id: admin.id,
            email: admin.email,
            name: admin.name,
            role: 'admin'
          }
        });
      }

      // Check if delivery boy
      const deliveryBoy = await DeliveryBoyModel.findByEmail(email);
      if (deliveryBoy) {
        if (!deliveryBoy.is_active) {
          return res.status(403).json({ error: 'Your account is inactive. Please contact admin.' });
        }

        const isValidPassword = await bcrypt.compare(password, deliveryBoy.password);
        if (!isValidPassword) {
          return res.status(401).json({ error: 'Invalid credentials' });
        }

        const token = jwt.sign(
          { id: deliveryBoy.id, email: deliveryBoy.email, role: 'delivery_boy' },
          config.jwt.secret,
          { expiresIn: config.jwt.expiresIn }
        );

        return res.json({
          token,
          user: {
            id: deliveryBoy.id,
            email: deliveryBoy.email,
            name: deliveryBoy.name,
            role: 'delivery_boy'
          }
        });
      }

      return res.status(401).json({ error: 'Invalid credentials' });
    } catch (error) {
      next(error);
    }
  }

  static async verifyToken(req, res, next) {
    try {
      const user = req.user;
      
      if (user.role === 'admin') {
        const admin = await AdminModel.findById(user.id);
        if (!admin) {
          return res.status(404).json({ error: 'User not found' });
        }
        return res.json({
          user: {
            id: admin.id,
            email: admin.email,
            name: admin.name,
            role: 'admin'
          }
        });
      } else {
        const deliveryBoy = await DeliveryBoyModel.findById(user.id);
        if (!deliveryBoy) {
          return res.status(404).json({ error: 'User not found' });
        }
        if (!deliveryBoy.is_active) {
          return res.status(403).json({ error: 'Your account is inactive' });
        }
        return res.json({
          user: {
            id: deliveryBoy.id,
            email: deliveryBoy.email,
            name: deliveryBoy.name,
            role: 'delivery_boy'
          }
        });
      }
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AuthController;