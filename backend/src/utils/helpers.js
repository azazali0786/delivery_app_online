class Helpers {
  static formatDate(date) {
    return new Date(date).toISOString().split('T')[0];
  }

  static getCurrentDate() {
    return new Date().toISOString().split('T')[0];
  }

  static validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
  }

  static validatePhone(phone) {
    const re = /^[0-9]{10}$/;
    return re.test(phone);
  }

  static generatePassword(length = 8) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let password = '';
    for (let i = 0; i < length; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
  }

  static calculatePendingAmount(entries) {
    return entries.reduce((total, entry) => {
      return total + (entry.milk_quantity * entry.rate - entry.collected_money);
    }, 0);
  }
}

module.exports = Helpers;