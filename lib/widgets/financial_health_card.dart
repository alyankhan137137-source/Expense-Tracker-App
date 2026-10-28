import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../models/expense.dart';
import '../models/savings_goal.dart';
import '../services/financial_health_service.dart';
import 'badges_dialog.dart';

/// Interactive UI Card displaying Financial Health Score (0-100), Tiers, Advice & Badges.
class FinancialHealthCard extends StatelessWidget {
  final List<Expense> expenses;
  final double totalIncome;
  final double totalExpenses;
  final double monthlyBudget;
  final List<Debt> debts;
  final List<SavingsGoal> goals;

  const FinancialHealthCard({
    super.key,
    required this.expenses,
    required this.totalIncome,
    required this.totalExpenses,
    required this.monthlyBudget,
    required this.debts,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final score = FinancialHealthService.calculateScore(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      monthlyBudget: monthlyBudget,
      debts: debts,
      goals: goals,
    );

    final tier = FinancialHealthService.getScoreTier(score);
    final String tierLabel = tier['label'] as String;
    final Color tierColor = tier['color'] as Color;

    final badges = FinancialHealthService.evaluateBadges(
      expenses: expenses,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      monthlyBudget: monthlyBudget,
      debts: debts,
      goals: goals,
    );

    final unlockedCount = badges.where((b) => b.isUnlocked).length;
    final tips = FinancialHealthService.generateSmartTips(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      monthlyBudget: monthlyBudget,
      debts: debts,
    );

    return Card(
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
            // Score Header
            Row(
              children: [
                // Score Circle Ring
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: tierColor, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: tierColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Financial Health',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tierLabel,
                              style: TextStyle(color: tierColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Score computed based on savings, budget compliance, and debt status.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Smart Personalized Advice Tip
            if (tips.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tips.first,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Achievements & Badges Ribbon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined, size: 18, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      'Badges ($unlockedCount/${badges.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => BadgesDialog(badges: badges),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Badge Icons Row Preview
            Wrap(
              spacing: 8,
              children: badges.map((badge) {
                return Opacity(
                  opacity: badge.isUnlocked ? 1.0 : 0.3,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: badge.color.withValues(alpha: 0.2),
                    child: Icon(badge.icon, size: 16, color: badge.color),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
