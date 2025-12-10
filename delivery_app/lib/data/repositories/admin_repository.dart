import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/delivery_boy_model.dart';
import '../models/customer_model.dart';
import '../models/area_model.dart';
import '../models/stock_model.dart';
import '../models/entry_model.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  // Dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    return await _apiService.get(ApiConstants.adminDashboard);
  }

  Future<Map<String, dynamic>> getDashboardReport({String? date}) async {
    String endpoint = ApiConstants.adminDashboardReport;
    if (date != null) {
      endpoint += '?date=$date';
    }
    return await _apiService.get(endpoint);
  }

  // Calculate Stats for Specific Delivery Boy
  Future<Map<String, dynamic>> calculateDeliveryBoyStats(
    int deliveryBoyId,
  ) async {
    try {
      // Fetch delivery boy with their assigned sub-areas
      final deliveryBoys = await getAllDeliveryBoys();
      final deliveryBoy = deliveryBoys.firstWhere(
        (db) => db.id == deliveryBoyId,
        orElse: () => throw Exception('Delivery boy not found'),
      );

      // Get list of sub-area IDs assigned to this delivery boy
      final assignedSubAreaIds =
          deliveryBoy.subAreas?.map((sa) => sa.subAreaId).toList() ?? [];

      // Fetch customers assigned to this delivery boy
      final allCustomers = await getAllCustomers(deliveryBoyId: deliveryBoyId);

      // Filter customers to only those in the same sub-areas as delivery boy
      final customers = allCustomers
          .where(
            (c) =>
                c.subAreaId != null && assignedSubAreaIds.contains(c.subAreaId),
          )
          .toList();

      final activeCustomers = customers
          .where((c) => c.isActive ?? false)
          .toList();

      // Fetch entries for today for this delivery boy
      final todayEntries = await getEntries(
        deliveryBoyId: deliveryBoyId,
        date: DateTime.now().toString().split(' ')[0],
      );

      // Fetch today's stock entry for this delivery boy
      final todayDate = DateTime.now().toString().split(' ')[0];
      final stockEntries = await getAllStockEntries(
        deliveryBoyId: deliveryBoyId,
        startDate: todayDate,
        endDate: todayDate,
      );

      // ---------------------------
      // ✅ UPDATED NEED CALCULATION (matching delivery boy logic)
      // ---------------------------
      int needHalf = 0;
      int needOne = 0;

      for (var customer in activeCustomers) {
        final double qty = customer.permanentQuantity;

        needOne += qty ~/ 1; // full 1-liter bottles
        double remaining = qty % 1; // leftover

        if (remaining >= 0.5) needHalf += 1; // half bottle if >= 0.5
      }

      // ---------------------------
      // Calculate Dispatched Stock from today's stock entries
      // ---------------------------
      double dispatchedHalf = 0;
      double dispatchedOne = 0;

      for (var stock in stockEntries) {
        dispatchedHalf += stock.halfLtrBottles;
        dispatchedOne += stock.oneLtrBottles;
      }

      // ---------------------------
      // Calculate Assign (Today Delivered) from today's entries
      // ---------------------------
      double assignHalf = 0;
      double assignOne = 0;
      double todayOnline = 0;
      double todayCash = 0;
      double todayPending = 0;

      for (var entry in todayEntries) {
        double quantity = entry.milkQuantity;

        assignOne += quantity ~/ 1;
        double remaining = quantity % 1;
        if (remaining >= 0.5) assignHalf += 1;

        // Calculate money collections
        if (entry.paymentMethod.toLowerCase() == 'online') {
          todayOnline += entry.collectedMoney;
        } else if (entry.paymentMethod.toLowerCase() == 'cash') {
          todayCash += entry.collectedMoney;
        }

        // Fixed: Calculate today's pending correctly
        todayPending +=
            (entry.milkQuantity * entry.rate) - entry.collectedMoney;
      }

      // Calculate Left in Market = Dispatched - Delivered
      double leftHalf = dispatchedHalf - assignHalf;
      double leftOne = dispatchedOne - assignOne;

      // Don't set negative values to 0 to show oversupply
      // if (leftHalf < 0) leftHalf = 0;
      // if (leftOne < 0) leftOne = 0;
     print(customers.length);
      // Calculate Total Pending Money
      double totalPending = 0;
      for (var customer in customers) {
        if (customer.totalPendingMoney != null) {
          totalPending += customer.totalPendingMoney!;
        }
      }
      return {
        'need_half': needHalf,
        'need_one': needOne,
        'stock_half_ltr_bottles': dispatchedHalf.toInt(),
        'stock_one_ltr_bottles': dispatchedOne.toInt(),
        'assign_half': assignHalf.toInt(),
        'assign_one': assignOne.toInt(),
        'left_half': leftHalf.toInt(),
        'left_one': leftOne.toInt(),
        'today_online': todayOnline.toStringAsFixed(2),
        'today_cash': todayCash.toStringAsFixed(2),
        'today_pending': todayPending.toStringAsFixed(2),
        'total_pending': totalPending.toStringAsFixed(2),
      };
    } catch (e) {
      print('Error calculating delivery boy stats: $e');
      return {
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
      };
    }
  }

  // Delivery Boys
  Future<List<DeliveryBoyModel>> getAllDeliveryBoys({
    int? areaId,
    int? subAreaId,
    String? search,
  }) async {
    String endpoint = ApiConstants.deliveryBoys;
    List<String> queryParams = [];

    if (areaId != null) queryParams.add('area_id=$areaId');
    if (subAreaId != null) queryParams.add('sub_area_id=$subAreaId');
    if (search != null && search.isNotEmpty) queryParams.add('search=$search');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _apiService.get(endpoint);
    return (response as List).map((e) => DeliveryBoyModel.fromJson(e)).toList();
  }

  Future<DeliveryBoyModel> createDeliveryBoy(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiConstants.deliveryBoys, data);
    return DeliveryBoyModel.fromJson(response);
  }

  Future<DeliveryBoyModel> updateDeliveryBoy(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put(
      '${ApiConstants.deliveryBoys}/$id',
      data,
    );
    return DeliveryBoyModel.fromJson(response);
  }

  Future<void> deleteDeliveryBoy(int id) async {
    await _apiService.delete('${ApiConstants.deliveryBoys}/$id');
  }

  Future<DeliveryBoyModel> toggleDeliveryBoyActive(int id) async {
    final response = await _apiService.patch(
      '${ApiConstants.deliveryBoys}/$id/toggle-active',
      {},
    );
    return DeliveryBoyModel.fromJson(response);
  }

  Future<void> assignSubAreas(int deliveryBoyId, List<int> subAreaIds) async {
    await _apiService.post(ApiConstants.assignSubAreas, {
      'delivery_boy_id': deliveryBoyId,
      'sub_area_ids': subAreaIds,
    });
  }

  // Customers
  Future<List<CustomerModel>> getAllCustomers({
    int? deliveryBoyId,
    int? areaId,
    int? subAreaId,
    double? minPendingMoney,
    int? minPendingBottles,
    String? permanentQuantityOrder,
    String? search,
  }) async {
    String endpoint = ApiConstants.adminCustomers;
    List<String> queryParams = [];

    if (deliveryBoyId != null) {
      queryParams.add('delivery_boy_id=$deliveryBoyId');
    }
    if (areaId != null) queryParams.add('area_id=$areaId');
    if (subAreaId != null) queryParams.add('sub_area_id=$subAreaId');
    if (minPendingMoney != null) {
      queryParams.add('min_pending_money=$minPendingMoney');
    }
    if (minPendingBottles != null) {
      queryParams.add('min_pending_bottles=$minPendingBottles');
    }
    if (permanentQuantityOrder != null) {
      queryParams.add('permanent_quantity_order=$permanentQuantityOrder');
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

  Future<List<CustomerModel>> getPendingApprovals() async {
    final response = await _apiService.get(ApiConstants.pendingApprovals);
    return (response as List).map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiConstants.adminCustomers, data);
    return CustomerModel.fromJson(response);
  }

  Future<CustomerModel> updateCustomer(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put(
      '${ApiConstants.adminCustomers}/$id',
      data,
    );
    return CustomerModel.fromJson(response);
  }

  Future<void> deleteCustomer(int id) async {
    await _apiService.delete('${ApiConstants.adminCustomers}/$id');
  }

  Future<CustomerModel> approveCustomer(
    int id,
    int subAreaId,
    double sortNumber,
  ) async {
    final response = await _apiService.post(
      '${ApiConstants.adminCustomers}/$id/approve',
      {'sub_area_id': subAreaId, 'sort_number': sortNumber},
    );
    return CustomerModel.fromJson(response);
  }

  // Areas
  Future<List<AreaModel>> getAllAreas() async {
    final response = await _apiService.get(ApiConstants.areas);
    return (response as List).map((e) => AreaModel.fromJson(e)).toList();
  }

  Future<AreaModel> createArea(String name) async {
    final response = await _apiService.post(ApiConstants.areas, {'name': name});
    return AreaModel.fromJson(response);
  }

  Future<SubAreaModel> createSubArea(int areaId, String name) async {
    final response = await _apiService.post(ApiConstants.subAreas, {
      'area_id': areaId,
      'name': name,
    });
    return SubAreaModel.fromJson(response);
  }

  Future<AreaModel> updateArea(int id, String name) async {
    final response = await _apiService.put('${ApiConstants.areas}/$id', {
      'name': name,
    });
    return AreaModel.fromJson(response);
  }

  Future<SubAreaModel> updateSubArea(int id, String name) async {
    final response = await _apiService.put('${ApiConstants.subAreas}/$id', {
      'name': name,
    });
    return SubAreaModel.fromJson(response);
  }

  Future<void> deleteArea(int id) async {
    await _apiService.delete('${ApiConstants.areas}/$id');
  }

  Future<void> deleteSubArea(int id) async {
    await _apiService.delete('${ApiConstants.subAreas}/$id');
  }

  // Reasons
  Future<List<Map<String, dynamic>>> getAllReasons() async {
    final response = await _apiService.get(ApiConstants.reasons);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createReason(String reason) async {
    return await _apiService.post(ApiConstants.reasons, {'reason': reason});
  }

  Future<Map<String, dynamic>> updateReason(int id, String reason) async {
    return await _apiService.put('${ApiConstants.reasons}/$id', {
      'reason': reason,
    });
  }

  Future<void> deleteReason(int id) async {
    await _apiService.delete('${ApiConstants.reasons}/$id');
  }

  // Stock Entries
  Future<List<StockModel>> getAllStockEntries({
    int? deliveryBoyId,
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = ApiConstants.stockEntries;
    List<String> queryParams = [];

    if (deliveryBoyId != null) {
      queryParams.add('delivery_boy_id=$deliveryBoyId');
    }
    if (startDate != null) queryParams.add('start_date=$startDate');
    if (endDate != null) queryParams.add('end_date=$endDate');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }
    final response = await _apiService.get(endpoint);
    return (response as List).map((e) => StockModel.fromJson(e)).toList();
  }

  Future<StockModel> createStockEntry(Map<String, dynamic> data) async {
    final response = await _apiService.post(ApiConstants.stockEntries, data);
    return StockModel.fromJson(response);
  }

  Future<StockModel> updateStockEntry(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put(
      '${ApiConstants.stockEntries}/$id',
      data,
    );
    return StockModel.fromJson(response);
  }

  Future<void> deleteStockEntry(int id) async {
    await _apiService.delete('${ApiConstants.stockEntries}/$id');
  }

  // Entries
  Future<void> deleteEntry(int id) async {
    await _apiService.delete('${ApiConstants.adminEntries}/$id');
  }

  // Expenses
  Future<List<Map<String, dynamic>>> createExpenses(
    List<Map<String, dynamic>> expenses,
  ) async {
    final response = await _apiService.post(ApiConstants.adminExpenses, {
      'expenses': expenses,
    });
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getExpenses({
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = ApiConstants.adminExpenses;
    List<String> qp = [];
    if (startDate != null) qp.add('start_date=$startDate');
    if (endDate != null) qp.add('end_date=$endDate');
    if (qp.isNotEmpty) endpoint += '?${qp.join('&')}';
    final response = await _apiService.get(endpoint);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deleteExpense(int id) async {
    await _apiService.delete('${ApiConstants.adminExpenses}/$id');
  }

  Future<void> deleteExpensesByDate(String date) async {
    await _apiService.delete(
      '${ApiConstants.adminExpenses}/by-date?date=$date',
    );
  }

  Future<List<EntryModel>> getEntries({
    int? deliveryBoyId,
    String? date,
  }) async {
    String endpoint = ApiConstants.adminEntries;
    List<String> queryParams = [];

    if (deliveryBoyId != null) {
      queryParams.add('delivery_boy_id=$deliveryBoyId');
    }
    if (date != null) {
      queryParams.add('date=$date');
    }

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }
    try {
      final response = await _apiService.get(endpoint);
      return (response as List).map((e) => EntryModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Invoice
  Future<Map<String, dynamic>> generateInvoice({
    required int customerId,
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = '${ApiConstants.adminInvoice}?customer_id=$customerId';

    if (startDate != null) endpoint += '&start_date=$startDate';
    if (endDate != null) endpoint += '&end_date=$endDate';

    return await _apiService.get(endpoint);
  }
}
