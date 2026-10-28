import 'package:flutter/material.dart';
import '../database/expense_database.dart';
import '../models/savings_goal.dart';
import '../services/app_settings.dart';
import '../widgets/savings_goal_dialog.dart';

/// Screen managing personal savings goals, deposit targets, and celebration banners.
class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  List<SavingsGoal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    final goals = await ExpenseDatabase.instance.getAllSavingsGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  void _openGoalModal([SavingsGoal? goal]) {
    showDialog(
      context: context,
      builder: (ctx) => SavingsGoalDialog(
        goalToEdit: goal,
        onSave: (updatedGoal) async {
          if (updatedGoal.id == null) {
            await ExpenseDatabase.instance.insertSavingsGoal(updatedGoal);
          } else {
            await ExpenseDatabase.instance.updateSavingsGoal(updatedGoal);
          }
          _loadGoals();
        },
      ),
    );
  }

  Future<void> _deleteGoal(int id) async {
    await ExpenseDatabase.instance.deleteSavingsGoal(id);
    _loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.savings_outlined, size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 12),
                      const Text('No savings goals added yet.', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _openGoalModal(),
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Goal'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final pct = goal.progressPercentage;

                    return Dismissible(
                      key: Key('goal_${goal.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.white, size: 28),
                      ),
                      onDismissed: (_) {
                        if (goal.id != null) _deleteGoal(goal.id!);
                      },
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: goal.isCompleted
                                ? Colors.green.withValues(alpha: 0.8)
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            width: goal.isCompleted ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (goal.isCompleted) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.emoji_events, color: Colors.green, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        '🎉 Goal Achieved! 100% Target Met',
                                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: goal.color.withValues(alpha: 0.2),
                                    child: Icon(Icons.savings, color: goal.color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.title,
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Saved ${settings.formatAmount(goal.currentAmount)} of ${settings.formatAmount(goal.targetAmount)}',
                                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _openGoalModal(goal),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _deleteGoal(goal.id!),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 8,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(goal.isCompleted ? Colors.green : goal.color),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(pct * 100).toStringAsFixed(1)}% Completed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: goal.isCompleted ? Colors.green : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGoalModal(),
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
    );
  }
}
