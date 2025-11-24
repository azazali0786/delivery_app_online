const AdminModel = require('../models/admin.model');
const DeliveryBoyModel = require('../models/deliveryBoy.model');
const CustomerModel = require('../models/customer.model');
const AreaModel = require('../models/area.model');
const ReasonModel = require('../models/reason.model');
const StockModel = require('../models/stock.model');
const EntryModel = require('../models/entry.model');

class AdminController {
  // Dashboard
  static async getDashboard(req, res, next) {
    try {
      const stats = await AdminModel.getDashboardStats();
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }

  // Delivery Boy Management
  static async createDeliveryBoy(req, res, next) {
    try {
      const deliveryBoy = await DeliveryBoyModel.create(req.body);
      res.status(201).json(deliveryBoy);
    } catch (error) {
      if (error.code === '23505') {
        return res.status(400).json({ error: 'Email already exists' });
      }
      next(error);
    }
  }

  static async getAllDeliveryBoys(req, res, next) {
    try {
      const filters = {
        area_id: req.query.area_id,
        sub_area_id: req.query.sub_area_id,
        search: req.query.search
      };
      const deliveryBoys = await AdminModel.getAllDeliveryBoys(filters);
      res.json(deliveryBoys);
    } catch (error) {
      next(error);
    }
  }

  static async updateDeliveryBoy(req, res, next) {
    try {
      const deliveryBoy = await DeliveryBoyModel.update(req.params.id, req.body);
      if (!deliveryBoy) {
        return res.status(404).json({ error: 'Delivery boy not found' });
      }
      res.json(deliveryBoy);
    } catch (error) {
      next(error);
    }
  }

  static async deleteDeliveryBoy(req, res, next) {
    try {
      const deliveryBoy = await DeliveryBoyModel.delete(req.params.id);
      if (!deliveryBoy) {
        return res.status(404).json({ error: 'Delivery boy not found' });
      }
      res.json({ message: 'Delivery boy deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async toggleDeliveryBoyActive(req, res, next) {
    try {
      const deliveryBoy = await DeliveryBoyModel.toggleActive(req.params.id);
      if (!deliveryBoy) {
        return res.status(404).json({ error: 'Delivery boy not found' });
      }
      res.json(deliveryBoy);
    } catch (error) {
      next(error);
    }
  }

  static async assignSubAreas(req, res, next) {
    try {
      const { delivery_boy_id, sub_area_ids } = req.body;
      await DeliveryBoyModel.assignSubAreas(delivery_boy_id, sub_area_ids);
      res.json({ message: 'Sub-areas assigned successfully' });
    } catch (error) {
      next(error);
    }
  }

  // Customer Management
  static async createCustomer(req, res, next) {
    try {
      const customer = await CustomerModel.create(req.body);
      res.status(201).json(customer);
    } catch (error) {
      next(error);
    }
  }

  static async getAllCustomers(req, res, next) {
    try {
      const filters = {
        delivery_boy_id: req.query.delivery_boy_id,
        area_id: req.query.area_id,
        sub_area_id: req.query.sub_area_id,
        min_pending_money: req.query.min_pending_money,
        min_pending_bottles: req.query.min_pending_bottles,
        permanent_quantity_order: req.query.permanent_quantity_order,
        search: req.query.search
      };
      const customers = await AdminModel.getAllCustomers(filters);
      res.json(customers);
    } catch (error) {
      next(error);
    }
  }

  static async updateCustomer(req, res, next) {
    try {
      const customer = await CustomerModel.update(req.params.id, req.body);
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }
      res.json(customer);
    } catch (error) {
      next(error);
    }
  }

  static async deleteCustomer(req, res, next) {
    try {
      const customer = await CustomerModel.delete(req.params.id);
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }
      res.json({ message: 'Customer deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async getPendingApprovals(req, res, next) {
    try {
      const customers = await AdminModel.getPendingApprovals();
      res.json(customers);
    } catch (error) {
      next(error);
    }
  }

  static async approveCustomer(req, res, next) {
    try {
      const { sub_area_id, sort_number } = req.body;
      const customer = await AdminModel.approveCustomer(
        req.params.id,
        sub_area_id,
        sort_number
      );
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }
      res.json(customer);
    } catch (error) {
      next(error);
    }
  }

  // Area Management
  static async createArea(req, res, next) {
    try {
      const area = await AreaModel.createArea(req.body.name);
      res.status(201).json(area);
    } catch (error) {
      next(error);
    }
  }

  static async createSubArea(req, res, next) {
    try {
      const subArea = await AreaModel.createSubArea(req.body.area_id, req.body.name);
      res.status(201).json(subArea);
    } catch (error) {
      next(error);
    }
  }

  static async getAllAreas(req, res, next) {
    try {
      const areas = await AreaModel.getAllAreas();
      res.json(areas);
    } catch (error) {
      next(error);
    }
  }

  static async updateArea(req, res, next) {
    try {
      const area = await AreaModel.updateArea(req.params.id, req.body.name);
      if (!area) {
        return res.status(404).json({ error: 'Area not found' });
      }
      res.json(area);
    } catch (error) {
      next(error);
    }
  }

  static async updateSubArea(req, res, next) {
    try {
      const subArea = await AreaModel.updateSubArea(req.params.id, req.body.name);
      if (!subArea) {
        return res.status(404).json({ error: 'Sub-area not found' });
      }
      res.json(subArea);
    } catch (error) {
      next(error);
    }
  }

  static async deleteArea(req, res, next) {
    try {
      const area = await AreaModel.deleteArea(req.params.id);
      if (!area) {
        return res.status(404).json({ error: 'Area not found' });
      }
      res.json({ message: 'Area deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async deleteSubArea(req, res, next) {
    try {
      const subArea = await AreaModel.deleteSubArea(req.params.id);
      if (!subArea) {
        return res.status(404).json({ error: 'Sub-area not found' });
      }
      res.json({ message: 'Sub-area deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  // Reasons Management
  static async createReason(req, res, next) {
    try {
      const reason = await ReasonModel.create(req.body.reason);
      res.status(201).json(reason);
    } catch (error) {
      next(error);
    }
  }

  static async getAllReasons(req, res, next) {
    try {
      const reasons = await ReasonModel.getAll();
      res.json(reasons);
    } catch (error) {
      next(error);
    }
  }

  static async updateReason(req, res, next) {
    try {
      const reason = await ReasonModel.update(req.params.id, req.body.reason);
      if (!reason) {
        return res.status(404).json({ error: 'Reason not found' });
      }
      res.json(reason);
    } catch (error) {
      next(error);
    }
  }

  static async deleteReason(req, res, next) {
    try {
      const reason = await ReasonModel.delete(req.params.id);
      if (!reason) {
        return res.status(404).json({ error: 'Reason not found' });
      }
      res.json({ message: 'Reason deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  // Stock Management
  static async getAllStockEntries(req, res, next) {
    try {
      const filters = {
        delivery_boy_id: req.query.delivery_boy_id,
        start_date: req.query.start_date,
        end_date: req.query.end_date
      };
      const stockEntries = await StockModel.getAll(filters);
      res.json(stockEntries);
    } catch (error) {
      next(error);
    }
  }

  static async createStockEntry(req, res, next) {
    try {
      const stockEntry = await StockModel.create(req.body);
      res.status(201).json(stockEntry);
    } catch (error) {
      next(error);
    }
  }

  static async updateStockEntry(req, res, next) {
    try {
      const stockEntry = await StockModel.update(req.params.id, req.body);
      if (!stockEntry) {
        return res.status(404).json({ error: 'Stock entry not found' });
      }
      res.json(stockEntry);
    } catch (error) {
      next(error);
    }
  }

  static async deleteStockEntry(req, res, next) {
    try {
      const stockEntry = await StockModel.delete(req.params.id);
      if (!stockEntry) {
        return res.status(404).json({ error: 'Stock entry not found' });
      }
      res.json({ message: 'Stock entry deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  // Entries Management
  static async deleteEntry(req, res, next) {
    try {
      const entry = await EntryModel.delete(req.params.id);
      if (!entry) {
        return res.status(404).json({ error: 'Entry not found' });
      }
      res.json({ message: 'Entry deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  // Invoice Generation
  static async generateInvoice(req, res, next) {
    try {
      const { customer_id, start_date, end_date } = req.query;

      if (!customer_id) {
        return res.status(400).json({ error: 'Customer ID is required' });
      }

      // Get customer details
      const customer = await CustomerModel.findById(customer_id);
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }

      // Get entries for the customer within date range
      const entries = await EntryModel.getByCustomer(
        customer_id,
        start_date,
        end_date
      );

      // Calculate totals
      let totalMilk = 0;
      let totalCollected = 0;
      let totalPending = 0;

      entries.forEach(entry => {
        totalMilk += parseFloat(entry.milk_quantity || 0);
        totalCollected += parseFloat(entry.collected_money || 0);
        totalPending += parseFloat((entry.milk_quantity || 0) * (entry.rate || 0) - (entry.collected_money || 0));
      });

      const invoiceData = {
        customer_name: customer.name,
        customer_phone: customer.phone_number,
        customer_address: customer.address,
        period_start: start_date || 'N/A',
        period_end: end_date || 'N/A',
        entries: entries.map(e => ({
          date: e.entry_date,
          milk_quantity: e.milk_quantity,
          rate: e.rate,
          collected: e.collected_money,
          payment_method: e.payment_method,
          is_delivered: e.is_delivered
        })),
        total_milk: totalMilk,
        total_collected: totalCollected,
        total_pending: totalPending.toFixed(2),
        generated_date: new Date().toISOString().split('T')[0]
      };

      res.json(invoiceData);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AdminController;