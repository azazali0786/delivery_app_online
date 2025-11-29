// widgets/edit_expense_dialog.dart
import 'package:flutter/material.dart';
import 'package:delivery_app/data/models/dashboard_report_model.dart';

class EditExpenseItem {
  final TextEditingController nameController;
  final TextEditingController amountController;
  String? nameError;
  String? amountError;
  final int originalIndex;

  EditExpenseItem({
    required String name,
    required double amount,
    required this.originalIndex,
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount.toString());

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }

  bool validate() {
    nameError = null;
    amountError = null;

    if (nameController.text.isEmpty) {
      nameError = 'Required';
      return false;
    }

    if (amountController.text.isEmpty) {
      amountError = 'Required';
      return false;
    }

    if (double.tryParse(amountController.text) == null) {
      amountError = 'Invalid';
      return false;
    }

    return true;
  }
}

class EditExpenseDialog extends StatefulWidget {
  final DailyExpenseGroup expenseGroup;
  final Function(List<Map<String, dynamic>> updatedExpenses) onExpensesUpdated;

  const EditExpenseDialog({
    Key? key,
    required this.expenseGroup,
    required this.onExpensesUpdated,
  }) : super(key: key);

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  late List<EditExpenseItem> _expenses;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _expenses = widget.expenseGroup.expenses
        .asMap()
        .entries
        .map((entry) => EditExpenseItem(
              name: entry.value.name,
              amount: entry.value.amount,
              originalIndex: entry.key,
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var expense in _expenses) {
      expense.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addExpenseField() {
    setState(() {
      _expenses.add(EditExpenseItem(
        name: '',
        amount: 0,
        originalIndex: -1, // New expense
      ));
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeExpenseField(int index) {
    if (_expenses.length > 1) {
      setState(() {
        _expenses[index].dispose();
        _expenses.removeAt(index);
      });
    }
  }

  void _submit() {
    bool allValid = true;
    for (var expense in _expenses) {
      if (!expense.validate()) {
        allValid = false;
      }
    }

    setState(() {});

    if (allValid) {
      final updatedExpenses = _expenses.map((expense) {
        return {
          'name': expense.nameController.text,
          'amount': double.parse(expense.amountController.text),
          'index': expense.originalIndex,
        };
      }).toList();

      widget.onExpensesUpdated(updatedExpenses);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFED8936).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFFED8936),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Expenses',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        widget.expenseGroup.dateString,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _addExpenseField,
                  icon: const Icon(Icons.add_circle),
                  color: const Color(0xFF48BB78),
                  iconSize: 28,
                  tooltip: 'Add More',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Expense List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  return _buildExpenseField(index);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Total Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Expenses:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    '₹${_calculateTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFED8936),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
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
                      'Cancel',
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED8936),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Update',
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
    );
  }

  Widget _buildExpenseField(int index) {
    final expense = _expenses[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFED8936).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFED8936),
                  ),
                ),
              ),
              const Spacer(),
              if (_expenses.length > 1)
                IconButton(
                  onPressed: () => _removeExpenseField(index),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFFF56565),
                  iconSize: 20,
                  tooltip: 'Remove',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: expense.nameController,
            decoration: InputDecoration(
              labelText: 'Expense Name',
              hintText: 'e.g., Pentrol, Bijli Bill',
              prefixIcon: const Icon(Icons.edit, color: Color(0xFFED8936), size: 20),
              errorText: expense.nameError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFED8936), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            onChanged: (_) {
              if (expense.nameError != null) {
                setState(() {
                  expense.nameError = null;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: expense.amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: 'e.g., 20, 35',
              prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF48BB78), size: 20),
              errorText: expense.amountError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF48BB78), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            onChanged: (_) {
              setState(() {
                expense.amountError = null;
              });
            },
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var expense in _expenses) {
      final amount = double.tryParse(expense.amountController.text);
      if (amount != null) {
        total += amount;
      }
    }
    return total;
  }
}