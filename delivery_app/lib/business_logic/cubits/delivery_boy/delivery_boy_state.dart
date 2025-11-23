import 'package:equatable/equatable.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/entry_model.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/area_model.dart';
import '../../../data/models/delivery_boy_model.dart';

abstract class DeliveryBoyState extends Equatable {
  const DeliveryBoyState();

  @override
  List<Object?> get props => [];
}

// Dashboard States
class DeliveryBoyDashboardInitial extends DeliveryBoyState {}

class DeliveryBoyDashboardLoading extends DeliveryBoyState {}

class DeliveryBoyDashboardLoaded extends DeliveryBoyState {
  final Map<String, dynamic> stats;

  const DeliveryBoyDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DeliveryBoyDashboardError extends DeliveryBoyState {
  final String message;

  const DeliveryBoyDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Profile States
class DeliveryBoyProfileLoading extends DeliveryBoyState {}

class DeliveryBoyProfileLoaded extends DeliveryBoyState {
  final DeliveryBoyModel profile;

  const DeliveryBoyProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DeliveryBoyProfileError extends DeliveryBoyState {
  final String message;

  const DeliveryBoyProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// Customer States
class DeliveryBoyCustomersLoading extends DeliveryBoyState {}

class DeliveryBoyCustomersLoaded extends DeliveryBoyState {
  final List<CustomerModel> customers;

  const DeliveryBoyCustomersLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class DeliveryBoyCustomersError extends DeliveryBoyState {
  final String message;

  const DeliveryBoyCustomersError(this.message);

  @override
  List<Object?> get props => [message];
}

// Entry States
class DeliveryBoyEntriesLoading extends DeliveryBoyState {}

class DeliveryBoyEntriesLoaded extends DeliveryBoyState {
  final List<EntryModel> entries;

  const DeliveryBoyEntriesLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

class DeliveryBoyEntriesError extends DeliveryBoyState {
  final String message;

  const DeliveryBoyEntriesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Stock States
class DeliveryBoyStockLoading extends DeliveryBoyState {}

class DeliveryBoyStockLoaded extends DeliveryBoyState {
  final List<StockModel> stocks;

  const DeliveryBoyStockLoaded(this.stocks);

  @override
  List<Object?> get props => [stocks];
}

class DeliveryBoyStockError extends DeliveryBoyState {
  final String message;

  const DeliveryBoyStockError(this.message);

  @override
  List<Object?> get props => [message];
}

// Area States
class DeliveryBoyAreasLoading extends DeliveryBoyState {}

class DeliveryBoyAreasLoaded extends DeliveryBoyState {
  final List<AreaModel> areas;

  const DeliveryBoyAreasLoaded(this.areas);

  @override
  List<Object?> get props => [areas];
}

class DeliveryBoyAreasError extends DeliveryBoyState {
  final String message;

  const DeliveryBoyAreasError(this.message);

  @override
  List<Object?> get props => [message];
}

// Operation States
class DeliveryBoyOperationLoading extends DeliveryBoyState {}

class DeliveryBoyOperationSuccess extends DeliveryBoyState {
  final String message;

  const DeliveryBoyOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DeliveryBoyOperationError extends DeliveryBoyState {
  final String message;

  const DeliveryBoyOperationError(this.message);

  @override
  List<Object?> get props => [message];
}