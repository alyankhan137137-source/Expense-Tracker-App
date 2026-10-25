import '../models/expense.dart';
import '../models/expense_category.dart';

/// Instant, zero-dependency Local Storage Manager pre-seeded with mock data for instant loading across Web, Mobile, and Desktop.
class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();

  static int _nextId = 6;
  static final List<Expense> _expenses = [
    Expense(
      id: 1,
      title: 'Weekly Grocery Shopping',
      amount: 124.50,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      category: ExpenseCategory.food,
    ),
    Expense(
      id: 2,
      title: 'Monthly Electric Bill',
      amount: 85.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: ExpenseCategory.bills,
    ),
    Expense(
      id: 3,
      title: 'Uber Ride to Office',
      amount: 22.50,
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: ExpenseCategory.transport,
    ),
    Expense(
      id: 4,
      title: 'Movie Tickets & Popcorn',
      amount: 38.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: ExpenseCategory.entertainment,
    ),
    Expense(
      id: 5,
      title: 'Pharmacy & Vitamins',
      amount: 45.00,
      date: DateTime.now().subtract(const Duration(days: 4)),
      category: ExpenseCategory.health,
    ),
  ];

  ExpenseDatabase._init();

  /// Inserts a new expense record.
  Future<Expense> insertExpense(Expense expense) async {
    final newExpense = expense.copyWith(id: _nextId++);
    _expenses.add(newExpense);
    return newExpense;
  }

  /// Fetches all expense records, sorted chronologically descending.
  Future<List<Expense>> getAllExpenses() async {
    final sortedList = List<Expense>.from(_expenses);
    sortedList.sort((a, b) => b.date.compareTo(a.date));
    return sortedList;
  }

  /// Updates an existing expense record by ID.
  Future<int> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      return 1;
    }
    return 0;
  }

  /// Deletes an expense record by ID.
  Future<int> deleteExpense(int id) async {
    final initialLength = _expenses.length;
    _expenses.removeWhere((e) => e.id == id);
    return initialLength - _expenses.length;
  }

  /// Calculates the total sum of all recorded expenses.
  Future<double> getTotalSpending() async {
    double total = 0.0;
    for (var expense in _expenses) {
      total += expense.amount;
    }
    return total;
  }

  /// Calculates a map of spending per category.
  Future<Map<ExpenseCategory, double>> getCategoryBreakdown() async {
    final Map<ExpenseCategory, double> breakdown = {};
    for (var expense in _expenses) {
      breakdown[expense.category] = (breakdown[expense.category] ?? 0.0) + expense.amount;
    }
    return breakdown;
  }

  /// Closes database connection.
  Future<void> close() async {}
}
