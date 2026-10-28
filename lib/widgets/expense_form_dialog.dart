import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

/// Modal bottom sheet dialog for adding/editing income and expenses.
class ExpenseFormDialog extends StatefulWidget {
  final Expense? expenseToEdit;
  final Function(Expense) onSave;

  const ExpenseFormDialog({
    super.key,
    this.expenseToEdit,
    required this.onSave,
  });

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _tagsController;
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;
  late TransactionType _transactionType;
  late RecurrencePeriod _recurrencePeriod;
  late String _currencySymbol;

  final List<String> _currencies = ['\$', '€', '£', '₹', '¥'];

  @override
  void initState() {
    super.initState();
    final expense = widget.expenseToEdit;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(2) : '',
    );
    _tagsController = TextEditingController(text: expense?.tags.join(', ') ?? '');
    _selectedDate = expense?.date ?? DateTime.now();
    _selectedCategory = expense?.category ?? ExpenseCategory.food;
    _transactionType = expense?.transactionType ?? TransactionType.expense;
    _recurrencePeriod = expense?.recurrencePeriod ?? RecurrencePeriod.none;
    _currencySymbol = expense?.currencySymbol ?? '\$';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.trim());
      final rawTags = _tagsController.text.split(',');
      final tagsList = rawTags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      final updatedExpense = Expense(
        id: widget.expenseToEdit?.id,
        title: title,
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory,
        transactionType: _transactionType,
        recurrencePeriod: _recurrencePeriod,
        tags: tagsList,
        currencySymbol: _currencySymbol,
      );

      widget.onSave(updatedExpense);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM dd, yyyy');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Transaction' : 'Add New Transaction',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Transaction Type Toggle (Income vs Expense)
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_upward, color: Colors.red),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_downward, color: Colors.green),
                    ),
                  ],
                  selected: {_transactionType},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _transactionType = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Title Input Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Monthly Salary or Grocery',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount & Currency Row
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _currencySymbol,
                      items: _currencies.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _currencySymbol = val);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Picker Row
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              dateFormat.format(_selectedDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Change',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Recurrence Selector
                DropdownButtonFormField<RecurrencePeriod>(
                  initialValue: _recurrencePeriod,
                  decoration: InputDecoration(
                    labelText: 'Repeat Schedule',
                    prefixIcon: const Icon(Icons.repeat),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: RecurrencePeriod.values.map((rp) {
                    return DropdownMenuItem(
                      value: rp,
                      child: Text(rp.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _recurrencePeriod = val);
                  },
                ),
                const SizedBox(height: 16),

                // Tags Input
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'e.g. work, groceries, vacation',
                    prefixIcon: const Icon(Icons.label_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Selection Choice Chips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ExpenseCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          avatar: Icon(
                            cat.icon,
                            size: 18,
                            color: isSelected ? theme.colorScheme.onPrimary : cat.color,
                          ),
                          label: Text(cat.displayName),
                          selected: isSelected,
                          selectedColor: cat.color,
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Transaction' : 'Save Transaction',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
