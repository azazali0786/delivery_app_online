import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/customer_model.dart';
import '../models/entry_model.dart';

class CustomerRepository {
  final ApiService _apiService;

  CustomerRepository(this._apiService);

  Future<CustomerModel> getCustomerById(int id) async {
    final response = await _apiService.get('${ApiConstants.customers}/$id');
    return CustomerModel.fromJson(response);
  }

  Future<List<EntryModel>> getCustomerEntries(
    int id, {
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = '${ApiConstants.customers}/$id/entries';
    List<String> queryParams = [];

    if (startDate != null) queryParams.add('start_date=$startDate');
    if (endDate != null) queryParams.add('end_date=$endDate');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _apiService.get(endpoint);
    // If backend returns an object with entries and opening_balance, return only the entries
    if (response is Map && response.containsKey('entries')) {
      return (response['entries'] as List)
          .map((e) => EntryModel.fromJson(e))
          .toList();
    }

    return (response as List).map((e) => EntryModel.fromJson(e)).toList();
  }

  /// New: get entries along with opening balance when startDate is provided
  Future<Map<String, dynamic>> getCustomerEntriesWithOpeningBalance(
    int id, {
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = '${ApiConstants.customers}/$id/entries';
    List<String> queryParams = [];

    if (startDate != null) queryParams.add('start_date=$startDate');
    if (endDate != null) queryParams.add('end_date=$endDate');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _apiService.get(endpoint);

    if (response is Map && response.containsKey('entries')) {
      final entries = (response['entries'] as List)
          .map((e) => EntryModel.fromJson(e))
          .toList();
      final opening = (response['opening_balance'] ?? 0).toDouble();
      return {'entries': entries, 'opening_balance': opening};
    }

    // Fallback when backend returns just a list
    final entries = (response as List)
        .map((e) => EntryModel.fromJson(e))
        .toList();
    return {'entries': entries, 'opening_balance': 0.0};
  }
}
