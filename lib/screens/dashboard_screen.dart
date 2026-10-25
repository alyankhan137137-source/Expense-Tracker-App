import 'package:flutter/material.dart';
import '../database/expense_database.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../widgets/expense_form_dialog.dart';
import '../widgets/expense_tile.dart';
import '../widgets/summary_card.dart';

/// Main Dashboard Screen managing local state, filters, and database synchronization.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Expense> _allExpenses = [];
  Map<ExpenseCategory, double> _categoryBreakdown = {};
  double _totalSpending = 0.0;
  bool _isLoading = true;
  ExpenseCategory? _selectedFilterCategory;

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  /// Reloads all data from SQLite local database and updates UI.
  Future<void> _refreshExpenses() async {
    setState(() => _isLoading = true);

    final expenses = await ExpenseDatabase.instance.getAllExpenses();
    final total = await ExpenseDatabase.instance.getTotalSpending();
    final breakdown = await ExpenseDatabase.instance.getCategoryBreakdown();

    setState(() {
      _allExpenses = expenses;
      _totalSpending = total;
      _categoryBreakdown = breakdown;
      _isLoading = false;
    });
  }

  /// Opens the ExpenseFormDialog modal for creating a new expense.
  void _openAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExpenseFormDialog(
        onSave: (newExpense) async {
          await ExpenseDatabase.instance.insertExpense(newExpense);
          _refreshExpenses();
          _showSnackBar('Expense added successfully!');
        },
      ),
    );
  }

  /// Opens the ExpenseFormDialog modal for updating an existing expense.
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
          _showSnackBar('Expense updated successfully!');
        },
      ),
    );
  }

  /// Deletes an expense record from the database.
  Future<void> _deleteExpense(Expense expense) async {
    if (expense.id != null) {
      await ExpenseDatabase.instance.deleteExpense(expense.id!);
      _refreshExpenses();
      _showSnackBar('Expense deleted');
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

    // Apply category filter if selected
    final displayedExpenses = _selectedFilterCategory == null
        ? _allExpenses
        : _allExpenses
            .where((e) => e.category == _selectedFilterCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined),
            SizedBox(width: 10),
            Text(
              'Expense Tracker',
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
                      totalSpending: _totalSpending,
                      categoryBreakdown: _categoryBreakdown,
                    ),
                  ),

                  // Category Filter Chips
                  SliverToBoxAdapter(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: _selectedFilterCategory == null,
                              onSelected: (_) {
                                setState(() {
                                  _selectedFilterCategory = null;
                                });
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
                                  setState(() {
                                    _selectedFilterCategory = selected ? cat : null;
                                  });
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
                            'Recent Transactions',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${displayedExpenses.length} items',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expense List Items or Empty State
                  if (displayedExpenses.isEmpty)
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
                              'No expenses found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap the + button below to add your first expense',
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
                          final expense = displayedExpenses[index];
                          return ExpenseTile(
                            expense: expense,
                            onEdit: () => _openEditExpenseModal(expense),
                            onDelete: () => _deleteExpense(expense),
                          );
                        },
                        childCount: displayedExpenses.length,
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpenseModal,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
