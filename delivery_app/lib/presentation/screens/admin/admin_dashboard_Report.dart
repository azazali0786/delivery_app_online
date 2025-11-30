// admin_dashboard_page.dart
import 'package:delivery_app/data/models/dashboard_report_model.dart';
import 'package:delivery_app/presentation/widgets/admin/data_row_widget.dart';
import 'package:delivery_app/presentation/widgets/admin/expense_dialog.dart';
import 'package:delivery_app/presentation/widgets/admin/edit_expense_dialog.dart';
import 'package:delivery_app/presentation/widgets/admin/milk_calculator_dialog.dart';
import 'package:delivery_app/presentation/widgets/admin/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/data/repositories/admin_repository.dart';

class AdminDashboardReport extends StatefulWidget {
  const AdminDashboardReport({Key? key}) : super(key: key);

  @override
  State<AdminDashboardReport> createState() => _AdminDashboardReportState();
}

class _AdminDashboardReportState extends State<AdminDashboardReport> {
  DateTime selectedDate = DateTime.now();
  final DashboardData data = DashboardData();
  bool _loading = false;

  String _fmtDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  bool _hasExpensesForSelectedDate() {
    final selectedDayStart = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final selectedDayEnd = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    return data.expenseList.any((expense) {
      return expense.date.isAfter(
            selectedDayStart.subtract(const Duration(seconds: 1)),
          ) &&
          expense.date.isBefore(selectedDayEnd.add(const Duration(seconds: 1)));
    });
  }

