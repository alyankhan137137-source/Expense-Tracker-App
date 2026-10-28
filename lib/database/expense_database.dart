import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/debt.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/savings_goal.dart';

/// Comprehensive Production SQLite Database Manager with automated Web & Memory fallback.
class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;
  static bool _isMemoryFallback = false;

  // In-memory fallback stores
  static final List<Expense> _memoryExpenses = [
    Expense(
      id: 1,
      title: 'Weekly Grocery Shopping',
      amount: 124.50,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      category: ExpenseCategory.food,
      transactionType: TransactionType.expense,
      tags: ['groceries'],
    ),
    Expense(
      id: 2,
      title: 'Monthly Salary Income',
      amount: 3200.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: ExpenseCategory.salary,
      transactionType: TransactionType.income,
      tags: ['salary', 'work'],
    ),
  ];
  static final List<SavingsGoal> _memorySavings = [
    SavingsGoal(
      id: 1,
      title: 'Emergency Reserve Fund',
      targetAmount: 5000.0,
      currentAmount: 2400.0,
      color: Colors.indigo,
    ),
  ];
  static final List<Debt> _memoryDebts = [
    Debt(
      id: 1,
      personName: 'Alex Smith',
      amount: 45.0,
      isIowe: false,
      date: DateTime.now().subtract(const Duration(days: 2)),
      note: 'Dinner split',
    ),
  ];
  static int _nextExpenseId = 3;
  static int _nextGoalId = 2;
  static int _nextDebtId = 2;
  static double _memoryBudget = 1500.0;

  ExpenseDatabase._init();

  Future<Database?> get database async {
    if (_isMemoryFallback) return null;
    if (_database != null) return _database!;

    try {
      _database = await _initDB('expenses_v4.db');
      return _database;
    } catch (e) {
      debugPrint('SQLite initialization warning, falling back to memory store: $e');
      _isMemoryFallback = true;
      return null;
    }
  }

  Future<Database?> _initDB(String filePath) async {
    try {
      if (kIsWeb) {
        // On Web browser, use high-performance in-memory store directly
        // to prevent sqflite_sw.js web worker binary warnings in dev server
        _isMemoryFallback = true;
        return null;
      }

      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 4,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Database factory open error: $e');
      _isMemoryFallback = true;
      return null;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        transaction_type TEXT NOT NULL DEFAULT 'expense',
        recurrence_period TEXT NOT NULL DEFAULT 'none',
        tags TEXT NOT NULL DEFAULT '',
        currency_symbol TEXT NOT NULL DEFAULT '\$'
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0.0,
        target_date TEXT,
        color_value INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_name TEXT NOT NULL,
        amount REAL NOT NULL,
        is_iowe INTEGER NOT NULL,
        date TEXT NOT NULL,
        due_date TEXT,
        is_settled INTEGER NOT NULL DEFAULT 0,
        note TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL
      )
    ''');

    await db.insert('settings', {'key': 'monthly_budget', 'value': '1500.0'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE expenses ADD COLUMN transaction_type TEXT NOT NULL DEFAULT 'expense'");
      await db.execute("ALTER TABLE expenses ADD COLUMN recurrence_period TEXT NOT NULL DEFAULT 'none'");
      await db.execute("ALTER TABLE expenses ADD COLUMN tags TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE expenses ADD COLUMN currency_symbol TEXT NOT NULL DEFAULT '\$'");
      await db.execute("CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)");
      await db.insert('settings', {'key': 'monthly_budget', 'value': '1500.0'},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          target_amount REAL NOT NULL,
          current_amount REAL NOT NULL DEFAULT 0.0,
          target_date TEXT,
          color_value INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS debts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          person_name TEXT NOT NULL,
          amount REAL NOT NULL,
          is_iowe INTEGER NOT NULL,
          date TEXT NOT NULL,
          due_date TEXT,
          is_settled INTEGER NOT NULL DEFAULT 0,
          note TEXT NOT NULL DEFAULT ''
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS custom_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon_code INTEGER NOT NULL,
          color_value INTEGER NOT NULL
        )
      ''');
    }
  }

  // --- EXPENSES / TRANSACTIONS ---

  Future<Expense> insertExpense(Expense expense) async {
    final db = await database;
    if (db != null) {
      final id = await db.insert('expenses', expense.toMap());
      return expense.copyWith(id: id);
    } else {
      final newExp = expense.copyWith(id: _nextExpenseId++);
      _memoryExpenses.add(newExp);
      return newExp;
    }
  }

  Future<List<Expense>> getAllExpenses({
    TransactionType? type,
    String? searchQuery,
    ExpenseCategory? category,
  }) async {
    final db = await database;
    if (db != null) {
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [];

      if (type != null) {
        whereClauses.add('transaction_type = ?');
        whereArgs.add(type.name);
      }

      if (category != null) {
        whereClauses.add('category = ?');
        whereArgs.add(category.name);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add('(title LIKE ? OR tags LIKE ?)');
        whereArgs.add('%$searchQuery%');
        whereArgs.add('%$searchQuery%');
      }

      final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final result = await db.query(
        'expenses',
        where: whereString,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date DESC',
      );
      return result.map((json) => Expense.fromMap(json)).toList();
    } else {
      var list = List<Expense>.from(_memoryExpenses);
      if (type != null) list = list.where((e) => e.transactionType == type).toList();
      if (category != null) list = list.where((e) => e.category == category).toList();
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        list = list.where((e) => e.title.toLowerCase().contains(q) || e.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    if (db != null) {
      return await db.update('expenses', expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
    } else {
      final idx = _memoryExpenses.indexWhere((e) => e.id == expense.id);
      if (idx != -1) {
        _memoryExpenses[idx] = expense;
        return 1;
      }
      return 0;
    }
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    if (db != null) {
      return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    } else {
      final initLen = _memoryExpenses.length;
      _memoryExpenses.removeWhere((e) => e.id == id);
      return initLen - _memoryExpenses.length;
    }
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    if (db != null) {
      final result = await db.rawQuery("SELECT SUM(amount) as total FROM expenses WHERE transaction_type = 'expense'");
      final total = result.first['total'];
      if (total == null) return 0.0;
      return (total as num).toDouble();
    } else {
      double sum = 0.0;
      for (var e in _memoryExpenses.where((e) => e.transactionType == TransactionType.expense)) {
        sum += e.amount;
      }
      return sum;
    }
  }

  Future<double> getTotalSpending() => getTotalExpenses();

  Future<double> getTotalIncome() async {
    final db = await database;
    if (db != null) {
      final result = await db.rawQuery("SELECT SUM(amount) as total FROM expenses WHERE transaction_type = 'income'");
      final total = result.first['total'];
      if (total == null) return 0.0;
      return (total as num).toDouble();
    } else {
      double sum = 0.0;
      for (var e in _memoryExpenses.where((e) => e.transactionType == TransactionType.income)) {
        sum += e.amount;
      }
      return sum;
    }
  }

  Future<Map<ExpenseCategory, double>> getCategoryBreakdown({TransactionType type = TransactionType.expense}) async {
    final db = await database;
    if (db != null) {
      final result = await db.rawQuery('''
        SELECT category, SUM(amount) as total 
        FROM expenses 
        WHERE transaction_type = ?
        GROUP BY category
      ''', [type.name]);

      final Map<ExpenseCategory, double> breakdown = {};
      for (var row in result) {
        final category = ExpenseCategory.fromString(row['category'] as String);
        final total = (row['total'] as num).toDouble();
        breakdown[category] = total;
      }
      return breakdown;
    } else {
      final Map<ExpenseCategory, double> breakdown = {};
      for (var e in _memoryExpenses.where((e) => e.transactionType == type)) {
        breakdown[e.category] = (breakdown[e.category] ?? 0.0) + e.amount;
      }
      return breakdown;
    }
  }

  Future<double> getMonthlyBudget() async {
    final db = await database;
    if (db != null) {
      final result = await db.query('settings', where: 'key = ?', whereArgs: ['monthly_budget']);
      if (result.isNotEmpty) {
        return double.tryParse(result.first['value'] as String) ?? 1500.0;
      }
      return 1500.0;
    } else {
      return _memoryBudget;
    }
  }

  Future<void> setMonthlyBudget(double amount) async {
    final db = await database;
    if (db != null) {
      await db.insert(
        'settings',
        {'key': 'monthly_budget', 'value': amount.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _memoryBudget = amount;
    }
  }

  // --- SAVINGS GOALS ---

  Future<SavingsGoal> insertSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    if (db != null) {
      final id = await db.insert('savings_goals', goal.toMap());
      return goal.copyWith(id: id);
    } else {
      final newGoal = goal.copyWith(id: _nextGoalId++);
      _memorySavings.add(newGoal);
      return newGoal;
    }
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    final db = await database;
    if (db != null) {
      final result = await db.query('savings_goals', orderBy: 'id DESC');
      return result.map((m) => SavingsGoal.fromMap(m)).toList();
    } else {
      return List<SavingsGoal>.from(_memorySavings);
    }
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    if (db != null) {
      return await db.update('savings_goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
    } else {
      final idx = _memorySavings.indexWhere((g) => g.id == goal.id);
      if (idx != -1) {
        _memorySavings[idx] = goal;
        return 1;
      }
      return 0;
    }
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await database;
    if (db != null) {
      return await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
    } else {
      final initLen = _memorySavings.length;
      _memorySavings.removeWhere((g) => g.id == id);
      return initLen - _memorySavings.length;
    }
  }

  // --- DEBTS & LOANS ---

  Future<Debt> insertDebt(Debt debt) async {
    final db = await database;
    if (db != null) {
      final id = await db.insert('debts', debt.toMap());
      return debt.copyWith(id: id);
    } else {
      final newDebt = debt.copyWith(id: _nextDebtId++);
      _memoryDebts.add(newDebt);
      return newDebt;
    }
  }

  Future<List<Debt>> getAllDebts() async {
    final db = await database;
    if (db != null) {
      final result = await db.query('debts', orderBy: 'is_settled ASC, date DESC');
      return result.map((m) => Debt.fromMap(m)).toList();
    } else {
      return List<Debt>.from(_memoryDebts);
    }
  }

  Future<int> updateDebt(Debt debt) async {
    final db = await database;
    if (db != null) {
      return await db.update('debts', debt.toMap(), where: 'id = ?', whereArgs: [debt.id]);
    } else {
      final idx = _memoryDebts.indexWhere((d) => d.id == debt.id);
      if (idx != -1) {
        _memoryDebts[idx] = debt;
        return 1;
      }
      return 0;
    }
  }

  Future<int> deleteDebt(int id) async {
    final db = await database;
    if (db != null) {
      return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
    } else {
      final initLen = _memoryDebts.length;
      _memoryDebts.removeWhere((d) => d.id == id);
      return initLen - _memoryDebts.length;
    }
  }

  Future<void> close() async {
    final db = await database;
    if (db != null) {
      await db.close();
    }
  }
}
