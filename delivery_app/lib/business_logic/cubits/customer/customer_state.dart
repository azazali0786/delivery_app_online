import 'package:equatable/equatable.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/entry_model.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final CustomerModel customer;

  const CustomerLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerEntriesLoading extends CustomerState {}

class CustomerEntriesLoaded extends CustomerState {
  final List<EntryModel> entries;

  const CustomerEntriesLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

class CustomerEntriesError extends CustomerState {
  final String message;

  const CustomerEntriesError(this.message);

  @override
  List<Object?> get props => [message];
}