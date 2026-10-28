import 'expense_category.dart';

/// Transaction type (expense or income).
enum TransactionType {
  expense,
  income;

  String get displayName => this == TransactionType.income ? 'Income' : 'Expense';
}

/// Recurrence period options for scheduled recurring expenses.
enum RecurrencePeriod {
  none,
  daily,
  weekly,
  monthly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurrencePeriod.none:
        return 'One-time';
      case RecurrencePeriod.daily:
        return 'Daily';
      case RecurrencePeriod.weekly:
        return 'Weekly';
      case RecurrencePeriod.monthly:
        return 'Monthly';
      case RecurrencePeriod.yearly:
        return 'Yearly';
    }
  }
}

/// Enhanced Data model representing a financial transaction.
class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final TransactionType transactionType;
  final RecurrencePeriod recurrencePeriod;
  final List<String> tags;
  final String currencySymbol;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.transactionType = TransactionType.expense,
    this.recurrencePeriod = RecurrencePeriod.none,
    this.tags = const [],
    this.currencySymbol = '\$',
  });

  /// Converts an [Expense] instance into a Map for SQLite database storage.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
      'transaction_type': transactionType.name,
      'recurrence_period': recurrencePeriod.name,
      'tags': tags.join(','),
      'currency_symbol': currencySymbol,
    };
  }

  /// Deserializes a Map database record into an [Expense] object.
  factory Expense.fromMap(Map<String, dynamic> map) {
    final tagsRaw = map['tags'] as String? ?? '';
    final tagsList = tagsRaw.isEmpty
        ? <String>[]
        : tagsRaw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: ExpenseCategory.fromString(map['category'] as String),
      transactionType: TransactionType.values.firstWhere(
        (t) => t.name == map['transaction_type'],
        orElse: () => TransactionType.expense,
      ),
      recurrencePeriod: RecurrencePeriod.values.firstWhere(
        (r) => r.name == map['recurrence_period'],
        orElse: () => RecurrencePeriod.none,
      ),
      tags: tagsList,
      currencySymbol: (map['currency_symbol'] as String?) ?? '\$',
    );
  }

  /// Copy helper for immutability.
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    TransactionType? transactionType,
    RecurrencePeriod? recurrencePeriod,
    List<String>? tags,
    String? currencySymbol,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      transactionType: transactionType ?? this.transactionType,
      recurrencePeriod: recurrencePeriod ?? this.recurrencePeriod,
      tags: tags ?? this.tags,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}
