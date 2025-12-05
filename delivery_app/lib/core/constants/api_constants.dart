class ApiConstants {
  // Base URL - Change this to your backend URL
  // Use Android emulator host mapping by default so emulator can reach your
  // machine's localhost. If you run the app on a physical device, replace
  // with your computer's LAN IP (e.g. 192.168.x.x).
  // When testing on a physical device, use your computer's LAN/Wi-Fi IP below.
  // Detected Wi‑Fi IP on this machine: 10.226.109.216
  // static const String baseUrl = 'http://srv1176321.hstgr.cloud:3000/api';
  static const String baseUrl = 'http://10.183.20.12:3000/api';

  // Alternative for local simulator / desktop where `localhost` resolves to
  // the host machine directly:
  // static const String baseUrl = 'http://localhost:3000/api';

  // Alternative for physical device (use your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:3000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String verify = '/auth/verify';

  // Admin endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminDashboardReport = '/admin/dashboard/report';
  static const String deliveryBoys = '/admin/delivery-boys';
  static const String adminCustomers = '/admin/customers';
  static const String pendingApprovals = '/admin/customers/pending-approvals';
  static const String areas = '/admin/areas';
  static const String subAreas = '/admin/sub-areas';
  static const String reasons = '/admin/reasons';
  static const String stockEntries = '/admin/stock-entries';
  static const String adminEntries = '/admin/entries';
  static const String adminExpenses = '/admin/expenses';
  static const String assignSubAreas = '/admin/delivery-boys/assign-subareas';
  static const String adminInvoice = '/admin/invoice';

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
