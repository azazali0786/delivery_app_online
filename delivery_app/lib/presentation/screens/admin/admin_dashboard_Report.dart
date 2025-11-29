// admin_dashboard_page.dart
import 'package:delivery_app/data/models/dashboard_report_model.dart';
import 'package:delivery_app/presentation/widgets/admin/data_row_widget.dart';
import 'package:delivery_app/presentation/widgets/admin/expense_dialog.dart';
import 'package:delivery_app/presentation/widgets/admin/edit_expense_dialog.dart';
import 'package:delivery_app/presentation/widgets/admin/milk_calculator_dialog.dart';
import 'package:delivery_app/presentation/widgets/admin/stats_card.dart';
import 'package:flutter/material.dart';

class AdminDashboardReport extends StatefulWidget {
  const AdminDashboardReport({Key? key}) : super(key: key);

  @override
  State<AdminDashboardReport> createState() => _AdminDashboardReportState();
}

class _AdminDashboardReportState extends State<AdminDashboardReport> {
  DateTime selectedDate = DateTime.now();
  final DashboardData data = DashboardData();

  void _showExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => ExpenseDialog(
        onExpenseAdded: (expenses) {
          setState(() {
            for (var expense in expenses) {
              data.addExpense(expense['name'], expense['amount']);
            }
          });
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
    }
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Expense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this expense?',
          style: TextStyle(color: Color(0xFF718096)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                data.removeExpense(index);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF56565),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDayConfirmation(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete All Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete all expenses for this day?',
          style: TextStyle(color: Color(0xFF718096)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                data.removeDailyExpenses(date);
              });
              Navigator.of(context).pop();
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
    showDialog(
      context: context,
      builder: (context) => EditExpenseDialog(
        expenseGroup: group,
        onExpensesUpdated: (updatedExpenses) {
          setState(() {
            // Remove old expenses for this day
            data.removeDailyExpenses(group.date);
            
            // Add updated expenses
            for (var expense in updatedExpenses) {
              data.addExpense(expense['name'], expense['amount']);
            }
          });
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
            icon: const Icon(Icons.calculate_outlined, color: Color(0xFF4299E1)),
            tooltip: 'Milk Calculator',
            onPressed: _showMilkCalculator,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
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
            _buildSectionHeader('Today\'s Summary'),
            const SizedBox(height: 8),
            _buildDateFilter(),
            const SizedBox(height: 16),
            _buildTodayDataCards(),
            const SizedBox(height: 24),
            _buildAddExpenseButton(),
            const SizedBox(height: 32),
            
            // Expense List Section
            if (data.expenseList.isNotEmpty) ...[
              _buildSectionHeader('Expense List'),
              const SizedBox(height: 16),
              _buildExpenseList(),
            ],
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
                value: '₹${data.totalData.profit}',
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
                label: 'Pending Money',
                value: '₹${data.totalData.pendingMoney}',
                valueColor: const Color(0xFFF56565),
              ),
              const Divider(height: 24),
              DataRowWidget(
                label: 'Left Bottles',
                value: '${data.totalData.leftBottles}',
                valueColor: const Color(0xFF4299E1),
              ),
              const Divider(height: 24),
              DataRowWidget(
                label: 'Collection',
                value: '₹${data.totalData.collection}',
                valueColor: const Color(0xFF48BB78),
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
                value: '₹${data.todayData.profit}',
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
        label: const Text(
          'Add Expense',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    final dailyGroups = data.getDailyExpenseGroups();
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dailyGroups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final group = dailyGroups[index];
        return _buildDailyExpenseCard(group);
      },
    );
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
                Text(
                  '₹${group.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFED8936),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showEditExpenseDialog(group),
                  icon: const Icon(Icons.edit),
                  color: const Color(0xFF4299E1),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _showDeleteDayConfirmation(group.date),
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFF56565),
                  tooltip: 'Delete All',
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
          child: const Icon(
            Icons.receipt,
            color: Color(0xFF718096),
            size: 18,
          ),
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