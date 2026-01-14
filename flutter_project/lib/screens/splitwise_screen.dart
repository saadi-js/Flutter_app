import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/shared_expense.dart';
import 'users_screen.dart';
import 'split_expense_screen.dart';
import 'balances_screen.dart';

class SplitwiseScreen extends StatelessWidget {
  final List<User> users;
  final List<SharedExpense> sharedExpenses;
  final Function(User) onAddUser;
  final Function(User) onUpdateUser;
  final Function(String) onDeleteUser;
  final Function(SharedExpense) onSplitExpense;

  const SplitwiseScreen({
    super.key,
    required this.users,
    required this.sharedExpenses,
    required this.onAddUser,
    required this.onUpdateUser,
    required this.onDeleteUser,
    required this.onSplitExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splitwise'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Stats Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        Icons.people,
                        users.length.toString(),
                        'Users',
                        Colors.blue,
                        onTap: () => _showUsersDialog(context),
                      ),
                      _buildStatItem(
                        context,
                        Icons.receipt_long,
                        sharedExpenses.length.toString(),
                        'Expenses',
                        Colors.purple,
                        onTap: () => _showExpensesDialog(context),
                      ),
                      _buildStatItem(
                        context,
                        Icons.attach_money,
                        '\$${_getTotalAmount().toStringAsFixed(0)}',
                        'Total',
                        Colors.green,
                        onTap: () => _showTotalDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Navigation Cards
          _buildNavigationCard(
            context,
            icon: Icons.people,
            title: 'Manage Users',
            subtitle: 'Add or edit people to split expenses with',
            color: const Color(0xFF6C63FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersScreen(
                    users: users,
                    onAddUser: onAddUser,
                    onUpdateUser: onUpdateUser,
                    onDeleteUser: onDeleteUser,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _buildNavigationCard(
            context,
            icon: Icons.call_split,
            title: 'Split Expense',
            subtitle: 'Create a new shared expense',
            color: const Color(0xFF4ECDC4),
            onTap: () {
              if (users.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add users first'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SplitExpenseScreen(
                    users: users,
                    onSplitExpense: onSplitExpense,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _buildNavigationCard(
            context,
            icon: Icons.account_balance_wallet,
            title: 'Balances & Settlements',
            subtitle: 'View who owes whom and settle up',
            color: const Color(0xFFFF6B6B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BalancesScreen(
                    sharedExpenses: sharedExpenses,
                    users: users,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Recent Shared Expenses
          if (sharedExpenses.isNotEmpty) ...[
            const Text(
              'Recent Shared Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...sharedExpenses.reversed.take(5).map((expense) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  title: Text(expense.title),
                  subtitle: Text(
                    '${expense.date.day}/${expense.date.month}/${expense.date.year} • ${expense.participantIds.length} people',
                  ),
                  trailing: Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Users'),
        content: SizedBox(
          width: double.maxFinite,
          child: users.isEmpty
              ? const Text('No users yet')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.color,
                        child: Text(
                          user.getInitials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: user.email != null ? Text(user.email!) : null,
                    );
                  },
                ),
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

  void _showExpensesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Shared Expenses'),
        content: SizedBox(
          width: double.maxFinite,
          child: sharedExpenses.isEmpty
              ? const Text('No shared expenses yet')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: sharedExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = sharedExpenses[index];
                    return ListTile(
                      leading: const Icon(Icons.receipt, color: Color(0xFF6C63FF)),
                      title: Text(expense.title),
                      subtitle: Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year} • ${expense.participantIds.length} people',
                      ),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    );
                  },
                ),
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

  void _showTotalDialog(BuildContext context) {
    final total = _getTotalAmount();
    final avgPerExpense = sharedExpenses.isEmpty ? 0.0 : total / sharedExpenses.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Total Amount Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Total Shared', '\$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildDetailRow('Number of Expenses', sharedExpenses.length.toString()),
            const SizedBox(height: 8),
            _buildDetailRow('Average per Expense', '\$${avgPerExpense.toStringAsFixed(2)}'),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTotalAmount() {
    return sharedExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
