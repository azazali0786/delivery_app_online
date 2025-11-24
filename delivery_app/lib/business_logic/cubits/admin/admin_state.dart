import 'package:equatable/equatable.dart';
import '../../../data/models/delivery_boy_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/area_model.dart';
import '../../../data/models/stock_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

// Dashboard States
class AdminDashboardInitial extends AdminState {}

class AdminDashboardLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final Map<String, dynamic> stats;

  const AdminDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class AdminDashboardError extends AdminState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Delivery Boy States
class DeliveryBoysLoading extends AdminState {}

class DeliveryBoysLoaded extends AdminState {
  final List<DeliveryBoyModel> deliveryBoys;

  const DeliveryBoysLoaded(this.deliveryBoys);

  @override
  List<Object?> get props => [deliveryBoys];
}

class DeliveryBoysError extends AdminState {
  final String message;

  const DeliveryBoysError(this.message);

  @override
  List<Object?> get props => [message];
}

// Customer States
class CustomersLoading extends AdminState {}

class CustomersLoaded extends AdminState {
  final List<CustomerModel> customers;

  const CustomersLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomersError extends AdminState {
  final String message;

  const CustomersError(this.message);

  @override
  List<Object?> get props => [message];
}

// Area States
class AreasLoading extends AdminState {}

class AreasLoaded extends AdminState {
  final List<AreaModel> areas;

  const AreasLoaded(this.areas);

  @override
  List<Object?> get props => [areas];
}

class AreasError extends AdminState {
  final String message;

  const AreasError(this.message);

  @override
  List<Object?> get props => [message];
}

// Stock States
class StockLoading extends AdminState {}

class StockLoaded extends AdminState {
  final List<StockModel> stocks;

  const StockLoaded(this.stocks);

  @override
  List<Object?> get props => [stocks];
}

class StockError extends AdminState {
  final String message;

  const StockError(this.message);

  @override
  List<Object?> get props => [message];
}

// Reasons States
class ReasonsLoading extends AdminState {}

class ReasonsLoaded extends AdminState {
  final List<Map<String, dynamic>> reasons;

  const ReasonsLoaded(this.reasons);

  @override
  List<Object?> get props => [reasons];
}

class ReasonsError extends AdminState {
  final String message;

  const ReasonsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Operation States
class AdminOperationLoading extends AdminState {}

class AdminOperationSuccess extends AdminState {
  final String message;

  const AdminOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminOperationError extends AdminState {
  final String message;

  const AdminOperationError(this.message);

  @override
  List<Object?> get props => [message];
}
