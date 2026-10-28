import 'package:flutter/material.dart';

/// Data model representing a personal target savings goal (e.g. Emergency Fund, Vacation).
class SavingsGoal {
  /// Unique database primary key identifier.
  final int? id;

  /// Goal title description.
  final String title;

  /// Total target goal amount.
  final double targetAmount;

  /// Currently accumulated saved amount.
  final double currentAmount;

  /// Optional target completion date.
  final DateTime? targetDate;

  /// UI theme accent color.
  final Color color;

  const SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.color = Colors.indigo,
  });

  /// Calculates current progress percentage from 0.0 (0%) to 1.0 (100%).
  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Whether target savings goal has been fully met.
  bool get isCompleted => currentAmount >= targetAmount;

  /// Converts a [SavingsGoal] instance into a Map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate?.toIso8601String(),
      'color_value': color.toARGB32(),
    };
  }

  /// Deserializes a database record Map into a [SavingsGoal] object.
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    final colorVal = map['color_value'] as int?;
    return SavingsGoal(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      targetDate: map['target_date'] != null ? DateTime.parse(map['target_date'] as String) : null,
      color: colorVal != null ? Color(colorVal) : Colors.indigo,
    );
  }

  /// Copy helper method for immutability.
  SavingsGoal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    Color? color,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
    );
  }
}
