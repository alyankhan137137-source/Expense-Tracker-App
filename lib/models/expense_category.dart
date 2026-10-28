import 'package:flutter/material.dart';

/// Transaction categories for expenses and income.
enum ExpenseCategory {
  food,
  transport,
  bills,
  entertainment,
  shopping,
  health,
  education,
  salary,
  freelance,
  investments,
  business,
  gifts,
  other;

  /// Human-readable category label.
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.bills:
        return 'Bills & Utilities';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.health:
        return 'Healthcare';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.salary:
        return 'Salary';
      case ExpenseCategory.freelance:
        return 'Freelance';
      case ExpenseCategory.investments:
        return 'Investments';
      case ExpenseCategory.business:
        return 'Business Income';
      case ExpenseCategory.gifts:
        return 'Gifts & Rewards';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  /// Corresponding Material icon.
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.bills:
        return Icons.receipt_long;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.health:
        return Icons.medical_services;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.salary:
        return Icons.work;
      case ExpenseCategory.freelance:
        return Icons.laptop_mac;
      case ExpenseCategory.investments:
        return Icons.trending_up;
      case ExpenseCategory.business:
        return Icons.storefront;
      case ExpenseCategory.gifts:
        return Icons.card_giftcard;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  /// Theme accent color.
  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.bills:
        return Colors.redAccent;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.health:
        return Colors.teal;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.salary:
        return Colors.green;
      case ExpenseCategory.freelance:
        return Colors.cyan;
      case ExpenseCategory.investments:
        return Colors.lightGreen;
      case ExpenseCategory.business:
        return Colors.amber;
      case ExpenseCategory.gifts:
        return Colors.deepOrange;
      case ExpenseCategory.other:
        return Colors.blueGrey;
    }
  }

  /// Whether category is typically income.
  bool get isIncomeCategory {
    return this == ExpenseCategory.salary ||
        this == ExpenseCategory.freelance ||
        this == ExpenseCategory.investments ||
        this == ExpenseCategory.business ||
        this == ExpenseCategory.gifts;
  }

  /// Converts string representation from DB.
  static ExpenseCategory fromString(String categoryName) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}
