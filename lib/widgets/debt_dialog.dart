import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';

/// Modal dialog for recording or editing a debt or loan (IOU).
class DebtDialog extends StatefulWidget {
  final Debt? debtToEdit;
  final Function(Debt) onSave;

  const DebtDialog({
    super.key,
    this.debtToEdit,
    required this.onSave,
  });

  @override
  State<DebtDialog> createState() => _DebtDialogState();
}

class _DebtDialogState extends State<DebtDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late bool _isIowe;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final d = widget.debtToEdit;
    _nameController = TextEditingController(text: d?.personName ?? '');
    _amountController = TextEditingController(text: d != null ? d.amount.toStringAsFixed(2) : '');
    _noteController = TextEditingController(text: d?.note ?? '');
    _isIowe = d?.isIowe ?? true; // Default: I owe
    _date = d?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final amount = double.parse(_amountController.text.trim());
      final note = _noteController.text.trim();

      final updatedDebt = Debt(
        id: widget.debtToEdit?.id,
        personName: name,
        amount: amount,
        isIowe: _isIowe,
        date: _date,
        note: note,
        isSettled: widget.debtToEdit?.isSettled ?? false,
      );

      widget.onSave(updatedDebt);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.debtToEdit != null;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AlertDialog(
      title: Text(isEditing ? 'Edit IOU / Debt' : 'Record New IOU / Debt', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('I Owe'), icon: Icon(Icons.arrow_upward, color: Colors.red)),
                  ButtonSegment(value: false, label: Text('They Owe Me'), icon: Icon(Icons.arrow_downward, color: Colors.green)),
                ],
                selected: {_isIowe},
                onSelectionChanged: (val) {
                  setState(() => _isIowe = val.first);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Person / Entity Name',
                  hintText: 'e.g. John Doe',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter an amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'e.g. Lunch split',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.indigo),
                title: Text('Date: ${dateFormat.format(_date)}'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: const Text('Change'),
                ),
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
          child: Text(isEditing ? 'Update Record' : 'Save Record'),
        ),
      ],
    );
  }
}
