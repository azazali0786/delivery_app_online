import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../widgets/common/loading_widget.dart';

class StockManagement extends StatelessWidget {
  const StockManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(context.read<AdminRepository>())..loadStockEntries(),
      child: const StockManagementView(),
    );
  }
}

class StockManagementView extends StatefulWidget {
  const StockManagementView({Key? key}) : super(key: key);

  @override
  State<StockManagementView> createState() => _StockManagementViewState();
}

class _StockManagementViewState extends State<StockManagementView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStockDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminCubit>().loadStockEntries(),
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
          if (state is StockLoading) {
            return const LoadingWidget(message: 'Loading stock...');
          }

          if (state is StockLoaded) {
            final stocks = state.stocks;
            if (stocks.isEmpty) {
              return const Center(child: Text('No stock entries found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                final stock = stocks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(stock.deliveryBoyName ?? 'Unknown'),
                    subtitle: Text(
                      'Half: ${stock.halfLtrBottles} | One: ${stock.oneLtrBottles}\nDate: ${stock.entryDate}',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
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
                              title: const Text('Delete Stock Entry'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.read<AdminCubit>().deleteStockEntry(
                                      stock.id,
                                    );
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
            );
          }

          if (state is StockError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddStockDialog(BuildContext context) {
    final halfLtrController = TextEditingController();
    final oneLtrController = TextEditingController();
    final collectedController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Stock Entry'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: halfLtrController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Half Liter Bottles',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: oneLtrController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'One Liter Bottles',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: collectedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Collected Bottles',
                  border: OutlineInputBorder(),
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<AdminCubit>().createStockEntry({
                  'half_ltr_bottles': int.parse(halfLtrController.text),
                  'one_ltr_bottles': int.parse(oneLtrController.text),
                  'collected_bottles': int.parse(collectedController.text),
                  'entry_date': Helpers.formatDateApi(DateTime.now()),
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
