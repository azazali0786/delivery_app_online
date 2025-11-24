import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

class CustomerManagement extends StatelessWidget {
  const CustomerManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(context.read<AdminRepository>())
        ..loadCustomers(),
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
                  const Icon(Icons.error_outline, size: 60, color: AppColors.error),
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
                            onLongPress: () => _showApproveDialog(context, customer),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
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
                                    style: const TextStyle(color: AppColors.error),
                                  ),
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
                                            context.read<AdminCubit>().deleteCustomer(customer.id);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: AppColors.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
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
    final subAreaController = TextEditingController();
    final sortNumberController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Approve ${customer.name}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please assign a Sub-Area and Sort Number to approve this customer.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Sub Area ID Input
              TextFormField(
                controller: subAreaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sub Area ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Sort Number Input
              TextFormField(
                controller: sortNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sort Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sort),
                  helperText: 'Order in the delivery list',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
            ],
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Close the dialog
                Navigator.pop(ctx);
                
                // Call the Cubit
                context.read<AdminCubit>().approveCustomer(
                      customer.id,
                      int.parse(subAreaController.text),
                      int.parse(sortNumberController.text),
                    );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }