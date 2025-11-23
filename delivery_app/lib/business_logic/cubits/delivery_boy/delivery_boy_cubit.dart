import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/delivery_boy_repository.dart';
import 'delivery_boy_state.dart';

class DeliveryBoyCubit extends Cubit<DeliveryBoyState> {
  final DeliveryBoyRepository _deliveryBoyRepository;

  DeliveryBoyCubit(this._deliveryBoyRepository)
      : super(DeliveryBoyDashboardInitial());

  // Dashboard
  Future<void> loadDashboard() async {
    emit(DeliveryBoyDashboardLoading());
    try {
      final stats = await _deliveryBoyRepository.getDashboard();
      emit(DeliveryBoyDashboardLoaded(stats));
    } catch (e) {
      emit(DeliveryBoyDashboardError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Profile
  Future<void> loadProfile() async {
    emit(DeliveryBoyProfileLoading());
    try {
      final profile = await _deliveryBoyRepository.getProfile();
      emit(DeliveryBoyProfileLoaded(profile));
    } catch (e) {
      emit(
          DeliveryBoyProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Customers
  Future<void> loadCustomers({
    int? areaId,
    int? subAreaId,
    String? deliveryStatus,
    String? search,
  }) async {
    emit(DeliveryBoyCustomersLoading());
    try {
      final customers = await _deliveryBoyRepository.getCustomers(
        areaId: areaId,
        subAreaId: subAreaId,
        deliveryStatus: deliveryStatus,
        search: search,
      );
      emit(DeliveryBoyCustomersLoaded(customers));
    } catch (e) {
      emit(DeliveryBoyCustomersError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCustomer(Map<String, dynamic> data) async {
    emit(DeliveryBoyOperationLoading());
    try {
      await _deliveryBoyRepository.createCustomer(data);
      emit(const DeliveryBoyOperationSuccess(
          'Customer added successfully. Waiting for admin approval.'));
    } catch (e) {
      emit(DeliveryBoyOperationError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Entries
  Future<void> loadEntries({String? date}) async {
    emit(DeliveryBoyEntriesLoading());
    try {
      final entries = await _deliveryBoyRepository.getEntries(date: date);
      emit(DeliveryBoyEntriesLoaded(entries));
    } catch (e) {
      emit(DeliveryBoyEntriesError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loadCustomerEntries(
    int customerId, {
    String? startDate,
    String? endDate,
  }) async {
    emit(DeliveryBoyEntriesLoading());
    try {
      final entries = await _deliveryBoyRepository.getCustomerEntries(
        customerId,
        startDate: startDate,
        endDate: endDate,
      );
      emit(DeliveryBoyEntriesLoaded(entries));
    } catch (e) {
      emit(DeliveryBoyEntriesError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createEntry(Map<String, dynamic> data) async {
    emit(DeliveryBoyOperationLoading());
    try {
      await _deliveryBoyRepository.createEntry(data);
      emit(const DeliveryBoyOperationSuccess('Entry created successfully'));
      loadDashboard();
    } catch (e) {
      emit(DeliveryBoyOperationError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateEntry(int id, Map<String, dynamic> data) async {
    emit(DeliveryBoyOperationLoading());
    try {
      await _deliveryBoyRepository.updateEntry(id, data);
      emit(const DeliveryBoyOperationSuccess('Entry updated successfully'));
    } catch (e) {
      emit(DeliveryBoyOperationError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> markNotDelivered(int entryId, String reason) async {
    emit(DeliveryBoyOperationLoading());
    try {
      await _deliveryBoyRepository.markNotDelivered(entryId, reason);
      emit(const DeliveryBoyOperationSuccess('Marked as not delivered'));
      loadDashboard();
    } catch (e) {
      emit(DeliveryBoyOperationError(
          e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Stock
  Future<void> loadStockEntries({
    String? startDate,
    String? endDate,
  }) async {
    emit(DeliveryBoyStockLoading());
    try {
      final stocks = await _deliveryBoyRepository.getStockEntries(
        startDate: startDate,
        endDate: endDate,
      );
      emit(DeliveryBoyStockLoaded(stocks));
    } catch (e) {
      emit(
          DeliveryBoyStockError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Areas
  Future<void> loadAssignedAreas() async {
    emit(DeliveryBoyAreasLoading());
    try {
      final areas = await _deliveryBoyRepository.getAssignedAreas();
      emit(DeliveryBoyAreasLoaded(areas));
    } catch (e) {
      emit(
          DeliveryBoyAreasError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}