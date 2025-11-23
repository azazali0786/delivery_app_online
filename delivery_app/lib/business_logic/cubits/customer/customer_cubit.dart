import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/customer_repository.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerCubit(this._customerRepository) : super(CustomerInitial());

  Future<void> loadCustomer(int id) async {
    emit(CustomerLoading());
    try {
      final customer = await _customerRepository.getCustomerById(id);
      emit(CustomerLoaded(customer));
    } catch (e) {
      emit(CustomerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loadCustomerEntries(
    int id, {
    String? startDate,
    String? endDate,
  }) async {
    emit(CustomerEntriesLoading());
    try {
      final entries = await _customerRepository.getCustomerEntries(
        id,
        startDate: startDate,
        endDate: endDate,
      );
      emit(CustomerEntriesLoaded(entries));
    } catch (e) {
      emit(CustomerEntriesError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}