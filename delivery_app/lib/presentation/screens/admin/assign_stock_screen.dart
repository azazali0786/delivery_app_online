import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../widgets/common/loading_widget.dart';

class AssignStockScreen extends StatelessWidget {
  const AssignStockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(context.read<AdminRepository>())..loadDeliveryBoys(),
      child: const AssignStockView(),
    );
  }
}

class AssignStockView extends StatefulWidget {
  const AssignStockView({Key? key}) : super(key: key);

  @override
  State<AssignStockView> createState() => _AssignStockViewState();
}

class _AssignStockViewState extends State<AssignStockView> {
  int? _selectedDeliveryBoyId;
  final _halfLtrController = TextEditingController();
  final _oneLtrController = TextEditingController();
  final _collectedController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _halfLtrController.dispose();
    _oneLtrController.dispose();
    _collectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Stock to Delivery Boys')),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            _clearForm();
            context.read<AdminCubit>().loadDeliveryBoys();
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
          if (state is DeliveryBoysLoading) {
            return const LoadingWidget(message: 'Loading delivery boys...');
          }

          if (state is DeliveryBoysLoaded) {
            final deliveryBoys = state.deliveryBoys;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select Delivery Boy
                    const Text(
                      'Select Delivery Boy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedDeliveryBoyId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintText: 'Choose a delivery boy',
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: deliveryBoys.map((boy) {
                        return DropdownMenuItem<int>(
                          value: boy.id,
                          child: Text(boy.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDeliveryBoyId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a delivery boy';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Stock Entry Form
                    const Text(
                      'Stock Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Half Liter Bottles
                    TextFormField(
                      controller: _halfLtrController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Half Liter Bottles',
                        hintText: 'e.g., 10',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.local_drink),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter half liter bottles count';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // One Liter Bottles
                    TextFormField(
                      controller: _oneLtrController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'One Liter Bottles',
                        hintText: 'e.g., 5',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.local_drink),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter one liter bottles count';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Collected Bottles
                    TextFormField(
                      controller: _collectedController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Collected Bottles',
                        hintText: 'e.g., 8',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.local_drink),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter collected bottles count';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitStock,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Assign Stock',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DeliveryBoysError) {
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
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminCubit>().loadDeliveryBoys();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _submitStock() {
    if (_formKey.currentState!.validate()) {
      context.read<AdminCubit>().createStockEntry({
        'delivery_boy_id': _selectedDeliveryBoyId,
        'half_ltr_bottles': int.parse(_halfLtrController.text),
        'one_ltr_bottles': int.parse(_oneLtrController.text),
        'collected_bottles': int.parse(_collectedController.text),
        'entry_date': Helpers.formatDateApi(DateTime.now()),
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _selectedDeliveryBoyId = null;
    _halfLtrController.clear();
    _oneLtrController.clear();
    _collectedController.clear();
  }
}
