import 'package:flutter/material.dart';
import '../models/recurring_expense.dart';
import '../models/expense.dart';

class RecurringScreen extends StatefulWidget {
  final List<RecurringExpense> recurringExpenses;
  final Function(RecurringExpense) onAddRecurring;
  final Function(RecurringExpense) onUpdateRecurring;
  final Function(String) onDeleteRecurring;
  final Function(Expense) onGenerateExpense;

  const RecurringScreen({
    super.key,
    required this.recurringExpenses,
    required this.onAddRecurring,
    required this.onUpdateRecurring,
    required this.onDeleteRecurring,
    required this.onGenerateExpense,
  });

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Healthcare',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-generate expenses on screen load
    _checkAndGenerateExpenses();
  }

  void _checkAndGenerateExpenses() {
    final now = DateTime.now();
    for (var recurring in widget.recurringExpenses) {
      if (recurring.isActive && now.isAfter(recurring.nextDue)) {
        _generateExpense(recurring);
      }
    }
  }

  void _generateExpense(RecurringExpense recurring) {
    // Create expense from recurring template
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: recurring.title,
      amount: recurring.amount,
      category: recurring.category,
      date: recurring.nextDue,
      notes: '${recurring.notes}\n(Auto-generated from recurring expense)',
    );

    widget.onGenerateExpense(expense);

    // Update recurring expense with new next due date
    final updatedRecurring = recurring.copyWith(
      lastGenerated: recurring.nextDue,
      nextDue: recurring.calculateNextDue(),
    );

    widget.onUpdateRecurring(updatedRecurring);
  }

  void _showAddEditDialog({RecurringExpense? recurring}) {
    final isEditing = recurring != null;
    final titleController = TextEditingController(text: recurring?.title ?? '');
    final amountController = TextEditingController(
      text: recurring?.amount.toStringAsFixed(2) ?? '',
    );
    final notesController = TextEditingController(text: recurring?.notes ?? '');
    
    String selectedCategory = recurring?.category ?? _categories[0];
    RecurrencePattern selectedPattern = recurring?.pattern ?? RecurrencePattern.monthly;
    DateTime selectedNextDue = recurring?.nextDue ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Recurring Expense' : 'Add Recurring Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(category), size: 20),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RecurrencePattern>(
                  value: selectedPattern,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                  items: RecurrencePattern.values.map((pattern) {
                    return DropdownMenuItem(
                      value: pattern,
                      child: Text(_getPatternName(pattern)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedPattern = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Next Due Date'),
                  subtitle: Text(
                    '${selectedNextDue.day}/${selectedNextDue.month}/${selectedNextDue.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedNextDue,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedNextDue = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty || amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }

                final newRecurring = RecurringExpense(
                  id: recurring?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  category: selectedCategory,
                  pattern: selectedPattern,
                  lastGenerated: recurring?.lastGenerated ?? DateTime.now(),
                  nextDue: selectedNextDue,
                  notes: notesController.text,
                  isActive: recurring?.isActive ?? true,
                );

                if (isEditing) {
                  widget.onUpdateRecurring(newRecurring);
                } else {
                  widget.onAddRecurring(newRecurring);
                }

                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteRecurring(RecurringExpense recurring) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Expense'),
        content: Text('Are you sure you want to delete "${recurring.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDeleteRecurring(recurring.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleActive(RecurringExpense recurring) {
    final updated = recurring.copyWith(isActive: !recurring.isActive);
    widget.onUpdateRecurring(updated);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills':
        return Icons.receipt_long;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  String _getPatternName(RecurrencePattern pattern) {
    switch (pattern) {
      case RecurrencePattern.daily:
        return 'Daily';
      case RecurrencePattern.weekly:
        return 'Weekly';
      case RecurrencePattern.monthly:
        return 'Monthly';
      case RecurrencePattern.yearly:
        return 'Yearly';
    }
  }

  Color _getPatternColor(RecurrencePattern pattern) {
    switch (pattern) {
      case RecurrencePattern.daily:
        return Colors.orange;
      case RecurrencePattern.weekly:
        return Colors.blue;
      case RecurrencePattern.monthly:
        return Colors.purple;
      case RecurrencePattern.yearly:
        return Colors.green;
    }
  }

  int _getDaysUntilDue(DateTime nextDue) {
    final now = DateTime.now();
    final difference = nextDue.difference(now);
    return difference.inDays;
  }

  @override
  Widget build(BuildContext context) {
    final activeRecurring = widget.recurringExpenses.where((r) => r.isActive).toList();
    final inactiveRecurring = widget.recurringExpenses.where((r) => !r.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Expenses'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: widget.recurringExpenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recurring expenses',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first one',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (activeRecurring.isNotEmpty) ...[
                  const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...activeRecurring.map((recurring) => _buildRecurringCard(recurring)),
                ],
                if (inactiveRecurring.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Inactive',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...inactiveRecurring.map((recurring) => _buildRecurringCard(recurring)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'recurring_fab',
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRecurringCard(RecurringExpense recurring) {
    final daysUntilDue = _getDaysUntilDue(recurring.nextDue);
    final isOverdue = daysUntilDue < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: recurring.isActive ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getPatternColor(recurring.pattern).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(recurring.category),
                      color: _getPatternColor(recurring.pattern),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recurring.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getPatternColor(recurring.pattern).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                recurring.getPatternString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getPatternColor(recurring.pattern),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              recurring.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${recurring.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Switch(
                        value: recurring.isActive,
                        onChanged: (_) => _toggleActive(recurring),
                        activeColor: const Color(0xFF6C63FF),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.warning : Icons.schedule,
                      size: 16,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isOverdue
                            ? 'Overdue by ${daysUntilDue.abs()} day${daysUntilDue.abs() == 1 ? '' : 's'}'
                            : daysUntilDue == 0
                                ? 'Due today'
                                : 'Due in $daysUntilDue day${daysUntilDue == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      'Next: ${recurring.nextDue.day}/${recurring.nextDue.month}/${recurring.nextDue.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (recurring.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  recurring.notes,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddEditDialog(recurring: recurring),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _deleteRecurring(recurring),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
