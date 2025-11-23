const CustomerModel = require('../models/customer.model');

class CustomerController {
  static async getCustomerById(req, res, next) {
    try {
      const customer = await CustomerModel.findById(req.params.id);
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }
      
      // Check authorization
      if (req.user.role === 'delivery_boy' && customer.delivery_boy_id !== req.user.id) {
        return res.status(403).json({ error: 'Access denied' });
      }
      
      res.json(customer);
    } catch (error) {
      next(error);
    }
  }

  static async getCustomerEntries(req, res, next) {
    try {
      const { start_date, end_date } = req.query;
      
      // Verify access
      const customer = await CustomerModel.findById(req.params.id);
      if (!customer) {
        return res.status(404).json({ error: 'Customer not found' });
      }
      
      if (req.user.role === 'delivery_boy' && customer.delivery_boy_id !== req.user.id) {
        return res.status(403).json({ error: 'Access denied' });
      }
      
      const entries = await CustomerModel.getCustomerEntries(
        req.params.id,
        start_date,
        end_date
      );
      
      res.json(entries);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = CustomerController;