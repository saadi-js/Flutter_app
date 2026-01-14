import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

/// Budget management screen
/// Shows category budgets with progress bars and alerts
class BudgetScreen extends StatefulWidget {
  final List<Expense> expenses;

  const BudgetScreen({
    Key? key,
    required this.expenses,
  }) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Budget> _budgets = [];
  String _selectedPeriod = 'monthly'; // daily, weekly, monthly

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgets = await StorageService.loadBudgets();
    setState(() {
      _budgets = budgets;
    });
  }

  /// Calculate spent amount for a category in the selected period
  double _getSpentAmount(String category) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'monthly':
      default:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }

    return widget.expenses
        .where((expense) =>
            expense.category == category &&
            expense.date.isAfter(startDate.subtract(const Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get budget status color
  Color _getBudgetColor(double spent, double budget) {
    final percentage = (spent / budget) * 100;
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }

  /// Get budget status text
  String _getBudgetStatus(double spent, double budget) {
    final percentage = (spent / budget) * 100;
    if (percentage < 50) return 'On Track';
    if (percentage < 80) return 'Warning';
    if (percentage < 100) return 'Near Limit';
    return 'Exceeded';
  }

  /// Show add/edit budget dialog
  void _showBudgetDialog({Budget? budget}) {
    final isEdit = budget != null;
    String selectedCategory = budget?.category ?? 'Food';
    double amount = budget?.amount ?? 100;
    String period = budget?.period ?? 'monthly';

    final amountController = TextEditingController(text: amount.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isEdit ? 'Edit Budget' : 'Add Budget'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['Food', 'Travel', 'Bills', 'Shopping', 'Other']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedCategory = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixText: '\$ ',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: period,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['daily', 'weekly', 'monthly']
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p[0].toUpperCase() + p.substring(1)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => period = value!);
                    },
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
                onPressed: () async {
                  final newAmount = double.tryParse(amountController.text) ?? 0;
                  if (newAmount > 0) {
                    setState(() {
                      if (isEdit) {
                        final index = _budgets.indexWhere((b) => b.category == budget.category);
                        if (index != -1) {
                          _budgets[index] = Budget(
                            category: selectedCategory,
                            amount: newAmount,
                            period: period,
                          );
                        }
                      } else {
                        _budgets.add(Budget(
                          category: selectedCategory,
                          amount: newAmount,
                          period: period,
                        ));
                      }
                    });
                    await StorageService.saveBudgets(_budgets);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                child: Text(isEdit ? 'Update' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Delete budget
  void _deleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the budget for ${budget.category}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _budgets.removeWhere((b) => b.category == budget.category);
      });
      await StorageService.saveBudgets(_budgets);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter budgets by selected period
    final filteredBudgets = _budgets.where((b) => b.period == _selectedPeriod).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Budget Management', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showBudgetDialog(),
            tooltip: 'Add Budget',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildBudgetSummary(),
          Expanded(child: _buildBudgetList(filteredBudgets)),
        ],
      ),
    );
  }

  /// Period selector
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF6C63FF),
      child: Row(
        children: ['daily', 'weekly', 'monthly'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => setState(() => _selectedPeriod = period),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                  foregroundColor: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(period[0].toUpperCase() + period.substring(1)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Budget summary card
  Widget _buildBudgetSummary() {
    final totalBudget = _budgets.where((b) => b.period == _selectedPeriod).fold(0.0, (sum, b) => sum + b.amount);
    final totalSpent = _budgets.where((b) => b.period == _selectedPeriod).fold(0.0, (sum, b) => sum + _getSpentAmount(b.category));
    final remaining = totalBudget - totalSpent;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Budget', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('\$${totalBudget.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0,
            backgroundColor: Colors.white30,
            valueColor: AlwaysStoppedAnimation(
              _getBudgetColor(totalSpent, totalBudget),
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('\$${totalSpent.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Remaining', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    '\$${remaining.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: remaining >= 0 ? Colors.white : Colors.red[200],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Budget list
  Widget _buildBudgetList(List<Budget> budgets) {
    if (budgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No budgets set for $_selectedPeriod period',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showBudgetDialog(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              icon: const Icon(Icons.add),
              label: const Text('Add Budget'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        final spent = _getSpentAmount(budget.category);
        final percentage = (spent / budget.amount * 100).clamp(0.0, 100.0);
        final color = _getBudgetColor(spent, budget.amount);
        final status = _getBudgetStatus(spent, budget.amount);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_getCategoryIcon(budget.category), color: color),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.category,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              status,
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showBudgetDialog(budget: budget),
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteBudget(budget),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${spent.toStringAsFixed(2)} spent', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Text('\$${budget.amount.toStringAsFixed(2)} budget', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (spent / budget.amount).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 10,
                ),
                const SizedBox(height: 8),
                Text(
                  '${percentage.toStringAsFixed(1)}% used',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get category icon
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Travel':
        return Icons.flight;
      case 'Bills':
        return Icons.receipt;
      case 'Shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}
