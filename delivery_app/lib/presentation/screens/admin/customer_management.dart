import 'package:delivery_app/data/models/area_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
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

            if (customers.isEmpty) {
              return const EmptyStateWidget(
                message: 'No customers found.',
                icon: Icons.people_outline,
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (value) {
                      context.read<AdminCubit>().loadCustomers(
                        search: value.isNotEmpty ? value : null,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminCubit>().loadCustomers();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onLongPress: () =>
                                _showApproveDialog(context, customer),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: Text(
                                customer.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(customer.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.phoneNumber),
                                if (customer.totalPendingMoney != null)
                                  Text(
                                    'Pending: ${Helpers.formatCurrency(customer.totalPendingMoney!)}',
                                    style: const TextStyle(
                                      color: AppColors.error,
                                    ),
                                  ),
                                SizedBox(height: 4),
                                Text(customer.subAreaName.toString()),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
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
                                } else if (value == 'edit') {
                                  _showEditDialog(context, customer);
                                }
                              },
                            ),
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

void _showApproveDialog(BuildContext context, dynamic customer) {
  final sortNumberController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  int? selectedAreaId;
  int? selectedSubAreaId;
  bool isActive = true;
  String shift = 'morning';

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text('Approve ${customer.name}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please assign Area, Sub-Area, Sort Number, shift and active status to approve this customer.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // Area Dropdown
                FutureBuilder<List<AreaModel>>(
                  future: context.read<AdminRepository>().getAllAreas(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final areas = snapshot.data!;

                    return DropdownButtonFormField<int>(
                      value: selectedAreaId,
                      decoration: const InputDecoration(
                        labelText: 'Select Area',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.public),
                      ),
                      items: areas.map((area) {
                        return DropdownMenuItem<int>(
                          value: area.id,
                          child: Text(area.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedAreaId = value;
                          selectedSubAreaId = null;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Please select an Area" : null,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Sub-Area
                if (selectedAreaId != null)
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _loadSubAreas(dialogContext),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const CircularProgressIndicator();
                      final allSubAreas = snapshot.data!;
                      final filtered = allSubAreas
                          .where((s) => s['area_id'] == selectedAreaId)
                          .toList();
                      if (filtered.isEmpty)
                        return const Text(
                          'No Sub-Areas available for this Area',
                        );

                      return DropdownButtonFormField<int>(
                        value: selectedSubAreaId,
                        decoration: const InputDecoration(
                          labelText: 'Select Sub-Area',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map),
                        ),
                        items: filtered.map((sub) {
                          return DropdownMenuItem<int>(
                            value: sub['id'],
                            child: Text(sub['name']),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedSubAreaId = value),
                        validator: (value) =>
                            value == null ? 'Please select a Sub-Area' : null,
                      );
                    },
                  ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: sortNumberController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Sort Number (10,5)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sort),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null)
                      return 'Must be a valid number';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Shift selection
                Row(
                  children: [
                    const Text('Shift:'),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Morning'),
                      selected: shift == 'morning',
                      onSelected: (_) =>
                          setDialogState(() => shift = 'morning'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Evening'),
                      selected: shift == 'evening',
                      onSelected: (_) =>
                          setDialogState(() => shift = 'evening'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Active toggle
                Row(
                  children: [
                    const Text('Status:'),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Active'),
                      selected: isActive,
                      onSelected: (_) => setDialogState(() => isActive = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('InActive'),
                      selected: !isActive,
                      onSelected: (_) => setDialogState(() => isActive = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // First update customer with shift/active if backend supports it
                final updateData = {
                  if (selectedSubAreaId != null)
                    'sub_area_id': selectedSubAreaId,
                  'sort_number':
                      double.tryParse(sortNumberController.text) ?? 0.0,
                  'is_active': isActive,
                  'shift': shift,
                };

                try {
                  await context.read<AdminRepository>().updateCustomer(
                    customer.id,
                    updateData,
                  );
                } catch (e) {
                  // ignore update failure but continue to approve if possible
                }

                Navigator.pop(ctx);

                context.read<AdminCubit>().approveCustomer(
                  customer.id,
                  selectedSubAreaId!,
                  double.parse(sortNumberController.text),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    ),
  );
}

void _showEditDialog(BuildContext context, dynamic customer) {
  final nameController = TextEditingController(text: customer.name);
  final phoneController = TextEditingController(text: customer.phoneNumber);
  final addressController = TextEditingController(text: customer.address ?? '');
  final whatsNUmController = TextEditingController(text: customer.whatsappNumber ?? '');
  final locationController = TextEditingController(
    text: customer.locationLink ?? '',
  );
  final permQtyController = TextEditingController(
    text: customer.permanentQuantity?.toString() ?? '0',
  );
  final formKey = GlobalKey<FormState>();

  bool isActive = customer.isActive ?? true;
  String shift = (customer.shift != null && (customer.shift == 'evening'))
      ? 'evening'
      : 'morning';

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text('Edit ${customer.name}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8,),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: whatsNUmController,
                  decoration: const InputDecoration(labelText: 'whatsapp Number'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location Link'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: permQtyController,
                  decoration: const InputDecoration(
                    labelText: 'Permanent Quantity',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                const Text('Shift:'),
const SizedBox(height: 8),
Wrap(
  spacing: 8,
  children: [
    ChoiceChip(
      label: const Text('Morning'),
      selected: shift == 'morning',
      onSelected: (_) {
        setDialogState(() => shift = 'morning');
      },
    ),
    ChoiceChip(
      label: const Text('Evening'),
      selected: shift == 'evening',
      onSelected: (_) {
        setDialogState(() => shift = 'evening');
      },
    ),
  ],
),
                const SizedBox(height: 12),
               const Text('Status:'),
const SizedBox(height: 8),
Wrap(
  spacing: 8,
  children: [
    ChoiceChip(
      label: const Text('Active'),
      selected: isActive,
      onSelected: (_) {
        setDialogState(() => isActive = true);
      },
    ),
    ChoiceChip(
      label: const Text('InActive'),
      selected: !isActive,
      onSelected: (_) {
        setDialogState(() => isActive = false);
      },
    ),
  ],
),

              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'name': nameController.text,
                'phone_number': phoneController.text,
                'address': addressController.text,
                'permanent_quantity':
                    double.tryParse(permQtyController.text) ?? 0,
                'is_active': isActive,
                'shift': shift,
                'whatsapp_number': whatsNUmController.text,
                'location_link': locationController.text,
              };
              try {
                await context.read<AdminRepository>().updateCustomer(
                  customer.id,
                  data,
                );
                Navigator.pop(ctx);
                // reload customers
                context.read<AdminCubit>().loadCustomers();
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Update failed: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

Future<List<Map<String, dynamic>>> _loadSubAreas(BuildContext context) async {
  try {
    final areas = await context.read<AdminRepository>().getAllAreas();
    final allSubAreas = <Map<String, dynamic>>[];

    for (final area in areas) {
      if (area.subAreas != null) {
        for (final subArea in area.subAreas!) {
          allSubAreas.add({
            'id': subArea.id,
            'name': subArea.name,
            'area_name': area.name,
            'area_id': area.id, // IMPORTANT for filtering
          });
        }
      }
    }
    return allSubAreas;
  } catch (e) {
    return [];
  }
}
