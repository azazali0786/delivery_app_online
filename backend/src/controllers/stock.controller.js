const StockModel = require('../models/stock.model');

class StockController {
  static async getStockById(req, res, next) {
    try {
      const stock = await StockModel.findById(req.params.id);
      if (!stock) {
        return res.status(404).json({ error: 'Stock entry not found' });
      }
      
      // Check authorization
      if (req.user.role === 'delivery_boy' && stock.delivery_boy_id !== req.user.id) {
        return res.status(403).json({ error: 'Access denied' });
      }
      
      res.json(stock);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = StockController;