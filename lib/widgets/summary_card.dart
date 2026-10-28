import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../services/app_settings.dart';

/// Refined Dashboard Summary Header with Privacy Mode & Budget Health Status Chips.
class SummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double monthlyBudget;
  final Map<ExpenseCategory, double> categoryBreakdown;
  final VoidCallback onSetBudgetTap;

  const SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.monthlyBudget,
    required this.categoryBreakdown,
    required this.onSetBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final theme = Theme.of(context);

    final netBalance = totalIncome - totalExpenses;
    final budgetUsage = monthlyBudget > 0 ? (totalExpenses / monthlyBudget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = totalExpenses > monthlyBudget;

    // Determine Budget Health Status Chip
    String statusText = '🟢 Healthy Budget';
    Color progressColor = Colors.green;
    Color statusBg = Colors.green.withValues(alpha: 0.2);

    if (budgetUsage > 0.8 && !isOverBudget) {
      statusText = '🟠 Caution (80% Used)';
      progressColor = Colors.orange;
      statusBg = Colors.orange.withValues(alpha: 0.2);
    } else if (isOverBudget) {
      statusText = '🔴 Budget Exceeded!';
      progressColor = Colors.red;
      statusBg = Colors.red.withValues(alpha: 0.2);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Net Balance Header & Privacy Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(
                      settings.isPrivacyMode ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    tooltip: 'Toggle Privacy Mode',
                    onPressed: () => settings.togglePrivacyMode(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    tooltip: 'Set Monthly Budget',
                    onPressed: onSetBudgetTap,
                  ),
                ],
              ),
            ],
          ),
          Text(
            settings.formatAmount(netBalance),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: netBalance >= 0 ? theme.colorScheme.onPrimaryContainer : Colors.red,
            ),
          ),
          const SizedBox(height: 16),

          // Income vs Expense Summary Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Income', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settings.formatAmount(totalIncome),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text('Expenses', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settings.formatAmount(totalExpenses),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Monthly Budget Tracker Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Budget Target',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '${settings.formatAmount(totalExpenses)} / ${settings.formatAmount(monthlyBudget)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOverBudget ? Colors.red : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: budgetUsage,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          if (isOverBudget) ...[
            const SizedBox(height: 6),
            const Text(
              '⚠️ Budget Exceeded! Limit reached for this month.',
              style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}
