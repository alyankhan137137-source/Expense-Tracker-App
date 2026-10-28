import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/expense_database.dart';
import '../models/debt.dart';
import '../services/app_settings.dart';
import '../widgets/debt_dialog.dart';

/// Screen managing debts, loans, and IOUs with swipe gestures and settled status badges.
class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  List<Debt> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    setState(() => _isLoading = true);
    final debts = await ExpenseDatabase.instance.getAllDebts();
    setState(() {
      _debts = debts;
      _isLoading = false;
    });
  }

  void _openDebtModal([Debt? debt]) {
    showDialog(
      context: context,
      builder: (ctx) => DebtDialog(
        debtToEdit: debt,
        onSave: (updatedDebt) async {
          if (updatedDebt.id == null) {
            await ExpenseDatabase.instance.insertDebt(updatedDebt);
          } else {
            await ExpenseDatabase.instance.updateDebt(updatedDebt);
          }
          _loadDebts();
        },
      ),
    );
  }

  Future<void> _toggleSettled(Debt debt) async {
    final updated = debt.copyWith(isSettled: !debt.isSettled);
    await ExpenseDatabase.instance.updateDebt(updated);
    _loadDebts();
  }

  Future<void> _deleteDebt(int id) async {
    await ExpenseDatabase.instance.deleteDebt(id);
    _loadDebts();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);

    double totalIOwe = 0.0;
    double totalOwedToMe = 0.0;

    for (var d in _debts) {
      if (!d.isSettled) {
        if (d.isIowe) {
          totalIOwe += d.amount;
        } else {
          totalOwedToMe += d.amount;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts & IOUs', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('I Owe Others', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(settings.formatAmount(totalIOwe), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                      ),
                      Container(height: 30, width: 1, color: theme.colorScheme.outlineVariant),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Owed to Me', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(settings.formatAmount(totalOwedToMe), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Debt List with Swipe Gestures
                Expanded(
                  child: _debts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.handshake_outlined, size: 64, color: theme.colorScheme.outline),
                              const SizedBox(height: 12),
                              const Text('No debts or IOUs recorded.', style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => _openDebtModal(),
                                icon: const Icon(Icons.add),
                                label: const Text('Record First IOU'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _debts.length,
                          itemBuilder: (context, index) {
                            final debt = _debts[index];
                            final color = debt.isIowe ? Colors.red : Colors.green;

                            return Dismissible(
                              key: Key('debt_${debt.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.delete, color: Colors.white, size: 28),
                              ),
                              onDismissed: (_) {
                                if (debt.id != null) _deleteDebt(debt.id!);
                              },
                              child: Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color.withValues(alpha: 0.15),
                                    child: Icon(debt.isIowe ? Icons.arrow_upward : Icons.arrow_downward, color: color),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          debt.personName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration: debt.isSettled ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                      if (debt.isSettled)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('Settled', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    '${debt.isIowe ? 'I owe' : 'Owes me'} • ${dateFormat.format(debt.date)}${debt.note.isNotEmpty ? ' (${debt.note})' : ''}',
                                    style: TextStyle(decoration: debt.isSettled ? TextDecoration.lineThrough : null),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        settings.formatAmount(debt.amount),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: debt.isSettled ? theme.colorScheme.outline : color,
                                          decoration: debt.isSettled ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      Checkbox(
                                        value: debt.isSettled,
                                        onChanged: (_) => _toggleSettled(debt),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _deleteDebt(debt.id!),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDebtModal(),
        icon: const Icon(Icons.add),
        label: const Text('Add IOU'),
      ),
    );
  }
}
