import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/customer_model.dart';
import '../models/entry_model.dart';
import '../models/stock_model.dart';
import '../models/area_model.dart';
import '../models/delivery_boy_model.dart';

class DeliveryBoyRepository {
  final ApiService _apiService;

  DeliveryBoyRepository(this._apiService);

  // Dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    return await _apiService.get(ApiConstants.deliveryDashboard);
  }

  // Calculate Dashboard Stats
  Future<Map<String, dynamic>> calculateDashboardStats() async {
    try {
      final dashboard = await getDashboard();

      return {
        'stock_half_ltr_bottles': dashboard['half_ltr_bottles'] ?? 0,
        'stock_one_ltr_bottles': dashboard['one_ltr_bottles'] ?? 0,
        'need_half': dashboard['need_half'] ?? 0,
        'need_one': dashboard['need_one'] ?? 0,
        'assign_half': dashboard['assign_half'] ?? 0,
        'assign_one': dashboard['assign_one'] ?? 0,
        'left_half': dashboard['left_half'] ?? 0,
        'left_one': dashboard['left_one'] ?? 0,
        'today_online': (dashboard['today_online'] ?? 0).toStringAsFixed(2),
        'today_cash': (dashboard['today_cash'] ?? 0).toStringAsFixed(2),
        'today_pending': (dashboard['today_pending'] ?? 0).toStringAsFixed(2),
        'total_pending': (dashboard['total_pending'] ?? 0).toStringAsFixed(2),
        'total_pending_bottles': dashboard['total_pending_bottles'] ?? 0,
        'today_collected_bottles': dashboard['today_collected_bottles'] ?? 0,
        'today_bottles': dashboard['today_bottles'] ?? 0,
        'period': dashboard['period'] ?? 'morning',
      };
    } catch (e) {
      return {
        'stock_half_ltr_bottles': 0,
        'stock_one_ltr_bottles': 0,
        'need_half': 0,
        'need_one': 0,
        'assign_half': 0,
        'assign_one': 0,
        'left_half': 0,
        'left_one': 0,
        'today_online': '0.00',
        'today_cash': '0.00',
        'today_pending': '0.00',
        'total_pending': '0.00',
        'total_pending_bottles': 0,
        'today_collected_bottles': 0,
        'today_bottles': 0,
        'period': 'morning',
      };
    }
  }

  // Profile
  Future<DeliveryBoyModel> getProfile() async {
    final response = await _apiService.get(ApiConstants.deliveryProfile);
    return DeliveryBoyModel.fromJson(response);
  }

  // Customers
  Future<List<CustomerModel>> getCustomers({
    int? areaId,
    int? subAreaId,
    String? deliveryStatus,
    String? search,
  }) async {
    String endpoint = ApiConstants.deliveryCustomers;
    List<String> queryParams = [];

    if (areaId != null) queryParams.add('area_id=$areaId');
    if (subAreaId != null) queryParams.add('sub_area_id=$subAreaId');
    if (deliveryStatus != null) {
      queryParams.add('delivery_status=$deliveryStatus');
    }
    if (search != null && search.isNotEmpty) {
      queryParams.add('search=$search');
    }

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _apiService.get(endpoint);
    return (response as List).map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> getCustomerById(int id) async {
    final response = await _apiService.get(
      '${ApiConstants.deliveryCustomers}/$id',
    );
    return CustomerModel.fromJson(response);
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await _apiService.post(
      ApiConstants.deliveryCustomers,
      data,
    );
    return CustomerModel.fromJson(response);
  }

  // Entries
  Future<List<EntryModel>> getEntries({String? date}) async {
    String endpoint = ApiConstants.deliveryEntries;
    if (date != null) {
      endpoint += '?date=$date';
    }

    final response = await _apiService.get(endpoint);
    return (response as List).map((e) => EntryModel.fromJson(e)).toList();
  }

  Future<List<EntryModel>> getCustomerEntries(
    int customerId, {
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = '${ApiConstants.deliveryCustomers}/$customerId/entries';
    List<String> queryParams = [];

    if (startDate != null) queryParams.add('start_date=$startDate');
    if (endDate != null) queryParams.add('end_date=$endDate');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _apiService.get(endpoint);
    return (response as List).map((e) => EntryModel.fromJson(e)).toList();
  }

  Future<EntryModel> createEntry(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiConstants.deliveryEntries, data);
    return EntryModel.fromJson(response);
  }

  Future<EntryModel> updateEntry(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put(
      '${ApiConstants.deliveryEntries}/$id',
      data,
    );
    return EntryModel.fromJson(response);
  }

  Future<EntryModel> markNotDelivered(int id, String reason) async {
    final response = await _apiService.patch(
      '${ApiConstants.deliveryEntries}/$id/not-delivered',
      {'reason': reason},
    );
    return EntryModel.fromJson(response);
  }

  // Stock
  Future<List<StockModel>> getStockEntries({
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = ApiConstants.deliveryStockEntries;
    List<String> queryParams = [];

    if (startDate != null) queryParams.add('start_date=$startDate');
    if (endDate != null) queryParams.add('end_date=$endDate');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _apiService.get(endpoint);
    return (response as List).map((e) => StockModel.fromJson(e)).toList();
  }

  Future<StockModel?> getTodayStock() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.deliveryStockEntries}/today',
      );
      return StockModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Areas
  Future<List<AreaModel>> getAssignedAreas() async {
    final response = await _apiService.get(ApiConstants.assignedAreas);
    return (response as List).map((e) => AreaModel.fromJson(e)).toList();
  }

  // Reasons
  Future<List<Map<String, dynamic>>> getReasons() async {
    final response = await _apiService.get(ApiConstants.deliveryReasons);

    return List<Map<String, dynamic>>.from(response);
  }
}
