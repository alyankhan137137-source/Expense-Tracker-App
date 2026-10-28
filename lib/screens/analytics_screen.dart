import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/expense_database.dart';
import '../models/debt.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/savings_goal.dart';
import '../services/app_settings.dart';
import '../widgets/analytics_chart_widget.dart';
import '../widgets/export_report_dialog.dart';
import '../widgets/financial_health_card.dart';

/// Analytics & Interactive Financial Reports Dashboard with 7-Day Spending Trend.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<ExpenseCategory, double> _breakdown = {};
  List<Expense> _allExpenses = [];
  List<Debt> _debts = [];
  List<SavingsGoal> _goals = [];
  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;
  double _monthlyBudget = 1500.0;
  bool _isLoading = true;

  List<double> _dailyAmounts = [];
  List<String> _dayLabels = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    final breakdown = await ExpenseDatabase.instance.getCategoryBreakdown();
    final totalExp = await ExpenseDatabase.instance.getTotalExpenses();
    final totalInc = await ExpenseDatabase.instance.getTotalIncome();
    final expenses = await ExpenseDatabase.instance.getAllExpenses();
    final debts = await ExpenseDatabase.instance.getAllDebts();
    final goals = await ExpenseDatabase.instance.getAllSavingsGoals();
    final budget = await ExpenseDatabase.instance.getMonthlyBudget();

    // Compute last 7 days spending
    final now = DateTime.now();
    final List<double> dailyAmts = [];
    final List<String> dayLbls = [];
    final dayFormat = DateFormat('E');

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      dayLbls.add(dayFormat.format(day));

      final dayExpenses = expenses.where((e) {
        return e.transactionType == TransactionType.expense &&
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day;
      });

      final sum = dayExpenses.fold(0.0, (s, e) => s + e.amount);
      dailyAmts.add(sum);
    }

    setState(() {
      _breakdown = breakdown;
      _totalExpenses = totalExp;
      _totalIncome = totalInc;
      _allExpenses = expenses;
      _debts = debts;
      _goals = goals;
      _monthlyBudget = budget;
      _dailyAmounts = dailyAmts;
      _dayLabels = dayLbls;
      _isLoading = false;
    });
  }

  void _openExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ExportReportDialog(
        expenses: _allExpenses,
        totalIncome: _totalIncome,
        totalExpenses: _totalExpenses,
        breakdown: _breakdown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final theme = Theme.of(context);

    // Compute top category
    ExpenseCategory? topCategory;
    double topAmount = 0.0;
    _breakdown.forEach((cat, amt) {
      if (amt > topAmount) {
        topAmount = amt;
        topCategory = cat;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV & Report',
            onPressed: _openExportDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Financial Health Score & Badges Card
                  FinancialHealthCard(
                    expenses: _allExpenses,
                    totalIncome: _totalIncome,
                    totalExpenses: _totalExpenses,
                    monthlyBudget: _monthlyBudget,
                    debts: _debts,
                    goals: _goals,
                  ),
                  const SizedBox(height: 16),

                  // 7-Day Spending Trend Bar Chart Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '7-Day Spending Trend',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.bar_chart, size: 20, color: Colors.indigo),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DailySpendingBarChart(
                            dailyAmounts: _dailyAmounts,
                            dayLabels: _dayLabels,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Top Spending Summary Card
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Highest Expense Category',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (topCategory != null) ...[
                                Icon(topCategory!.icon, color: topCategory!.color, size: 28),
                                const SizedBox(width: 10),
                                Text(
                                  topCategory!.displayName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ] else
                                Text(
                                  'None yet',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                settings.formatAmount(topAmount),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Donut Chart Header
                  Text(
                    'Category Share',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Donut Chart Visualization
                  DonutCategoryChart(
                    breakdown: _breakdown,
                    totalAmount: _totalExpenses,
                  ),
                  const SizedBox(height: 20),

                  // Category Breakdown Legend List
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _breakdown.entries.map((entry) {
                          final cat = entry.key;
                          final amt = entry.value;
                          final pct = _totalExpenses > 0 ? (amt / _totalExpenses) * 100 : 0.0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 12),
                                Icon(cat.icon, size: 18, color: cat.color),
                                const SizedBox(width: 8),
                                Text(cat.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(
                                  '${settings.formatAmount(amt)} (${pct.toStringAsFixed(1)}%)',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Export Report Banner
                  FilledButton.icon(
                    onPressed: _openExportDialog,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate Financial Summary & CSV Export'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
