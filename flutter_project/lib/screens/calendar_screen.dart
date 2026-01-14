import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';

/// Calendar view screen showing monthly expense overview
/// Displays daily expense totals with heat map coloring
class CalendarScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense, Expense) onUpdateExpense;
  final Function(Expense) onDeleteExpense;

  const CalendarScreen({
    Key? key,
    required this.expenses,
    required this.onUpdateExpense,
    required this.onDeleteExpense,
  }) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  /// Get expenses for a specific date
  List<Expense> _getExpensesForDate(DateTime date) {
    return widget.expenses.where((expense) {
      return expense.date.year == date.year &&
          expense.date.month == date.month &&
          expense.date.day == date.day;
    }).toList();
  }

  /// Calculate total expenses for a date
  double _getTotalForDate(DateTime date) {
    final expenses = _getExpensesForDate(date);
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get heat map color based on amount
  Color _getHeatMapColor(double amount) {
    if (amount == 0) return Colors.grey[200]!;
    
    // Calculate max amount in the month for scaling
    final maxAmount = _getMaxAmountInMonth();
    if (maxAmount == 0) return Colors.grey[200]!;
    
    final intensity = (amount / maxAmount).clamp(0.0, 1.0);
    
    if (intensity < 0.2) {
      return const Color(0xFF6C63FF).withOpacity(0.2);
    } else if (intensity < 0.4) {
      return const Color(0xFF6C63FF).withOpacity(0.4);
    } else if (intensity < 0.6) {
      return const Color(0xFF6C63FF).withOpacity(0.6);
    } else if (intensity < 0.8) {
      return const Color(0xFF6C63FF).withOpacity(0.8);
    } else {
      return const Color(0xFF6C63FF);
    }
  }

  /// Get maximum amount spent in a single day this month
  double _getMaxAmountInMonth() {
    double maxAmount = 0;
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final total = _getTotalForDate(date);
      if (total > maxAmount) maxAmount = total;
    }
    
    return maxAmount;
  }

  /// Calculate month total
  double _getMonthTotal() {
    return widget.expenses.where((expense) {
      return expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
    }).fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Go to previous month
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _selectedDate = null;
    });
  }

  /// Go to next month
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Calendar View', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMonthNavigator(),
            _buildMonthSummary(),
            _buildCalendar(),
            if (_selectedDate != null) _buildDayExpenses(),
          ],
        ),
      ),
    );
  }

  /// Month navigation header
  Widget _buildMonthNavigator() {
    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                        'July', 'August', 'September', 'October', 'November', 'December'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF6C63FF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _previousMonth,
          ),
          Text(
            '${monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  /// Month summary card
  Widget _buildMonthSummary() {
    final monthTotal = _getMonthTotal();
    
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Month Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
            ],
          ),
          Text(
            '\$${monthTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Calendar grid
  Widget _buildCalendar() {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayOfWeek = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;
    
    // Calculate starting position (1 = Monday, 7 = Sunday)
    final startOffset = firstDayOfWeek % 7; // 0 for Sunday, 1 for Monday, etc.
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // Calendar days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox(); // Empty space before month starts
              }
              
              final day = index - startOffset + 1;
              final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
              final total = _getTotalForDate(date);
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF6C63FF)
                        : _getHeatMapColor(total),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected || (total > 0 && _getHeatMapColor(total).opacity > 0.5)
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      if (total > 0)
                        Text(
                          '\$${total.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 8,
                            color: isSelected || _getHeatMapColor(total).opacity > 0.5
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Day expenses list
  Widget _buildDayExpenses() {
    final expenses = _getExpensesForDate(_selectedDate!);
    
    if (expenses.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No expenses on this day',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    final dayTotal = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${dayTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ExpenseCard(
                  expense: expense,
                  onTap: () => _showExpenseDetails(expense),
                  onEdit: () => _navigateToEditExpense(expense),
                  onDelete: () => _deleteExpenseWithConfirmation(expense),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Show expense details dialog
  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(expense.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${expense.formattedAmount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Category: ${expense.category}'),
            Text('Date: ${expense.formattedDate}'),
            if (expense.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${expense.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Navigate to edit expense screen
  void _navigateToEditExpense(Expense expense) async {
    // This would navigate to edit screen
    // Implementation depends on your navigation setup
  }

  /// Delete expense with confirmation
  void _deleteExpenseWithConfirmation(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
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
      widget.onDeleteExpense(expense);
      setState(() {
        // Refresh the view after deletion
      });
    }
  }
}
