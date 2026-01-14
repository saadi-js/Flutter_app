import 'package:flutter/material.dart';
import '../models/shared_expense.dart';
import '../models/user.dart';

class BalancesScreen extends StatefulWidget {
  final List<SharedExpense> sharedExpenses;
  final List<User> users;

  const BalancesScreen({
    super.key,
    required this.sharedExpenses,
    required this.users,
  });

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  final Set<String> _settledDebts = {};

  Map<String, double> _calculateBalances() {
    Map<String, double> balances = {};
    
    // Initialize all users with 0 balance
    for (var user in widget.users) {
      balances[user.id] = 0.0;
    }

    // Calculate balances from shared expenses
    for (var expense in widget.sharedExpenses) {
      for (var entry in expense.amountPerPerson.entries) {
        balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
      }
    }

    return balances;
  }

  List<DebtRelationship> _calculateDebts() {
    final balances = _calculateBalances();
    List<DebtRelationship> debts = [];

    // Separate creditors and debtors
    List<MapEntry<String, double>> creditors = [];
    List<MapEntry<String, double>> debtors = [];

    for (var entry in balances.entries) {
      if (entry.value > 0.01) {
        creditors.add(entry);
      } else if (entry.value < -0.01) {
        debtors.add(entry);
      }
    }

    // Sort for consistent ordering
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => a.value.compareTo(b.value));

    // Match creditors with debtors
    int i = 0, j = 0;
    while (i < creditors.length && j < debtors.length) {
      final creditorEntry = creditors[i];
      final debtorEntry = debtors[j];
      
      final creditorAmount = creditorEntry.value;
      final debtorAmount = debtorEntry.value.abs();
      final amount = creditorAmount < debtorAmount ? creditorAmount : debtorAmount;

      debts.add(DebtRelationship(
        debtorId: debtorEntry.key,
        creditorId: creditorEntry.key,
        amount: amount,
      ));

      creditors[i] = MapEntry(creditorEntry.key, creditorEntry.value - amount);
      debtors[j] = MapEntry(debtorEntry.key, debtorEntry.value + amount);

      if (creditors[i].value < 0.01) i++;
      if (debtors[j].value.abs() < 0.01) j++;
    }

    return debts;
  }

  User? _getUserById(String id) {
    try {
      return widget.users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  void _settleDebt(DebtRelationship debt) {
    setState(() {
      final key = '${debt.debtorId}_${debt.creditorId}_${debt.amount}';
      if (_settledDebts.contains(key)) {
        _settledDebts.remove(key);
      } else {
        _settledDebts.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final balances = _calculateBalances();
    final debts = _calculateDebts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balances & Settlements'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: widget.sharedExpenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No shared expenses yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Split an expense to see balances',
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
                // Net Balances Section
                const Text(
                  'Net Balances',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: widget.users.map((user) {
                        final balance = balances[user.id] ?? 0;
                        final isPositive = balance > 0.01;
                        final isNegative = balance < -0.01;
                        final color = isPositive
                            ? Colors.green
                            : isNegative
                                ? Colors.red
                                : Colors.grey;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: user.color,
                                radius: 20,
                                child: Text(
                                  user.getInitials(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      isPositive
                                          ? 'Gets back'
                                          : isNegative
                                              ? 'Owes'
                                              : 'Settled up',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${balance.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Settlements Section
                const Text(
                  'Suggested Settlements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These are the simplest way to settle all balances',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                
                if (debts.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Colors.green[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'All settled up!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No outstanding balances',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...debts.map((debt) {
                    final debtor = _getUserById(debt.debtorId);
                    final creditor = _getUserById(debt.creditorId);
                    
                    if (debtor == null || creditor == null) {
                      return const SizedBox.shrink();
                    }

                    final key = '${debt.debtorId}_${debt.creditorId}_${debt.amount}';
                    final isSettled = _settledDebts.contains(key);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isSettled ? 0 : 2,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isSettled) {
                              _settledDebts.remove(key);
                            } else {
                              _settledDebts.add(key);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Opacity(
                          opacity: isSettled ? 0.5 : 1.0,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: debtor.color,
                                radius: 20,
                                child: Text(
                                  debtor.getInitials(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isSettled)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: debtor.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' pays '),
                                TextSpan(
                                  text: creditor.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text(
                            isSettled ? 'Marked as settled' : 'Tap to mark as settled',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${debt.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSettled ? Colors.grey : Colors.red,
                                  decoration: isSettled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              CircleAvatar(
                                backgroundColor: creditor.color,
                                radius: 16,
                                child: Text(
                                  creditor.getInitials(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: null, // Removed duplicate onTap - handled by InkWell
                        ),
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 24),

                // Expense History
                const Text(
                  'Shared Expense History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.sharedExpenses.reversed.map((expense) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text(expense.title),
                      subtitle: Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year} • ${expense.getSplitTypeString()}',
                      ),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Split Details:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...expense.amountPerPerson.entries.map((entry) {
                                final user = _getUserById(entry.key);
                                if (user == null) return const SizedBox.shrink();
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: user.color,
                                        radius: 12,
                                        child: Text(
                                          user.getInitials(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(user.name)),
                                      Text(
                                        '\$${entry.value.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}

class DebtRelationship {
  final String debtorId;
  final String creditorId;
  final double amount;

  DebtRelationship({
    required this.debtorId,
    required this.creditorId,
    required this.amount,
  });
}
