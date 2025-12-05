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
  final bool unApproved;
  const CustomerManagement({Key? key, required this.unApproved}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = AdminCubit(context.read<AdminRepository>());
        // Load based on initial mode
        if (unApproved) {
          cubit.loadPendingApprovals();
        } else {
          cubit.loadCustomers();
        }
        return cubit;
      },
      child: CustomerManagementView(
        unApproved: unApproved,
      ),
    );
  }
}

class CustomerManagementView extends StatefulWidget {
  final bool unApproved;
  
  const CustomerManagementView({
    Key? key,
    required this.unApproved,
  }) : super(key: key);

  @override
  State<CustomerManagementView> createState() => _CustomerManagementViewState();
}

class _CustomerManagementViewState extends State<CustomerManagementView> {
  final _searchController = TextEditingController();
  final _minPendingController = TextEditingController();
  bool _isPendingMode = false;

  String? _searchQuery;
  double? _minPendingMoney;
  String? _areaFilter;
  String? _subAreaFilter;
  String? _shiftFilter;

  Set<String> _allAreas = {};
  Set<String> _allSubAreas = {};

  @override
  void initState() {
    super.initState();
    _isPendingMode = widget.unApproved; // Set initial mode
  }

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
    _refreshList();
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

  // Helper method to refresh based on current mode
  void _refreshList() {
    if (_isPendingMode) {
      context.read<AdminCubit>().loadPendingApprovals();
    } else {
      context.read<AdminCubit>().loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(_isPendingMode ? 'Pending Approvals' : 'Customer Details'),
        actions: [
          if (!_isPendingMode)
            IconButton(
              icon: const Icon(Icons.pending_actions),
              tooltip: 'Pending Approvals',
              onPressed: () {
                setState(() => _isPendingMode = true);
                context.read<AdminCubit>().loadPendingApprovals();
              },
            ),
          if (_isPendingMode)
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: 'All Customers',
              onPressed: () {
                setState(() => _isPendingMode = false);
                context.read<AdminCubit>().loadCustomers();
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshList,
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
            // Refresh list after successful operation
            _refreshList();
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
            return LoadingWidget(
              message: _isPendingMode 
                ? 'Loading pending approvals...' 
                : 'Loading customers...',
            );
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
                    onPressed: _refreshList,
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
                // Show pending indicator banner
                if (_isPendingMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        Icon(
                          Icons.pending_actions,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Showing ${filteredCustomers.length} pending approval(s)',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Filter Bar (only for non-pending mode)
                if (!_isPendingMode)
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
                    onAreaChanged: (value) =>
                        setState(() => _areaFilter = value),
                    onSubAreaChanged: (value) =>
                        setState(() => _subAreaFilter = value),
                    onShiftChanged: (value) =>
                        setState(() => _shiftFilter = value),
                    onClearFilters: _clearFilters,
                  ),

                // Customer List
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? EmptyStateWidget(
                          message: _isPendingMode 
                            ? 'No pending approvals.' 
                            : 'No customers found.',
                          icon: _isPendingMode 
                            ? Icons.check_circle_outline 
                            : Icons.people_outline,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            _refreshList();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = filteredCustomers[index];
                              return CustomerCard(
                                customer: customer,
                                onApprove: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder: (ctx) => BlocProvider.value(
                                      value: context.read<AdminCubit>(),
                                      child: ApproveCustomerDialog(
                                        customer: customer,
                                        repository: context
                                            .read<AdminRepository>(),
                                      ),
                                    ),
                                  );
                                  // Refresh after dialog closes
                                  if (result == true && mounted) {
                                    _refreshList();
                                  }
                                },
                                onEdit: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder: (ctx) => BlocProvider.value(
                                      value: context.read<AdminCubit>(),
                                      child: EditCustomerDialog(
                                        customer: customer,
                                        repository: context
                                            .read<AdminRepository>(),
                                      ),
                                    ),
                                  );
                                  // Refresh after dialog closes
                                  if (result == true && mounted) {
                                    _refreshList();
                                  }
                                },
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