  // Get total expenses for selected date
  double _getSelectedDateExpenses() {
    final selectedDayStart = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final selectedDayEnd = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    return data.expenseList
        .where((expense) =>
            expense.date.isAfter(
              selectedDayStart.subtract(const Duration(seconds: 1)),
            ) &&
            expense.date.isBefore(selectedDayEnd.add(const Duration(seconds: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData({String? dateStr}) async {
    setState(() {
      _loading = true;
    });
    try {
      final repo = context.read<AdminRepository>();
      // fetch report with optional date parameter
      final report = await repo.getDashboardReport(date: dateStr);
      if (report != null) {
        final total = report['total'] ?? {};
        final dateData = report['date'] ?? {};
        setState(() {
          // Total data
          data.totalData.collection = (total['collection'] ?? 0).toInt();
          data.totalData.leftBottles = (total['leftBottles'] ?? 0).toInt();
          data.totalData.profit = ((total['total_profit'] ?? 0)).toInt();
          data.totalData.deliveryBoys = (total['delivery_boys'] ?? 0).toInt();
          data.totalData.customers = (total['customers'] ?? 0).toInt();
          data.totalData.pendingMoney = (total['pending_money'] ?? 0).toInt();

          // Selected date data
          data.todayData.online = (dateData['online'] ?? 0).toInt();
          data.todayData.cash = (dateData['cash'] ?? 0).toInt();
          data.todayData.total = (dateData['total'] ?? 0).toInt();
          data.todayData.pending = (dateData['pending'] ?? 0).toInt();
          data.todayData.expenses = (dateData['expenses'] ?? 0).toInt();
          data.todayData.profit = (dateData['profit'] ?? 0).toInt();
        });
      }

      // fetch expenses (all)
      final expenses = await repo.getExpenses();
      setState(() {
        data.expenseList.clear();
        for (final e in expenses) {
          try {
            final date = DateTime.parse(e['expense_date']);
            data.expenseList.add(Expense(
              id: e['id'],
              name: e['name'],
              amount: (e['amount'] is num)
                  ? (e['amount'].toDouble())
                  : double.parse(e['amount'].toString()),
              date: date,
            ));
          } catch (_) {}
        }
      });
    } catch (e) {
      // ignore for now
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => ExpenseDialog(
        onExpenseAdded: (expenses) {
          // Persist to backend and refresh
          () async {
            final repo = context.read<AdminRepository>();
            final List<Map<String, dynamic>> toSend = [];
            for (var expense in expenses) {
              toSend.add({
                'name': expense['name'],
                'amount': expense['amount'],
                'expense_date': _fmtDate(selectedDate),
              });
            }
            try {
              final inserted = await repo.createExpenses(toSend);
              setState(() {
                for (final e in inserted) {
                  try {
                    final date = DateTime.parse(e['expense_date']);
                    data.expenseList.add(Expense(
                      id: e['id'],
                      name: e['name'],
                      amount: (e['amount'] is num)
                          ? (e['amount'].toDouble())
                          : double.parse(e['amount'].toString()),
                      date: date,
                    ));
                  } catch (_) {}
                }
              });
              // Reload to get updated stats
              _loadData(dateStr: _fmtDate(selectedDate));
            } catch (e) {
              // ignore errors for now
            }
          }();
        },
      ),
    );
  }

  void _showMilkCalculator() {
    showDialog(
      context: context,
      builder: (context) => const MilkCalculatorDialog(),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Reload data for the selected date
      _loadData(dateStr: _fmtDate(picked));
    }
  }

  void _showDeleteDayConfirmation(DateTime date) {
    // Get repository reference before showing dialog
    final repo = context.read<AdminRepository>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete All Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        content: Text(
          'Are you sure you want to delete all expenses for ${date.day}/${date.month}/${date.year}?',
          style: const TextStyle(color: Color(0xFF718096)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // Close dialog first
              
              try {
                // Delete from backend
                await repo.deleteExpensesByDate(_fmtDate(date));
                
                // Remove from local data
                setState(() {
                  data.expenseList.removeWhere((expense) {
                    final expenseDate = DateTime(
                      expense.date.year,
                      expense.date.month,
                      expense.date.day,
                    );
                    final targetDate = DateTime(date.year, date.month, date.day);
                    return expenseDate.isAtSameMomentAs(targetDate);
                  });
                });
                
                // Reload data to refresh stats
                await _loadData(dateStr: _fmtDate(selectedDate));
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All expenses deleted successfully'),
                      backgroundColor: Color(0xFF48BB78),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting expenses: $e'),
                      backgroundColor: const Color(0xFFF56565),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF56565),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showEditExpenseDialog(DailyExpenseGroup group) {
    // Get repository reference before showing dialog
    final repo = context.read<AdminRepository>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => EditExpenseDialog(
        expenseGroup: group,
        onExpensesUpdated: (updatedExpenses) async {
          try {
            // Format the date properly - should be YYYY-MM-DD
            final dateStr = _fmtDate(group.date);
            
            print('Deleting expenses for date: $dateStr'); // Debug log
            
            // Delete existing expenses for this date
            await repo.deleteExpensesByDate(dateStr);
            
            print('Creating ${updatedExpenses.length} new expenses'); // Debug log
            
            // Create new expenses with updated values
            final toSend = updatedExpenses
                .map((e) => {
                      'name': e['name'],
                      'amount': e['amount'],
                      'expense_date': dateStr,
                    })
                .toList();

            final inserted = await repo.createExpenses(
              List<Map<String, dynamic>>.from(toSend),
            );

            // Update local data - remove old expenses for this date
            if (mounted) {
              setState(() {
                data.expenseList.removeWhere((expense) {
                  final expenseDate = DateTime(
                    expense.date.year,
                    expense.date.month,
                    expense.date.day,
                  );
                  final targetDate = DateTime(
                    group.date.year,
                    group.date.month,
                    group.date.day,
                  );
                  return expenseDate.isAtSameMomentAs(targetDate);
                });

                // Add new expenses
                for (final e in inserted) {
                  try {
                    final date = DateTime.parse(e['expense_date']);
                    data.expenseList.add(Expense(
                      id: e['id'],
                      name: e['name'],
                      amount: (e['amount'] is num)
                          ? (e['amount'].toDouble())
                          : double.parse(e['amount'].toString()),
                      date: date,
                    ));
                  } catch (_) {}
                }
              });

              // Reload data to refresh stats
              await _loadData(dateStr: _fmtDate(selectedDate));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expenses updated successfully'),
                  backgroundColor: Color(0xFF48BB78),
                ),
              );
            }
          } catch (e) {
            print('Error updating expenses: $e'); // Debug log
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating expenses: $e'),
                  backgroundColor: const Color(0xFFF56565),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calculate_outlined,
              color: Color(0xFF4299E1),
            ),
            tooltip: 'Milk Calculator',
            onPressed: _showMilkCalculator,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Data Section
                  _buildSectionHeader('Total Overview'),
                  const SizedBox(height: 16),
                  _buildTotalDataCards(),
                  const SizedBox(height: 32),

                  // Today's Data Section
                  _buildSectionHeader('Day\'s Summary'),
                  const SizedBox(height: 8),
                  _buildDateFilter(),
                  const SizedBox(height: 16),
                  _buildTodayDataCards(),
                  const SizedBox(height: 24),
                  
                  // Expense section for selected date
                  if (_hasExpensesForSelectedDate()) ...[
                    _buildSectionHeader(
                      'Expenses',
                    ),
                    const SizedBox(height: 16),
                    _buildExpenseList(),
                    const SizedBox(height: 24),
                  ],
                  
                  _buildAddExpenseButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildTotalDataCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Delivery Boys',
                value: '${data.totalData.deliveryBoys}',
                icon: Icons.delivery_dining,
                color: const Color(0xFF667EEA),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: 'Customers',
                value: '${data.totalData.customers}',
                icon: Icons.people,
                color: const Color(0xFF48BB78),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: 'Profit',
                value: '₹${data.totalData.profit + data.totalData.pendingMoney}',
                icon: Icons.trending_up,
                color: const Color(0xFFED8936),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              DataRowWidget(
                label: 'Collection',
                value: '₹${data.totalData.collection}',
                valueColor: const Color(0xFF48BB78),
              ),
              const Divider(height: 24),
              DataRowWidget(
                label: 'Pending',
                value: '₹${data.totalData.pendingMoney}',
                valueColor: const Color(0xFFF56565),
              ),
              const Divider(height: 24),
              DataRowWidget(
                label: 'Expenses',
                value: '₹${data.totalData.collection - data.totalData.profit}',
                valueColor: const Color(0xFFF59E0B),
              ),
              const Divider(height: 24),
              DataRowWidget(
                label: 'Left Bottles',
                value: '${data.totalData.leftBottles}',
                valueColor: const Color(0xFF4299E1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Color(0xFF4299E1)),
          const SizedBox(width: 12),
          Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _selectDate,
            child: const Text('Change Date'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayDataCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Online',
                value: '₹${data.todayData.online}',
                icon: Icons.payment,
                color: const Color(0xFF9F7AEA),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: 'Cash',
                value: '₹${data.todayData.cash}',
                icon: Icons.money,
                color: const Color(0xFF38B2AC),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: 'Total',
                value: '₹${data.todayData.total}',
                icon: Icons.account_balance_wallet,
                color: const Color(0xFFED8936),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              DataRowWidget(
                label: 'Pending',
                value: '₹${data.todayData.pending}',
                valueColor: const Color(0xFFF56565),
              ),
              const Divider(height: 24),
              DataRowWidget(
                label: 'Expenses',
                value: '₹${data.todayData.expenses}',
                valueColor: const Color(0xFFED8936),
              ),
              const Divider(height: 24),
              DataRowWidget(
                label: 'Profit',
                value: '₹${data.todayData.profit + data.todayData.pending}',
                valueColor: const Color(0xFF48BB78),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddExpenseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showExpenseDialog,
        icon: const Icon(Icons.add_circle_outline),
        label: Text(
          'Add Expense for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4299E1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    // Get expenses only for selected date
    final selectedDayStart = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final selectedDayEnd = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    final expensesForSelectedDate = data.expenseList.where((expense) {
      return expense.date.isAfter(
            selectedDayStart.subtract(const Duration(seconds: 1)),
          ) &&
          expense.date.isBefore(selectedDayEnd.add(const Duration(seconds: 1)));
    }).toList();

    if (expensesForSelectedDate.isEmpty) {
      return const SizedBox.shrink();
    }

    final group = DailyExpenseGroup(
      date: selectedDate,
      expenses: expensesForSelectedDate,
    );

    return _buildDailyExpenseCard(group);
  }

  Widget _buildDailyExpenseCard(DailyExpenseGroup group) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with date and actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFED8936).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFED8936).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFED8936),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.dateString,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        '${group.expenses.length} expense${group.expenses.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                Column(
                  children: [
                    Text(
                  '₹${group.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFED8936),
                  ),
                ),
                    Row(
                      children: [
                        IconButton(
                      onPressed: () => _showEditExpenseDialog(group),
                      icon: const Icon(Icons.edit),
                      color: const Color(0xFF4299E1),
                      tooltip: 'Edit Day Expenses',
                    ),
                    IconButton(
                      onPressed: () => _showDeleteDayConfirmation(group.date),
                      icon: const Icon(Icons.delete_outline),
                      color: const Color(0xFFF56565),
                      tooltip: 'Delete All Day Expenses',
                    ),
                      ],
                    ),
                  ],
                ),
                
              ],
            ),
          ),

          // Expense items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: group.expenses.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final expense = group.expenses[index];
              return _buildExpenseItem(expense);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF718096).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt, color: Color(0xFF718096), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            expense.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        Text(
          '₹${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}