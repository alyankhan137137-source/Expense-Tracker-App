import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

/// Helper service for generating CSV data strings and formatted text financial reports.
class ExportService {
  /// Generates a CSV format string from transaction records.
  static String generateCsv(List<Expense> expenses) {
    final StringBuffer csv = StringBuffer();
    csv.writeln('ID,Date,Title,Type,Category,Amount,Currency,Tags,Recurrence');

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var item in expenses) {
      final dateStr = dateFormat.format(item.date);
      final titleStr = '"${item.title.replaceAll('"', '""')}"';
      final tagsStr = '"${item.tags.join('; ')}"';

      csv.writeln(
        '${item.id ?? ''},$dateStr,$titleStr,${item.transactionType.name},${item.category.name},${item.amount.toStringAsFixed(2)},${item.currencySymbol},$tagsStr,${item.recurrencePeriod.name}',
      );
    }

    return csv.toString();
  }

  /// Generates a human-readable Financial Health Report summary.
  static String generateSummaryReport({
    required List<Expense> expenses,
    required double totalIncome,
    required double totalExpenses,
    required Map<ExpenseCategory, double> breakdown,
  }) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final netSavings = totalIncome - totalExpenses;

    ExpenseCategory? topCat;
    double topAmt = 0.0;
    breakdown.forEach((cat, amt) {
      if (amt > topAmt) {
        topAmt = amt;
        topCat = cat;
      }
    });

    final StringBuffer report = StringBuffer();
    report.writeln('===========================================');
    report.writeln('       FINANCIAL SUMMARY REPORT           ');
    report.writeln('   Generated: ${dateFormat.format(DateTime.now())}');
    report.writeln('===========================================');
    report.writeln('');
    report.writeln('📊 OVERVIEW:');
    report.writeln('  • Total Income:   ${currencyFormat.format(totalIncome)}');
    report.writeln('  • Total Expenses: ${currencyFormat.format(totalExpenses)}');
    report.writeln('  • Net Savings:    ${currencyFormat.format(netSavings)}');
    report.writeln('  • Total Records:  ${expenses.length}');
    report.writeln('');
    report.writeln('🏷️ HIGHEST SPENDING CATEGORY:');
    if (topCat != null) {
      report.writeln('  • Category: ${topCat!.displayName}');
      report.writeln('  • Amount:   ${currencyFormat.format(topAmt)}');
    } else {
      report.writeln('  • No expense data available.');
    }
    report.writeln('');
    report.writeln('📌 CATEGORY BREAKDOWN:');
    breakdown.forEach((cat, amt) {
      final pct = totalExpenses > 0 ? (amt / totalExpenses * 100).toStringAsFixed(1) : '0.0';
      report.writeln('  • ${cat.displayName.padRight(20)}: ${currencyFormat.format(amt)} ($pct%)');
    });
    report.writeln('===========================================');

    return report.toString();
  }
}
