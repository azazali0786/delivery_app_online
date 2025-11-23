const EntryModel = require('../models/entry.model');

class EntryController {
  static async getEntryById(req, res, next) {
    try {
      const entry = await EntryModel.findById(req.params.id);
      if (!entry) {
        return res.status(404).json({ error: 'Entry not found' });
      }
      
      // Check authorization
      if (req.user.role === 'delivery_boy' && entry.delivery_boy_id !== req.user.id) {
        return res.status(403).json({ error: 'Access denied' });
      }
      
      res.json(entry);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = EntryController;