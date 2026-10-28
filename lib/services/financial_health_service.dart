import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../models/expense.dart';
import '../models/savings_goal.dart';

/// Achievement Badge data class.
class AchievementBadge {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  const AchievementBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

/// Smart Financial Health Scoring, Gamification, and Financial Advice Engine.
class FinancialHealthService {
  /// Calculates 0–100 Financial Health Score based on user metrics.
  static int calculateScore({
    required double totalIncome,
    required double totalExpenses,
    required double monthlyBudget,
    required List<Debt> debts,
    required List<SavingsGoal> goals,
  }) {
    int score = 50; // Base score

    // 1. Budget Compliance (+20 / -20)
    if (monthlyBudget > 0) {
      if (totalExpenses <= monthlyBudget) {
        score += 20;
      } else {
        score -= 20;
      }
    }

    // 2. Savings Rate (+15 / -10)
    if (totalIncome > 0) {
      final savingsRate = (totalIncome - totalExpenses) / totalIncome;
      if (savingsRate >= 0.20) {
        score += 15; // Saving >= 20%
      } else if (savingsRate > 0) {
        score += 5;
      } else {
        score -= 10; // Spending > Income
      }
    }

    // 3. Savings Goals Progress (+10)
    if (goals.isNotEmpty) {
      final completedGoals = goals.where((g) => g.isCompleted).length;
      score += (completedGoals * 5).clamp(0, 10);
    }

    // 4. Debt Status (+5 / -10)
    final unpaidDebts = debts.where((d) => !d.isSettled && d.isIowe).length;
    if (debts.isNotEmpty && unpaidDebts == 0) {
      score += 5; // Debt free
    } else if (unpaidDebts > 0) {
      score -= (unpaidDebts * 3).clamp(0, 10);
    }

    return score.clamp(0, 100);
  }

  /// Returns Financial Status Tier label and color based on score.
  static Map<String, dynamic> getScoreTier(int score) {
    if (score >= 85) {
      return {'label': 'Excellent', 'color': Colors.green};
    } else if (score >= 70) {
      return {'label': 'Good', 'color': Colors.teal};
    } else if (score >= 50) {
      return {'label': 'Fair', 'color': Colors.orange};
    } else {
      return {'label': 'Needs Attention', 'color': Colors.red};
    }
  }

  /// Evaluates and returns all Achievement Badges with unlocked status.
  static List<AchievementBadge> evaluateBadges({
    required List<Expense> expenses,
    required double totalIncome,
    required double totalExpenses,
    required double monthlyBudget,
    required List<Debt> debts,
    required List<SavingsGoal> goals,
  }) {
    final unpaidDebts = debts.where((d) => !d.isSettled && d.isIowe).length;

    return [
      AchievementBadge(
        title: 'First Step',
        description: 'Logged your first transaction record.',
        icon: Icons.flag,
        color: Colors.blue,
        isUnlocked: expenses.isNotEmpty,
      ),
      AchievementBadge(
        title: 'Budget Guardian',
        description: 'Kept spending under monthly budget target.',
        icon: Icons.shield,
        color: Colors.indigo,
        isUnlocked: monthlyBudget > 0 && totalExpenses <= monthlyBudget,
      ),
      AchievementBadge(
        title: 'Master Saver',
        description: 'Created a personal savings goal.',
        icon: Icons.savings,
        color: Colors.teal,
        isUnlocked: goals.isNotEmpty,
      ),
      AchievementBadge(
        title: 'Debt Free',
        description: 'All outstanding IOUs & debts settled.',
        icon: Icons.handshake,
        color: Colors.green,
        isUnlocked: debts.isNotEmpty && unpaidDebts == 0,
      ),
      AchievementBadge(
        title: 'Super Logger',
        description: 'Recorded 10 or more financial records.',
        icon: Icons.bolt,
        color: Colors.amber,
        isUnlocked: expenses.length >= 10,
      ),
      AchievementBadge(
        title: 'Wealth Builder',
        description: 'Maintained a positive net income savings rate.',
        icon: Icons.trending_up,
        color: Colors.purple,
        isUnlocked: totalIncome > totalExpenses && totalIncome > 0,
      ),
    ];
  }

  /// Generates contextual financial advice tips based on user data.
  static List<String> generateSmartTips({
    required double totalIncome,
    required double totalExpenses,
    required double monthlyBudget,
    required List<Debt> debts,
  }) {
    final List<String> tips = [];

    if (totalExpenses > monthlyBudget && monthlyBudget > 0) {
      tips.add('⚠️ You have exceeded your monthly budget target. Consider reviewing non-essential spending.');
    } else {
      tips.add('👍 Great job keeping your spending under your monthly budget!');
    }

    if (totalIncome > 0) {
      final savingsRate = ((totalIncome - totalExpenses) / totalIncome * 100);
      if (savingsRate < 20) {
        tips.add('💡 Financial Experts recommend saving at least 20% of your income. Current rate: ${savingsRate.toStringAsFixed(1)}%');
      } else {
        tips.add('🌟 Excellent savings rate of ${savingsRate.toStringAsFixed(1)}%! Keep building your wealth.');
      }
    }

    final unpaidDebts = debts.where((d) => !d.isSettled && d.isIowe).length;
    if (unpaidDebts > 0) {
      tips.add('🤝 You have $unpaidDebts unsettled debt(s). Prioritize paying high-interest debts first.');
    }

    return tips;
  }
}
