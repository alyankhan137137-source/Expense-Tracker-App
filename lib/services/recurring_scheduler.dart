import '../database/expense_database.dart';
import '../models/expense.dart';

/// Service for checking and auto-logging due recurring expenses.
class RecurringScheduler {
  /// Checks for recurring expenses and logs new instances if due.
  static Future<int> checkAndScheduleRecurringExpenses() async {
    final db = ExpenseDatabase.instance;
    final allExpenses = await db.getAllExpenses();

    final recurringItems = allExpenses.where((e) => e.recurrencePeriod != RecurrencePeriod.none).toList();
    int scheduledCount = 0;
    final now = DateTime.now();

    for (var item in recurringItems) {
      DateTime nextDue;
      switch (item.recurrencePeriod) {
        case RecurrencePeriod.daily:
          nextDue = item.date.add(const Duration(days: 1));
          break;
        case RecurrencePeriod.weekly:
          nextDue = item.date.add(const Duration(days: 7));
          break;
        case RecurrencePeriod.monthly:
          nextDue = DateTime(item.date.year, item.date.month + 1, item.date.day);
          break;
        case RecurrencePeriod.yearly:
          nextDue = DateTime(item.date.year + 1, item.date.month, item.date.day);
          break;
        case RecurrencePeriod.none:
          continue;
      }

      // If next due date has arrived and hasn't been logged today
      if (now.isAfter(nextDue) && nextDue.difference(item.date).inDays > 0) {
        final newRecord = item.copyWith(
          id: null,
          date: now,
        );
        await db.insertExpense(newRecord);
        scheduledCount++;
      }
    }

    return scheduledCount;
  }
}
