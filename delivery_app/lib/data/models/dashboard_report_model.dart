// models/dashboard_data.dart

class Expense {
  final int? id;
  final String name;
  final double amount;
  final DateTime date;

  Expense({
    this.id,
    required this.name,
    required this.amount,
    required this.date,
  });
}

class DailyExpenseGroup {
  final DateTime date;
  final List<Expense> expenses;

  DailyExpenseGroup({required this.date, required this.expenses});

  double get totalAmount {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  String get dateString {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TotalData {
  int deliveryBoys;
  int customers;
  int profit;
  int pendingMoney;
  int leftBottles;
  int collection;

  TotalData({
    this.deliveryBoys = 0,
    this.customers = 0,
    this.profit = 0,
    this.pendingMoney = 0,
    this.leftBottles = 0,
    this.collection = 0,
  });
}

class TodayData {
  int online;
  int cash;
  int total;
  int pending;
  int expenses;
  int profit;

  TodayData({
    this.online = 0,
    this.cash = 0,
    this.total = 0,
    this.pending = 0,
    this.expenses = 0,
    this.profit = 0,
  });
}

class DashboardData {
  final TotalData totalData = TotalData();
  final TodayData todayData = TodayData();
  final List<Expense> expenseList = [];

  void addExpense(String name, double value, {DateTime? date, int? id}) {
    final d = date ?? DateTime.now();
    expenseList.add(Expense(id: id, name: name, amount: value, date: d));
    todayData.expenses = totalExpenseAmount.toInt();
    todayData.profit = todayData.total - todayData.expenses;
  }

  void removeExpense(int index) {
    if (index >= 0 && index < expenseList.length) {
      final expense = expenseList[index];
      todayData.expenses -= expense.amount.toInt();
      todayData.profit = todayData.total - todayData.expenses;
      expenseList.removeAt(index);
    }
  }

  void updateExpense(int index, String name, double amount) {
    if (index >= 0 && index < expenseList.length) {
      final oldAmount = expenseList[index].amount;
      expenseList[index] = Expense(
        name: name,
        amount: amount,
        date: expenseList[index].date,
      );

      // Update today's expenses
      todayData.expenses =
          todayData.expenses - oldAmount.toInt() + amount.toInt();
      todayData.profit = todayData.total - todayData.expenses;
    }
  }

  void removeDailyExpenses(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final expensesToRemove = expenseList
        .where(
          (expense) =>
              expense.date.isAfter(
                startOfDay.subtract(const Duration(seconds: 1)),
              ) &&
              expense.date.isBefore(endOfDay.add(const Duration(seconds: 1))),
        )
        .toList();

    for (var expense in expensesToRemove) {
      todayData.expenses -= expense.amount.toInt();
      expenseList.remove(expense);
    }

    todayData.profit = todayData.total - todayData.expenses;
  }

  List<DailyExpenseGroup> getDailyExpenseGroups() {
    Map<String, List<Expense>> groupedExpenses = {};

    for (var expense in expenseList) {
      final dateKey =
          '${expense.date.year}-${expense.date.month}-${expense.date.day}';
      if (!groupedExpenses.containsKey(dateKey)) {
        groupedExpenses[dateKey] = [];
      }
      groupedExpenses[dateKey]!.add(expense);
    }

    List<DailyExpenseGroup> groups = [];
    groupedExpenses.forEach((key, expenses) {
      groups.add(
        DailyExpenseGroup(date: expenses.first.date, expenses: expenses),
      );
    });

    // Sort by date descending (newest first)
    groups.sort((a, b) => b.date.compareTo(a.date));

    return groups;
  }

  double get totalExpenseAmount {
    return expenseList.fold(0, (sum, expense) => sum + expense.amount);
  }
}
