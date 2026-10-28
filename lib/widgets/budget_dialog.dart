import 'package:flutter/material.dart';

/// Modal dialog allowing users to configure their target monthly budget.
class BudgetDialog extends StatefulWidget {
  final double currentBudget;
  final Function(double) onSave;

  const BudgetDialog({
    super.key,
    required this.currentBudget,
    required this.onSave,
  });

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentBudget.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_controller.text.trim());
      widget.onSave(amount);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.track_changes, color: Colors.indigo),
          SizedBox(width: 10),
          Text('Set Monthly Budget'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Monthly Spending Target (\$)',
            hintText: 'e.g. 1500.00',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Enter a budget amount';
            final parsed = double.tryParse(val.trim());
            if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.primary),
          child: const Text('Save Target'),
        ),
      ],
    );
  }
}
