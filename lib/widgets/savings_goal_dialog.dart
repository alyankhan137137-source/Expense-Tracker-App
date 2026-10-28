import 'package:flutter/material.dart';
import '../models/savings_goal.dart';

/// Modal dialog for creating a new savings goal or depositing funds into an existing goal.
class SavingsGoalDialog extends StatefulWidget {
  final SavingsGoal? goalToEdit;
  final Function(SavingsGoal) onSave;

  const SavingsGoalDialog({
    super.key,
    this.goalToEdit,
    required this.onSave,
  });

  @override
  State<SavingsGoalDialog> createState() => _SavingsGoalDialogState();
}

class _SavingsGoalDialogState extends State<SavingsGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  Color _selectedColor = Colors.indigo;

  final List<Color> _colors = [
    Colors.indigo,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    final goal = widget.goalToEdit;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _targetController = TextEditingController(text: goal != null ? goal.targetAmount.toStringAsFixed(2) : '');
    _currentController = TextEditingController(text: goal != null ? goal.currentAmount.toStringAsFixed(2) : '0.00');
    _selectedColor = goal?.color ?? Colors.indigo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final target = double.parse(_targetController.text.trim());
      final current = double.parse(_currentController.text.trim());

      final updatedGoal = SavingsGoal(
        id: widget.goalToEdit?.id,
        title: title,
        targetAmount: target,
        currentAmount: current,
        color: _selectedColor,
      );

      widget.onSave(updatedGoal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goalToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Update Savings Goal' : 'New Savings Goal', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Goal Title',
                  hintText: 'e.g. Emergency Fund, Vacation',
                  prefixIcon: const Icon(Icons.savings),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Target Amount (\$)',
                  prefixIcon: const Icon(Icons.flag),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter target amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Current Amount Saved (\$)',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter current amount';
                  if (double.tryParse(val.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Theme Color: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 6,
                    children: _colors.map((c) {
                      final isSelected = _selectedColor == c;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: c,
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update Goal' : 'Save Goal'),
        ),
      ],
    );
  }
}
