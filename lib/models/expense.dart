import 'expense_category.dart';

/// Data class representing an individual expense record.
class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  /// Converts an [Expense] instance into a Map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
    };
  }

  /// Creates an [Expense] object from a database record Map.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: ExpenseCategory.fromString(map['category'] as String),
    );
  }

  /// Returns a copy of the expense with updated properties.
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}
