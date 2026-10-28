import 'package:flutter/material.dart';
import '../database/expense_database.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/app_settings.dart';
import '../widgets/budget_dialog.dart';
import '../widgets/debt_dialog.dart';
import '../widgets/expense_form_dialog.dart';
import '../widgets/expense_tile.dart';
import '../widgets/savings_goal_dialog.dart';
import '../widgets/summary_card.dart';

/// Main Dashboard Screen managing local state, searching, multi-action speed dial, and swipe gestures.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Expense> _allExpenses = [];
  Map<ExpenseCategory, double> _categoryBreakdown = {};
  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;
  double _monthlyBudget = 1500.0;
  bool _isLoading = true;
  bool _isSpeedDialOpen = false;

  ExpenseCategory? _selectedFilterCategory;
  TransactionType? _selectedTypeFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Reloads all data from SQLite local database and updates UI.
  Future<void> _refreshExpenses() async {
    setState(() => _isLoading = true);

    final expenses = await ExpenseDatabase.instance.getAllExpenses(
      type: _selectedTypeFilter,
      searchQuery: _searchQuery,
      category: _selectedFilterCategory,
    );
    final totalExp = await ExpenseDatabase.instance.getTotalExpenses();
    final totalInc = await ExpenseDatabase.instance.getTotalIncome();
    final breakdown = await ExpenseDatabase.instance.getCategoryBreakdown();
    final budget = await ExpenseDatabase.instance.getMonthlyBudget();

    setState(() {
      _allExpenses = expenses;
      _totalExpenses = totalExp;
      _totalIncome = totalInc;
      _categoryBreakdown = breakdown;
      _monthlyBudget = budget;
      _isLoading = false;
    });
  }

  /// Opens the ExpenseFormDialog modal for creating a new transaction.
  void _openAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExpenseFormDialog(
        onSave: (newExpense) async {
          await ExpenseDatabase.instance.insertExpense(newExpense);
          _refreshExpenses();
          _showSnackBar('Transaction added successfully!');
        },
      ),
    );
  }

  /// Opens the ExpenseFormDialog modal for updating an existing transaction.
  void _openEditExpenseModal(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExpenseFormDialog(
        expenseToEdit: expense,
        onSave: (updatedExpense) async {
          await ExpenseDatabase.instance.updateExpense(updatedExpense);
          _refreshExpenses();
          _showSnackBar('Transaction updated successfully!');
        },
      ),
    );
  }

  /// Opens BudgetDialog to set monthly spending limit.
  void _openBudgetModal() {
    showDialog(
      context: context,
      builder: (ctx) => BudgetDialog(
        currentBudget: _monthlyBudget,
        onSave: (newBudget) async {
          await ExpenseDatabase.instance.setMonthlyBudget(newBudget);
          _refreshExpenses();
          _showSnackBar('Monthly budget target updated!');
        },
      ),
    );
  }

  /// Opens SavingsGoalDialog to quickly add a savings target.
  void _openSavingsModal() {
    showDialog(
      context: context,
      builder: (ctx) => SavingsGoalDialog(
        onSave: (goal) async {
          await ExpenseDatabase.instance.insertSavingsGoal(goal);
          _refreshExpenses();
          _showSnackBar('Savings goal created!');
        },
      ),
    );
  }

  /// Opens DebtDialog to quickly record an IOU.
  void _openDebtModal() {
    showDialog(
      context: context,
      builder: (ctx) => DebtDialog(
        onSave: (debt) async {
          await ExpenseDatabase.instance.insertDebt(debt);
          _refreshExpenses();
          _showSnackBar('IOU record created!');
        },
      ),
    );
  }

  /// Deletes an expense record from the database.
  Future<void> _deleteExpense(Expense expense) async {
    if (expense.id != null) {
      await ExpenseDatabase.instance.deleteExpense(expense.id!);
      _refreshExpenses();
      _showSnackBar('Record deleted');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = AppSettings.instance;

    final avgDailySpend = _totalExpenses > 0 ? (_totalExpenses / 30) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined),
            SizedBox(width: 10),
            Text(
              'Finance Tracker Pro',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshExpenses,
              child: CustomScrollView(
                slivers: [
                  // Dashboard Summary Section
                  SliverToBoxAdapter(
                    child: SummaryCard(
                      totalIncome: _totalIncome,
                      totalExpenses: _totalExpenses,
                      monthlyBudget: _monthlyBudget,
                      categoryBreakdown: _categoryBreakdown,
                      onSetBudgetTap: _openBudgetModal,
                    ),
                  ),

                  // Quick Insight Metric Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Chip(
                              avatar: const Icon(Icons.analytics_outlined, size: 16),
                              label: Text('Daily Avg: ${settings.formatAmount(avgDailySpend)}'),
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Chip(
                              avatar: const Icon(Icons.receipt, size: 16),
                              label: Text('Total Items: ${_allExpenses.length}'),
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search transactions or tags (#work)...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    _refreshExpenses();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onChanged: (query) {
                          setState(() => _searchQuery = query);
                          _refreshExpenses();
                        },
                      ),
                    ),
                  ),

                  // Filter Segmented Buttons (All, Expenses, Income)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SegmentedButton<TransactionType?>(
                        segments: const [
                          ButtonSegment<TransactionType?>(
                            value: null,
                            label: Text('All'),
                          ),
                          ButtonSegment<TransactionType?>(
                            value: TransactionType.expense,
                            label: Text('Expenses'),
                            icon: Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                          ),
                          ButtonSegment<TransactionType?>(
                            value: TransactionType.income,
                            label: Text('Income'),
                            icon: Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                          ),
                        ],
                        selected: {_selectedTypeFilter},
                        onSelectionChanged: (selected) {
                          setState(() => _selectedTypeFilter = selected.first);
                          _refreshExpenses();
                        },
                      ),
                    ),
                  ),

                  // Category Filter Chips
                  SliverToBoxAdapter(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text('All Categories'),
                              selected: _selectedFilterCategory == null,
                              onSelected: (_) {
                                setState(() => _selectedFilterCategory = null);
                                _refreshExpenses();
                              },
                            ),
                          ),
                          ...ExpenseCategory.values.map((cat) {
                            final isSelected = _selectedFilterCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(
                                  cat.icon,
                                  size: 16,
                                  color: isSelected ? theme.colorScheme.onPrimary : cat.color,
                                ),
                                label: Text(cat.displayName),
                                selected: isSelected,
                                selectedColor: cat.color.withValues(alpha: 0.8),
                                onSelected: (selected) {
                                  setState(() => _selectedFilterCategory = selected ? cat : null);
                                  _refreshExpenses();
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transaction History',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Swipe left to delete',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Transaction List Items with Swipe-to-Dismiss Gestures
                  if (_allExpenses.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap + below to record an income or expense',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final expense = _allExpenses[index];
                          return Dismissible(
                            key: Key('expense_${expense.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete, color: Colors.white, size: 28),
                            ),
                            onDismissed: (_) {
                              _deleteExpense(expense);
                            },
                            child: ExpenseTile(
                              expense: expense,
                              onEdit: () => _openEditExpenseModal(expense),
                              onDelete: () => _deleteExpense(expense),
                            ),
                          );
                        },
                        childCount: _allExpenses.length,
                      ),
                    ),
                ],
              ),
            ),

      // Multi-Action Floating Speed Dial Menu
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isSpeedDialOpen) ...[
            FloatingActionButton.small(
              heroTag: 'fab_debt',
              onPressed: () {
                setState(() => _isSpeedDialOpen = false);
                _openDebtModal();
              },
              tooltip: 'Add IOU / Debt',
              backgroundColor: Colors.teal,
              child: const Icon(Icons.handshake, color: Colors.white),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'fab_savings',
              onPressed: () {
                setState(() => _isSpeedDialOpen = false);
                _openSavingsModal();
              },
              tooltip: 'Add Savings Goal',
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.savings, color: Colors.white),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'fab_expense',
              onPressed: () {
                setState(() => _isSpeedDialOpen = false);
                _openAddExpenseModal();
              },
              tooltip: 'Add Transaction',
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.receipt_long, color: Colors.white),
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton.extended(
            heroTag: 'fab_main',
            onPressed: () {
              setState(() => _isSpeedDialOpen = !_isSpeedDialOpen);
            },
            icon: Icon(_isSpeedDialOpen ? Icons.close : Icons.add),
            label: Text(_isSpeedDialOpen ? 'Close Menu' : 'Quick Actions'),
          ),
        ],
      ),
    );
  }
}
