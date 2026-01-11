import 'package:flutter/material.dart';

class ExpenseItem {
  final TextEditingController nameController;
  final TextEditingController amountController;
  String? nameError;
  String? amountError;

  ExpenseItem()
    : nameController = TextEditingController(),
      amountController = TextEditingController();

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

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final List<ExpenseItem> _expenses = [ExpenseItem()];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    for (var expense in _expenses) expense.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addExpenseField() {
    setState(() {
      _expenses.add(ExpenseItem());
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
      if (!expense.validate()) allValid = false;
    }

    setState(() {});

    if (allValid) {
      final expensesList = _expenses.map((expense) {
        return {
          'name': expense.nameController.text,
          'amount': double.parse(expense.amountController.text),
        };
      }).toList();

      Navigator.of(context).pop(expensesList);
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (var expense in _expenses) {
      final amount = double.tryParse(expense.amountController.text);
      if (amount != null) total += amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expenses'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addExpenseField,
            icon: const Icon(Icons.add_circle),
            color: const Color(0xFF48BB78),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
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
                                color: const Color(0xFF4299E1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4299E1),
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
                            hintText: 'e.g., Petrol, Bijli Bill',
                            prefixIcon: const Icon(
                              Icons.edit,
                              color: Color(0xFF4299E1),
                              size: 20,
                            ),
                            errorText: expense.nameError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
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
                            prefixIcon: const Icon(
                              Icons.currency_rupee,
                              color: Color(0xFF48BB78),
                              size: 20,
                            ),
                            errorText: expense.amountError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
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
                },
              ),
            ),

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

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text('Add All (${_expenses.length})'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF4299E1),
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
}
