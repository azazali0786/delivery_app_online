// lib/presentation/screens/admin/customer_management.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/admin/customer_card.dart';
import '../../widgets/admin/customer_filter_bar.dart';
import '../../widgets/admin/approve_customer_dialog.dart';
import '../../widgets/admin/edit_customer_dialog.dart';

class CustomerManagement extends StatelessWidget {
  const CustomerManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(context.read<AdminRepository>())..loadCustomers(),
      child: const CustomerManagementView(),
    );
  }
}

class CustomerManagementView extends StatefulWidget {
  const CustomerManagementView({Key? key}) : super(key: key);

  @override
  State<CustomerManagementView> createState() => _CustomerManagementViewState();
}

class _CustomerManagementViewState extends State<CustomerManagementView> {
  final _searchController = TextEditingController();
  final _minPendingController = TextEditingController();
  
  String? _searchQuery;
  double? _minPendingMoney;
  String? _areaFilter;
  String? _subAreaFilter;
  String? _shiftFilter;

  Set<String> _allAreas = {};
  Set<String> _allSubAreas = {};

  @override
  void dispose() {
    _searchController.dispose();
    _minPendingController.dispose();
    super.dispose();
  }

  void _updateFilters(List<CustomerModel> customers) {
    _allAreas = customers
        .where((c) => c.areaName != null)
        .map((c) => c.areaName!)
        .toSet();
    _allSubAreas = customers
        .where((c) => c.subAreaName != null)
        .map((c) => c.subAreaName!)
        .toSet();
  }

  List<CustomerModel> _filterCustomers(List<CustomerModel> customers) {
    return customers.where((customer) {
      // Search filter
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        final matchesName = customer.name.toLowerCase().contains(query);
        final matchesPhone = customer.phoneNumber.contains(query);
        if (!matchesName && !matchesPhone) return false;
      }

      // Pending money filter
      if (_minPendingMoney != null) {
        if ((customer.totalPendingMoney ?? 0) < _minPendingMoney!) {
          return false;
        }
      }

      // Area filter
      if (_areaFilter != null && customer.areaName != _areaFilter) {
        return false;
      }

      // Sub-area filter
      if (_subAreaFilter != null && customer.subAreaName != _subAreaFilter) {
        return false;
      }

      // Shift filter
      if (_shiftFilter != null && (customer.shift ?? '') != _shiftFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = null;
      _minPendingMoney = null;
      _areaFilter = null;
      _subAreaFilter = null;
      _shiftFilter = null;
      _searchController.clear();
      _minPendingController.clear();
    });
    context.read<AdminCubit>().loadCustomers();
  }

  void _applySearch(String value) {
    setState(() {
      _searchQuery = value.isNotEmpty ? value : null;
    });
  }

  void _applyMinPending(String value) {
    setState(() {
      _minPendingMoney = double.tryParse(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pending_actions),
            tooltip: 'Pending Approvals',
            onPressed: () {
              context.read<AdminCubit>().loadPendingApprovals();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminCubit>().loadCustomers();
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AdminOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomersLoading) {
            return const LoadingWidget(message: 'Loading customers...');
          }

          if (state is CustomersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AdminCubit>().loadCustomers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CustomersLoaded) {
            final customers = state.customers;
            _updateFilters(customers);
            final filteredCustomers = _filterCustomers(customers);

            return Column(
              children: [
                // Filter Bar
                CustomerFilterBar(
                  searchController: _searchController,
                  minPendingController: _minPendingController,
                  onSearchChanged: _applySearch,
                  onMinPendingChanged: _applyMinPending,
                  areaFilter: _areaFilter,
                  subAreaFilter: _subAreaFilter,
                  shiftFilter: _shiftFilter,
                  allAreas: _allAreas,
                  allSubAreas: _allSubAreas,
                  onAreaChanged: (value) => setState(() => _areaFilter = value),
                  onSubAreaChanged: (value) => setState(() => _subAreaFilter = value),
                  onShiftChanged: (value) => setState(() => _shiftFilter = value),
                  onClearFilters: _clearFilters,
                ),

                // Customer List
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? const EmptyStateWidget(
                          message: 'No customers found.',
                          icon: Icons.people_outline,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<AdminCubit>().loadCustomers();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = filteredCustomers[index];
                              return CustomerCard(
                                customer: customer,
                                onApprove: () => showDialog(
                                  context: context,
                                  builder: (ctx) => BlocProvider.value(
                                    value: context.read<AdminCubit>(),
                                    child: ApproveCustomerDialog(
                                      customer: customer,
                                      repository: context.read<AdminRepository>(),
                                    ),
                                  ),
                                ),
                                onEdit: () => showDialog(
                                  context: context,
                                  builder: (ctx) => BlocProvider.value(
                                    value: context.read<AdminCubit>(),
                                    child: EditCustomerDialog(
                                      customer: customer,
                                      repository: context.read<AdminRepository>(),
                                    ),
                                  ),
                                ),
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Customer'),
                                      content: Text(
                                        'Are you sure you want to delete ${customer.name}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            context
                                                .read<AdminCubit>()
                                                .deleteCustomer(customer.id);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}