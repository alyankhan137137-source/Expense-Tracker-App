/// Data model representing debts, loans, and IOUs.
class Debt {
  /// Unique database primary key identifier.
  final int? id;

  /// Name of person or entity involved in the debt/loan.
  final String personName;

  /// Total monetary value of the debt or loan.
  final double amount;

  /// Debt directional type: `true` if I owe them, `false` if they owe me.
  final bool isIowe;

  /// Date when the debt record was created.
  final DateTime date;

  /// Optional expected due date for settlement.
  final DateTime? dueDate;

  /// Settlement status flag.
  final bool isSettled;

  /// Optional context note or description.
  final String note;

  const Debt({
    this.id,
    required this.personName,
    required this.amount,
    required this.isIowe,
    required this.date,
    this.dueDate,
    this.isSettled = false,
    this.note = '',
  });

  /// Converts a [Debt] instance into a Map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'person_name': personName,
      'amount': amount,
      'is_iowe': isIowe ? 1 : 0,
      'date': date.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'is_settled': isSettled ? 1 : 0,
      'note': note,
    };
  }

  /// Deserializes a database record Map into a [Debt] object.
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as int?,
      personName: map['person_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      isIowe: (map['is_iowe'] as int) == 1,
      date: DateTime.parse(map['date'] as String),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      isSettled: (map['is_settled'] as int) == 1,
      note: (map['note'] as String?) ?? '',
    );
  }

  /// Copy helper method for immutability.
  Debt copyWith({
    int? id,
    String? personName,
    double? amount,
    bool? isIowe,
    DateTime? date,
    DateTime? dueDate,
    bool? isSettled,
    String? note,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      isIowe: isIowe ?? this.isIowe,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      isSettled: isSettled ?? this.isSettled,
      note: note ?? this.note,
    );
  }
}
