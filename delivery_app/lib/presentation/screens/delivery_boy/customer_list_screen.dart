import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_state.dart';
import '../../../data/repositories/delivery_boy_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'entry_screen.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeliveryBoyCubit(context.read<DeliveryBoyRepository>())
            ..loadCustomers(),
      child: const CustomerListView(),
    );
  }
}

class CustomerListView extends StatefulWidget {
  const CustomerListView({Key? key}) : super(key: key);

  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  String? _deliveryStatusFilter;
  String? _areaFilter;
  String? _shiftFilter;
  String? _subAreaFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<CustomerModel> _filteredCustomers = [];
  Set<String> _allAreas = {};
  Set<String> _allSubAreas = {};

  @override
  void dispose() {
    _searchController.dispose();
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
      // Exclude inactive customers
      if (customer.isActive != null && customer.isActive == false) return false;
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = customer.name.toLowerCase().contains(query);
        final matchesPhone = customer.phoneNumber.contains(query);
        if (!matchesName && !matchesPhone) return false;
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
      if (_shiftFilter != null && (customer.shift ?? '') != _shiftFilter)
        return false;

      return true;
    }).toList();
  }

  void _showFilterBottomSheet() {
    // Capture the cubit before opening bottom sheet
    final cubit = context.read<DeliveryBoyCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _deliveryStatusFilter = null;
                            _areaFilter = null;
                            _subAreaFilter = null;
                          });
                          setModalState(() {});
                          cubit.loadCustomers();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Delivery Status Filter
                  const Text(
                    'Delivery Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _deliveryStatusFilter == null,
                        onSelected: () {
                          setState(() => _deliveryStatusFilter = null);
                          setModalState(() {});
                          cubit.loadCustomers();
                        },
                      ),
                      _FilterChip(
                        label: 'Delivered',
                        selected: _deliveryStatusFilter == 'delivered',
                        onSelected: () {
                          setState(() => _deliveryStatusFilter = 'delivered');
                          setModalState(() {});
                          cubit.loadCustomers(deliveryStatus: 'delivered');
                        },
                      ),
                      _FilterChip(
                        label: 'Pending',
                        selected: _deliveryStatusFilter == 'pending',
                        onSelected: () {
                          setState(() => _deliveryStatusFilter = 'pending');
                          setModalState(() {});
                          cubit.loadCustomers(deliveryStatus: 'pending');
                        },
                      ),
                      _FilterChip(
                        label: 'Not Delivered',
                        selected: _deliveryStatusFilter == 'notDelivered',
                        onSelected: () {
                          setState(
                            () => _deliveryStatusFilter = 'notDelivered',
                          );
                          setModalState(() {});
                          cubit.loadCustomers(deliveryStatus: 'notDelivered');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Shift',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _shiftFilter == null,
                        onSelected: () {
                          setState(() => _shiftFilter = null);
                          setModalState(() {});
                        },
                      ),
                      _FilterChip(
                        label: 'Morning',
                        selected: _shiftFilter == 'morning',
                        onSelected: () {
                          setState(() => _shiftFilter = 'morning');
                          setModalState(() {});
                        },
                      ),
                      _FilterChip(
                        label: 'Evening',
                        selected: _shiftFilter == 'evening',
                        onSelected: () {
                          setState(() => _shiftFilter = 'evening');
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),

                  if (_allAreas.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    const Text(
                      'Area',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _FilterChip(
                            label: 'All Areas',
                            selected: _areaFilter == null,
                            onSelected: () {
                              setState(() {
                                _areaFilter = null;
                                _subAreaFilter = null;
                              });
                              setModalState(() {});
                            },
                          ),
                          ..._allAreas.map(
                            (area) => _FilterChip(
                              label: area,
                              selected: _areaFilter == area,
                              onSelected: () {
                                setState(() {
                                  _areaFilter = area;
                                  _subAreaFilter = null;
                                });
                                setModalState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_allSubAreas.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    const Text(
                      'Sub Area',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _FilterChip(
                            label: 'All Sub Areas',
                            selected: _subAreaFilter == null,
                            onSelected: () {
                              setState(() => _subAreaFilter = null);
                              setModalState(() {});
                            },
                          ),
                          ..._allSubAreas.map(
                            (subArea) => _FilterChip(
                              label: subArea,
                              selected: _subAreaFilter == subArea,
                              onSelected: () {
                                setState(() => _subAreaFilter = subArea);
                                setModalState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_deliveryStatusFilter != null ||
                    _areaFilter != null ||
                    _subAreaFilter != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: BlocBuilder<DeliveryBoyCubit, DeliveryBoyState>(
        builder: (context, state) {
          if (state is DeliveryBoyCustomersLoading) {
            return const LoadingWidget(message: 'Loading customers...');
          }

          if (state is DeliveryBoyCustomersError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<DeliveryBoyCubit>().loadCustomers(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DeliveryBoyCustomersLoaded) {
            final customers = state.customers;
            _updateFilters(customers);
            _filteredCustomers = _filterCustomers(customers);

            return Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone number',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),

                // Active Filters Display
                if (_areaFilter != null || _subAreaFilter != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Text(
                          'Filters: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (_areaFilter != null)
                                Chip(
                                  label: Text(_areaFilter!),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() => _areaFilter = null);
                                  },
                                  labelStyle: const TextStyle(fontSize: 12),
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (_subAreaFilter != null)
                                Chip(
                                  label: Text(_subAreaFilter!),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() => _subAreaFilter = null);
                                  },
                                  labelStyle: const TextStyle(fontSize: 12),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Customer List
                Expanded(
                  child: _filteredCustomers.isEmpty
                      ? EmptyStateWidget(
                          message: _searchQuery.isNotEmpty
                              ? 'No customers found matching "$_searchQuery"'
                              : 'No customers found',
                          icon: Icons.people_outline,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<DeliveryBoyCubit>().loadCustomers(
                              deliveryStatus: _deliveryStatusFilter,
                            );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];
                              return _CustomerCard(
                                customer: customer,
                                onCall: () =>
                                    Helpers.makePhoneCall(customer.phoneNumber),
                                onLocation: () => Helpers.openMap(
                                  customer.locationLink,
                                  customer.latitude,
                                  customer.longitude,
                                ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onCall;
  final VoidCallback onLocation;

  const _CustomerCard({
    required this.customer,
    required this.onCall,
    required this.onLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntryScreen(customer: customer),
            ),
          );
          if (result == true) {
            context.read<DeliveryBoyCubit>().loadCustomers();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        (customer.shift != null
                                ? (customer.shift!.toLowerCase().contains('m')
                                      ? 'M'
                                      : (customer.shift!.toLowerCase().contains(
                                              'e',
                                            )
                                            ? 'E'
                                            : customer.name[0]))
                                : customer.name[0])
                            .toString()
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (customer.areaName != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  customer.subAreaName != null
                                      ? '${customer.areaName} • ${customer.subAreaName}'
                                      : customer.areaName!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (customer.todayDeliveryStatus != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: customer.todayDeliveryStatus!
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        customer.todayDeliveryStatus!
                            ? Icons.check_circle
                            : Icons.pending,
                        size: 16,
                        color: customer.todayDeliveryStatus!
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // Details Row
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.water_drop_outlined,
                      label: 'Qty',
                      value: Helpers.formatQuantity(customer.permanentQuantity),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (customer.totalPendingMoney != null)
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Pending',
                        value: Helpers.formatCurrency(
                          customer.totalPendingMoney!,
                        ),
                        color: AppColors.error,
                      ),
                    ),
                  if (customer.totalPendingMoney != null)
                    const SizedBox(width: 8),

                  // Action Buttons
                  IconButton(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: onLocation,
                    icon: const Icon(Icons.location_on),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
