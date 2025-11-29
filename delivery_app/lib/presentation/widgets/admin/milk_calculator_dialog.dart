// widgets/milk_calculator_dialog.dart
import 'package:flutter/material.dart';

class MilkCalculatorDialog extends StatefulWidget {
  const MilkCalculatorDialog({Key? key}) : super(key: key);

  @override
  State<MilkCalculatorDialog> createState() => _MilkCalculatorDialogState();
}

class _MilkCalculatorDialogState extends State<MilkCalculatorDialog> {
  final _quantityController = TextEditingController();
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();
  final _requiredFatController = TextEditingController();
  final _requiredSnfController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _result = '';
  double _waterToAdd = 0;
  String _targetType = ''; // 'fat' or 'snf'

  @override
  void dispose() {
    _quantityController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _requiredFatController.dispose();
    _requiredSnfController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final quantity = double.parse(_quantityController.text);
      final currentFat = double.parse(_fatController.text);
      final currentSnf = double.parse(_snfController.text);
      
      final requiredFat = _requiredFatController.text.isNotEmpty 
          ? double.parse(_requiredFatController.text) 
          : null;
      final requiredSnf = _requiredSnfController.text.isNotEmpty 
          ? double.parse(_requiredSnfController.text) 
          : null;

      if (requiredFat == null && requiredSnf == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter either required Fat or SNF'),
            backgroundColor: Color(0xFFF56565),
          ),
        );
        return;
      }

      if (requiredFat != null && requiredSnf != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter only one: either Fat OR SNF'),
            backgroundColor: Color(0xFFF56565),
          ),
        );
        return;
      }

      double waterNeeded = 0;
      String type = '';

      if (requiredFat != null) {
        // Calculate water needed to achieve required fat percentage
        // Formula: Water = (Current_Fat * Quantity / Required_Fat) - Quantity
        if (requiredFat >= currentFat) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Required fat must be less than current fat'),
              backgroundColor: Color(0xFFF56565),
            ),
          );
          return;
        }
        waterNeeded = (currentFat * quantity / requiredFat) - quantity;
        type = 'Fat';
      } else if (requiredSnf != null) {
        // Calculate water needed to achieve required SNF percentage
        // Formula: Water = (Current_SNF * Quantity / Required_SNF) - Quantity
        if (requiredSnf >= currentSnf) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Required SNF must be less than current SNF'),
              backgroundColor: Color(0xFFF56565),
            ),
          );
          return;
        }
        waterNeeded = (currentSnf * quantity / requiredSnf) - quantity;
        type = 'SNF';
      }

      setState(() {
        _waterToAdd = waterNeeded;
        _targetType = type;
        _result = 'calculated';
      });
    }
  }

  void _clearForm() {
    setState(() {
      _quantityController.clear();
      _fatController.clear();
      _snfController.clear();
      _requiredFatController.clear();
      _requiredSnfController.clear();
      _result = '';
      _waterToAdd = 0;
      _targetType = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9F7AEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calculate,
                        color: Color(0xFF9F7AEA),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Milk Balance Calculator',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Calculate water needed to balance milk',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Milk Quantity
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total Milk Quantity (Ltr)',
                    hintText: 'e.g., 100',
                    prefixIcon: const Icon(Icons.local_drink, color: Color(0xFF4299E1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4299E1), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7FAFC),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Current Fat
                TextFormField(
                  controller: _fatController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Current Fat (gm/100ml)',
                    hintText: 'e.g., 7.7',
                    prefixIcon: const Icon(Icons.opacity, color: Color(0xFFED8936)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFED8936), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7FAFC),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Current SNF
                TextFormField(
                  controller: _snfController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Current SNF (gm/100ml)',
                    hintText: 'e.g., 9.2',
                    prefixIcon: const Icon(Icons.water_drop, color: Color(0xFF48BB78)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF48BB78), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7FAFC),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Section Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9F7AEA),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Required (Fill only ONE)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Required Fat
                TextFormField(
                  controller: _requiredFatController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Required Fat (gm/100ml)',
                    hintText: 'Optional - Fill Fat OR SNF',
                    prefixIcon: const Icon(Icons.opacity_outlined, color: Color(0xFFED8936)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFED8936), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFFAF5),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Required SNF
                TextFormField(
                  controller: _requiredSnfController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Required SNF (gm/100ml)',
                    hintText: 'Optional - Fill Fat OR SNF',
                    prefixIcon: const Icon(Icons.water_drop_outlined, color: Color(0xFF48BB78)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF48BB78), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5FFF9),
                  ),
                ),
                
                if (_result.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667EEA).withOpacity(0.1),
                          const Color(0xFF9F7AEA).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF48BB78).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF48BB78),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Calculation Result',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.water,
                                    color: Color(0xFF4299E1),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_waterToAdd.toStringAsFixed(2)} Ltr',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4299E1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Water to add for required $_targetType',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFAF0),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFED8936).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFED8936),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Final quantity: ${(double.parse(_quantityController.text) + _waterToAdd).toStringAsFixed(2)} Ltr',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2D3748),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (_result.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            foregroundColor: const Color(0xFF718096),
                          ),
                        ),
                      ),
                    if (_result.isNotEmpty) const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9F7AEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Calculate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}