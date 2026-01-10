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

      // Debug logging: print start/end dates and the entry_date of each returned row
      // console.log(`getCustomerEntries called for customer ${req.params.id} start_date=${start_date} end_date=${end_date}`);
      // console.log('Returned entries dates:', entries.map(e => e.entry_date));

      // If a start_date was provided, compute opening balance and return both entries and opening balance
      if (start_date) {
        const openingBalance = await CustomerModel.getOpeningBalance(req.params.id, start_date);
        // console.log('Opening balance:', openingBalance);
        return res.json({ entries, opening_balance: parseFloat(openingBalance || 0) });
      }

      res.json(entries);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = CustomerController;