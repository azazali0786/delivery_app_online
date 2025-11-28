import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _adminRepository;

  AdminCubit(this._adminRepository) : super(AdminDashboardInitial());

  // Dashboard
  Future<void> loadDashboard() async {
    emit(AdminDashboardLoading());
    try {
      final stats = await _adminRepository.getDashboard();
      emit(AdminDashboardLoaded(stats));
    } catch (e) {
      emit(AdminDashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Delivery Boys
  Future<void> loadDeliveryBoys({
    int? areaId,
    int? subAreaId,
    String? search,
  }) async {
    emit(DeliveryBoysLoading());
    try {
      final deliveryBoys = await _adminRepository.getAllDeliveryBoys(
        areaId: areaId,
        subAreaId: subAreaId,
        search: search,
      );
      emit(DeliveryBoysLoaded(deliveryBoys));
    } catch (e) {
      emit(DeliveryBoysError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createDeliveryBoy(Map<String, dynamic> data) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.createDeliveryBoy(data);
      emit(const AdminOperationSuccess('Delivery boy created successfully'));
      loadDeliveryBoys();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateDeliveryBoy(int id, Map<String, dynamic> data) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.updateDeliveryBoy(id, data);
      emit(const AdminOperationSuccess('Delivery boy updated successfully'));
      loadDeliveryBoys();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteDeliveryBoy(int id) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.deleteDeliveryBoy(id);
      emit(const AdminOperationSuccess('Delivery boy deleted successfully'));
      loadDeliveryBoys();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> toggleDeliveryBoyActive(int id) async {
    try {
      await _adminRepository.toggleDeliveryBoyActive(id);
      loadDeliveryBoys();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> assignSubAreas(int deliveryBoyId, List<int> subAreaIds) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.assignSubAreas(deliveryBoyId, subAreaIds);
      emit(const AdminOperationSuccess('Sub-areas assigned successfully'));
      loadDeliveryBoys();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Customers
  Future<void> loadCustomers({
    int? deliveryBoyId,
    int? areaId,
    int? subAreaId,
    double? minPendingMoney,
    int? minPendingBottles,
    String? permanentQuantityOrder,
    String? search,
  }) async {
    emit(CustomersLoading());
    try {
      final customers = await _adminRepository.getAllCustomers(
        deliveryBoyId: deliveryBoyId,
        areaId: areaId,
        subAreaId: subAreaId,
        minPendingMoney: minPendingMoney,
        minPendingBottles: minPendingBottles,
        permanentQuantityOrder: permanentQuantityOrder,
        search: search,
      );
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loadPendingApprovals() async {
    emit(CustomersLoading());
    try {
      final customers = await _adminRepository.getPendingApprovals();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCustomer(Map<String, dynamic> data) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.createCustomer(data);
      emit(const AdminOperationSuccess('Customer created successfully'));
      loadCustomers();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCustomer(int id, Map<String, dynamic> data) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.updateCustomer(id, data);
      emit(const AdminOperationSuccess('Customer updated successfully'));
      loadCustomers();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCustomer(int id) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.deleteCustomer(id);
      emit(const AdminOperationSuccess('Customer deleted successfully'));
      loadCustomers();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> approveCustomer(int id, int subAreaId, double sortNumber) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.approveCustomer(id, subAreaId, sortNumber);
      emit(const AdminOperationSuccess('Customer approved successfully'));
      loadPendingApprovals();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Areas
  Future<void> loadAreas() async {
    emit(AreasLoading());
    try {
      final areas = await _adminRepository.getAllAreas();
      emit(AreasLoaded(areas));
    } catch (e) {
      emit(AreasError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createArea(String name) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.createArea(name);
      emit(const AdminOperationSuccess('Area created successfully'));
      loadAreas();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createSubArea(int areaId, String name) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.createSubArea(areaId, name);
      emit(const AdminOperationSuccess('Sub-area created successfully'));
      loadAreas();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateArea(int id, String name) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.updateArea(id, name);
      emit(const AdminOperationSuccess('Area updated successfully'));
      loadAreas();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateSubArea(int id, String name) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.updateSubArea(id, name);
      emit(const AdminOperationSuccess('Sub-area updated successfully'));
      loadAreas();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteArea(int id) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.deleteArea(id);
      emit(const AdminOperationSuccess('Area deleted successfully'));
      loadAreas();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteSubArea(int id) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.deleteSubArea(id);
      emit(const AdminOperationSuccess('Sub-area deleted successfully'));
      loadAreas();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Stock
  Future<void> loadStockEntries({
    int? deliveryBoyId,
    String? startDate,
    String? endDate,
  }) async {
    emit(StockLoading());
    try {
      final stocks = await _adminRepository.getAllStockEntries(
        deliveryBoyId: deliveryBoyId,
        startDate: startDate,
        endDate: endDate,
      );
      emit(StockLoaded(stocks));
    } catch (e) {
      emit(StockError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createStockEntry(Map<String, dynamic> data) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.createStockEntry(data);
      emit(const AdminOperationSuccess('Stock entry created successfully'));
      loadStockEntries();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateStockEntry(int id, Map<String, dynamic> data) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.updateStockEntry(id, data);
      emit(const AdminOperationSuccess('Stock entry updated successfully'));
      loadStockEntries();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteStockEntry(int id) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.deleteStockEntry(id);
      emit(const AdminOperationSuccess('Stock entry deleted successfully'));
      loadStockEntries();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Reasons
  Future<void> loadReasons() async {
    emit(ReasonsLoading());
    try {
      final reasons = await _adminRepository.getAllReasons();
      emit(ReasonsLoaded(reasons));
    } catch (e) {
      emit(ReasonsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createReason(String reason) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.createReason(reason);
      emit(const AdminOperationSuccess('Reason created successfully'));
      loadReasons();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateReason(int id, String reason) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.updateReason(id, reason);
      emit(const AdminOperationSuccess('Reason updated successfully'));
      loadReasons();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteReason(int id) async {
    emit(AdminOperationLoading());
    try {
      await _adminRepository.deleteReason(id);
      emit(const AdminOperationSuccess('Reason deleted successfully'));
      loadReasons();
    } catch (e) {
      emit(AdminOperationError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
