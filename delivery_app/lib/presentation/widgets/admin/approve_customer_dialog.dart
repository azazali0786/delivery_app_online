// lib/presentation/widgets/admin/approve_customer_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/area_model.dart';
import '../../../data/models/customer_model.dart';

class ApproveCustomerDialog extends StatefulWidget {
  final CustomerModel customer;
  final AdminRepository repository;

  const ApproveCustomerDialog({
    Key? key,
    required this.customer,
    required this.repository,
  }) : super(key: key);

  @override
  State<ApproveCustomerDialog> createState() => _ApproveCustomerDialogState();
}

class _ApproveCustomerDialogState extends State<ApproveCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sortNumberController = TextEditingController();

  int? _selectedAreaId;
  int? _selectedSubAreaId;
  bool _isActive = true;
  String _shift = 'morning';
  List<AreaModel> _areas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  @override
  void dispose() {
    _sortNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await widget.repository.getAllAreas();
      setState(() {
        _areas = areas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Update customer with additional details
    final updateData = {
      if (_selectedSubAreaId != null) 'sub_area_id': _selectedSubAreaId,
      'sort_number': double.tryParse(_sortNumberController.text) ?? 0.0,
      'is_active': _isActive,
      'shift': _shift,
    };

    try {
      await widget.repository.updateCustomer(
        widget.customer.id,
        updateData,
      );
    } catch (e) {
      // Continue to approve even if update fails
    }

    Navigator.pop(context);

    context.read<AdminCubit>().approveCustomer(
          widget.customer.id,
          _selectedSubAreaId!,
          double.parse(_sortNumberController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Approve Customer',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.customer.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  // Area Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedAreaId,
                    decoration: InputDecoration(
                      labelText: 'Select Area *',
                      prefixIcon: const Icon(Icons.public),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _areas.map((area) {
                      return DropdownMenuItem<int>(
                        value: area.id,
                        child: Text(area.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAreaId = value;
                        _selectedSubAreaId = null;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select an area' : null,
                  ),
                  const SizedBox(height: 16),

                  // Sub-Area Dropdown
                  if (_selectedAreaId != null)
                    DropdownButtonFormField<int>(
                      value: _selectedSubAreaId,
                      decoration: InputDecoration(
                        labelText: 'Select Sub-Area *',
                        prefixIcon: const Icon(Icons.map),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _areas
                          .firstWhere((a) => a.id == _selectedAreaId)
                          .subAreas
                          ?.map((subArea) {
                        return DropdownMenuItem<int>(
                          value: subArea.id,
                          child: Text(subArea.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSubAreaId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Please select a sub-area' : null,
                    ),
                  if (_selectedAreaId != null) const SizedBox(height: 16),

                  // Sort Number
                  TextFormField(
                    controller: _sortNumberController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Sort Number *',
                      hintText: 'e.g., 1, 1.5, 2',
                      prefixIcon: const Icon(Icons.sort),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Must be a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Shift Selection
                  const Text(
                    'Shift',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Morning'),
                          selected: _shift == 'morning',
                          onSelected: (_) =>
                              setState(() => _shift = 'morning'),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Evening'),
                          selected: _shift == 'evening',
                          onSelected: (_) =>
                              setState(() => _shift = 'evening'),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Active Status
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Active'),
                          selected: _isActive,
                          onSelected: (_) => setState(() => _isActive = true),
                          selectedColor: AppColors.success.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Inactive'),
                          selected: !_isActive,
                          onSelected: (_) => setState(() => _isActive = false),
                          selectedColor: AppColors.error.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}