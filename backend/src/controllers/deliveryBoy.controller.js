const DeliveryBoyModel = require('../models/deliveryBoy.model');
const CustomerModel = require('../models/customer.model');
const EntryModel = require('../models/entry.model');
const StockModel = require('../models/stock.model');
const AreaModel = require('../models/area.model');
const ReasonModel = require('../models/reason.model');

class DeliveryBoyController {
  // Dashboard
  static async getDashboard(req, res, next) {
    try {
      const stats = await DeliveryBoyModel.getDashboardStats(req.user.id);
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }

  // Profile
  static async getProfile(req, res, next) {
    try {
      const deliveryBoy = await DeliveryBoyModel.findById(req.user.id);
      if (!deliveryBoy) {
        return res.status(404).json({ error: 'Profile not found' });
      }

      // Remove password from response
      delete deliveryBoy.password;

      // Get assigned sub-areas
      const subAreas = await DeliveryBoyModel.getAssignedSubAreas(req.user.id);
      deliveryBoy.assigned_sub_areas = subAreas;

      res.json(deliveryBoy);
    } catch (error) {
      next(error);
    }
  }

  // Customer Management
  static async createCustomer(req, res, next) {
    try {
      const customer = await CustomerModel.create(req.body, req.user.id);
      res.status(201).json(customer);
    } catch (error) {
      next(error);
    }
  }

  static async getCustomers(req, res, next) {
    try {
      const filters = {
        area_id: req.query.area_id,
        sub_area_id: req.query.sub_area_id,
        delivery_status: req.query.delivery_status,
        search: req.query.search
      };
      const customers = await CustomerModel.getByDeliveryBoy(req.user.id, filters);
      res.json(customers);
    } catch (error) {
      next(error);
    }
  }

  static async getCustomerById(req, res, next) {
    try {
      const customer = await CustomerModel.findById(req.params.id);
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }

      // Verify this customer's sub_area is assigned to this delivery boy
      const { pool } = require('../config/database');
      const assignmentCheck = await pool.query(
        'SELECT 1 FROM delivery_boy_subareas WHERE delivery_boy_id = $1 AND sub_area_id = $2',
        [req.user.id, customer.sub_area_id]
      );

      if (assignmentCheck.rows.length === 0) {
        return res.status(403).json({ error: 'Access denied' });
      }

      res.json(customer);
    } catch (error) {
      next(error);
    }
  }

  // Entry Management
  static async createEntry(req, res, next) {
    try {
      const entryData = {
        ...req.body,
        delivery_boy_id: req.user.id
      };

      const entry = await EntryModel.create(entryData);
      res.status(201).json(entry);
    } catch (error) {
      next(error);
    }
  }

  static async getEntries(req, res, next) {
    try {
      const date = req.query.date || null;
      const entries = await EntryModel.getByDeliveryBoy(req.user.id, date);
      res.json(entries);
    } catch (error) {
      next(error);
    }
  }

  static async getCustomerEntries(req, res, next) {
    try {
      const { start_date, end_date } = req.query;
      const entries = await CustomerModel.getCustomerEntries(
        req.params.customer_id,
        start_date,
        end_date
      );
      res.json(entries);
    } catch (error) {
      next(error);
    }
  }

  static async updateEntry(req, res, next) {
    try {
      const entry = await EntryModel.findById(req.params.id);
      if (!entry) {
        return res.status(404).json({ error: 'Entry not found' });
      }

      // Verify this entry belongs to this delivery boy
      if (entry.delivery_boy_id !== req.user.id) {
        return res.status(403).json({ error: 'Access denied' });
      }

      const updatedEntry = await EntryModel.update(req.params.id, req.body);
      res.json(updatedEntry);
    } catch (error) {
      next(error);
    }
  }

  static async markNotDelivered(req, res, next) {
    try {
      const { reason } = req.body;

      const entry = await EntryModel.findById(req.params.id);
      if (!entry) {
        return res.status(404).json({ error: 'Entry not found' });
      }

      if (entry.delivery_boy_id !== req.user.id) {
        return res.status(403).json({ error: 'Access denied' });
      }

      const updatedEntry = await EntryModel.update(req.params.id, {
        is_delivered: false,
        not_delivered_reason: reason
      });

      res.json(updatedEntry);
    } catch (error) {
      next(error);
    }
  }

  // Stock Management
  static async getStockEntries(req, res, next) {
    try {
      const { start_date, end_date } = req.query;
      const stockEntries = await StockModel.getByDeliveryBoy(
        req.user.id,
        start_date,
        end_date
      );
      res.json(stockEntries);
    } catch (error) {
      next(error);
    }
  }

  static async getTodayStock(req, res, next) {
    try {
      const stock = await StockModel.getTodayStock(req.user.id);
      res.json(stock || { half_ltr_bottles: 0, one_ltr_bottles: 0 });
    } catch (error) {
      next(error);
    }
  }

  // Areas
  static async getAssignedAreas(req, res, next) {
    try {
      const subAreas = await DeliveryBoyModel.getAssignedSubAreas(req.user.id);

      // Group by area
      const areaMap = {};
      subAreas.forEach(sa => {
        if (!areaMap[sa.area_id]) {
          areaMap[sa.area_id] = {
            id: sa.area_id,
            name: sa.area_name,
            sub_areas: []
          };
        }
        areaMap[sa.area_id].sub_areas.push({
          id: sa.sub_area_id,
          name: sa.sub_area_name
        });
      });

      res.json(Object.values(areaMap));
    } catch (error) {
      next(error);
    }
  }

  // Reasons
  static async getReasons(req, res, next) {
    try {
      const reasons = await ReasonModel.getAll();
      res.json(reasons);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = DeliveryBoyController;