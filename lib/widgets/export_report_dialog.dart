import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/export_service.dart';

/// Modal dialog previewing and copying generated CSV or Financial Summary Reports.
class ExportReportDialog extends StatefulWidget {
  final List<Expense> expenses;
  final double totalIncome;
  final double totalExpenses;
  final Map<ExpenseCategory, double> breakdown;

  const ExportReportDialog({
    super.key,
    required this.expenses,
    required this.totalIncome,
    required this.totalExpenses,
    required this.breakdown,
  });

  @override
  State<ExportReportDialog> createState() => _ExportReportDialogState();
}

class _ExportReportDialogState extends State<ExportReportDialog> {
  int _selectedTab = 0; // 0 = Summary Report, 1 = CSV Data

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final reportText = ExportService.generateSummaryReport(
      expenses: widget.expenses,
      totalIncome: widget.totalIncome,
      totalExpenses: widget.totalExpenses,
      breakdown: widget.breakdown,
    );

    final csvText = ExportService.generateCsv(widget.expenses);

    final activeText = _selectedTab == 0 ? reportText : csvText;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.description, color: Colors.indigo),
          SizedBox(width: 10),
          Text('Export Financial Data'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Segmented Tab Selector
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Summary Report'), icon: Icon(Icons.analytics)),
                ButtonSegment(value: 1, label: Text('CSV Format'), icon: Icon(Icons.table_chart)),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (val) {
                setState(() {
                  _selectedTab = val.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Scrollable Code/Text Preview
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  activeText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: activeText));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_selectedTab == 0 ? 'Summary report copied to clipboard!' : 'CSV data copied to clipboard!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy to Clipboard'),
        ),
      ],
    );
  }
}
