class ApiConstants {
  // Base URL - Change this to your backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Alternative for Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Alternative for physical device (use your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:3000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String verify = '/auth/verify';

  // Admin endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String deliveryBoys = '/admin/delivery-boys';
  static const String adminCustomers = '/admin/customers';
  static const String pendingApprovals = '/admin/customers/pending-approvals';
  static const String areas = '/admin/areas';
  static const String subAreas = '/admin/sub-areas';
  static const String reasons = '/admin/reasons';
  static const String stockEntries = '/admin/stock-entries';
  static const String adminEntries = '/admin/entries';
  static const String assignSubAreas = '/admin/delivery-boys/assign-subareas';

  // Delivery Boy endpoints
  static const String deliveryDashboard = '/delivery-boy/dashboard';
  static const String deliveryProfile = '/delivery-boy/profile';
  static const String deliveryCustomers = '/delivery-boy/customers';
  static const String deliveryEntries = '/delivery-boy/entries';
  static const String deliveryStockEntries = '/delivery-boy/stock-entries';
  static const String assignedAreas = '/delivery-boy/assigned-areas';
  static const String deliveryReasons = '/delivery-boy/reasons';

  // Customer endpoints
  static const String customers = '/customers';

  // Entry endpoints
  static const String entries = '/entries';

  // Stock endpoints
  static const String stock = '/stock';
}