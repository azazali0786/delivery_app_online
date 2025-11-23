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
    return (response as List).map((e) => EntryModel.fromJson(e)).toList();
  }
}