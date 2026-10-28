import 'dart:convert';
import '../database/expense_database.dart';
import '../models/debt.dart';
import '../models/expense.dart';
import '../models/savings_goal.dart';

/// Backup Service for serializing and deserializing JSON backup payloads.
class BackupService {
  /// Exports all application data into a formatted JSON string backup payload.
  static Future<String> exportBackupJson() async {
    final db = ExpenseDatabase.instance;

    final expenses = await db.getAllExpenses();
    final savings = await db.getAllSavingsGoals();
    final debts = await db.getAllDebts();

    final Map<String, dynamic> backupMap = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'savings_goals': savings.map((s) => s.toMap()).toList(),
      'debts': debts.map((d) => d.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupMap);
  }

  /// Restores application database state from a JSON backup string payload.
  static Future<bool> restoreBackupJson(String jsonStr) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final db = ExpenseDatabase.instance;

      if (data.containsKey('expenses')) {
        final List<dynamic> expList = data['expenses'];
        for (var map in expList) {
          final expense = Expense.fromMap(Map<String, dynamic>.from(map));
          await db.insertExpense(expense);
        }
      }

      if (data.containsKey('savings_goals')) {
        final List<dynamic> savList = data['savings_goals'];
        for (var map in savList) {
          final goal = SavingsGoal.fromMap(Map<String, dynamic>.from(map));
          await db.insertSavingsGoal(goal);
        }
      }

      if (data.containsKey('debts')) {
        final List<dynamic> debtList = data['debts'];
        for (var map in debtList) {
          final debt = Debt.fromMap(Map<String, dynamic>.from(map));
          await db.insertDebt(debt);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
