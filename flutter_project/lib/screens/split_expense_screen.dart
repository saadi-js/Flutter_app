import 'package:flutter/material.dart';
import '../models/shared_expense.dart';
import '../models/user.dart';

class SplitExpenseScreen extends StatefulWidget {
  final List<User> users;
  final Function(SharedExpense) onSplitExpense;

  const SplitExpenseScreen({
    super.key,
    required this.users,
    required this.onSplitExpense,
  });

  @override
  State<SplitExpenseScreen> createState() => _SplitExpenseScreenState();
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
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

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  SplitType _splitType = SplitType.equal;
  Set<String> _selectedParticipants = {};
  
  // For different split types
  Map<String, double> _percentages = {};
  Map<String, double> _exactAmounts = {};
  Map<String, double> _shares = {};

  @override
  void initState() {
    super.initState();
    // Pre-select all users by default
    _selectedParticipants = widget.users.map((u) => u.id).toSet();
  }

  Map<String, double>? _calculateSplit() {
    if (_selectedParticipants.isEmpty || _amountController.text.isEmpty) {
      return null;
    }

    final totalAmount = double.tryParse(_amountController.text) ?? 0;
    if (totalAmount == 0) return null;

    Map<String, double> result = {};

    switch (_splitType) {
      case SplitType.equal:
        final perPerson = totalAmount / _selectedParticipants.length;
        for (var userId in _selectedParticipants) {
          result[userId] = perPerson;
        }
        break;

      case SplitType.percentage:
        for (var userId in _selectedParticipants) {
          final percentage = _percentages[userId] ?? 0;
          result[userId] = (totalAmount * percentage) / 100;
        }
        break;

      case SplitType.exact:
        for (var userId in _selectedParticipants) {
          result[userId] = _exactAmounts[userId] ?? 0;
        }
        break;

      case SplitType.shares:
        final totalShares = _shares.values.fold(0.0, (sum, shares) => sum + shares);
        if (totalShares > 0) {
          for (var userId in _selectedParticipants) {
            final shares = _shares[userId] ?? 0;
            result[userId] = (totalAmount * shares) / totalShares;
          }
        }
        break;
    }

    return result;
  }

  void _saveSplitExpense() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    final amountPerPerson = _calculateSplit();
    if (amountPerPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error calculating split')),
      );
      return;
    }

    // Validate split
    if (_splitType == SplitType.percentage) {
      final totalPercentage = _percentages.values.fold(0.0, (sum, p) => sum + p);
      if ((totalPercentage - 100).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Percentages must add up to 100%')),
        );
        return;
      }
    } else if (_splitType == SplitType.exact) {
      final totalExact = _exactAmounts.values.fold(0.0, (sum, a) => sum + a);
      final totalAmount = double.parse(_amountController.text);
      if ((totalExact - totalAmount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exact amounts must add up to total')),
        );
        return;
      }
    }

    final sharedExpense = SharedExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: _selectedDate,
      notes: _notesController.text,
      participantIds: _selectedParticipants.toList(),
      splitType: _splitType,
      amountPerPerson: amountPerPerson,
    );

    widget.onSplitExpense(sharedExpense);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Split Expense'),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No users available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add users first to split expenses',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalAmount = double.tryParse(_amountController.text) ?? 0;
    final amountPerPerson = _calculateSplit();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Expense'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Basic expense details
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Expense Title *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Total Amount *',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
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
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          
          // Split type selector
          const Text(
            'Split Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<SplitType>(
            segments: const [
              ButtonSegment(
                value: SplitType.equal,
                label: Text('Equal'),
                icon: Icon(Icons.people),
              ),
              ButtonSegment(
                value: SplitType.percentage,
                label: Text('%'),
                icon: Icon(Icons.percent),
              ),
            ],
            selected: {_splitType},
            onSelectionChanged: (Set<SplitType> newSelection) {
              setState(() {
                _splitType = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 8),
          SegmentedButton<SplitType>(
            segments: const [
              ButtonSegment(
                value: SplitType.exact,
                label: Text('Exact'),
                icon: Icon(Icons.attach_money),
              ),
              ButtonSegment(
                value: SplitType.shares,
                label: Text('Shares'),
                icon: Icon(Icons.pie_chart),
              ),
            ],
            selected: {_splitType},
            onSelectionChanged: (Set<SplitType> newSelection) {
              setState(() {
                _splitType = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),

          // Participants
          const Text(
            'Select Participants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.users.map((user) {
            final isSelected = _selectedParticipants.contains(user.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedParticipants.add(user.id);
                      // Initialize values
                      if (_splitType == SplitType.percentage) {
                        _percentages[user.id] = 100.0 / widget.users.length;
                      } else if (_splitType == SplitType.shares) {
                        _shares[user.id] = 1.0;
                      } else if (_splitType == SplitType.exact && totalAmount > 0) {
                        _exactAmounts[user.id] = totalAmount / widget.users.length;
                      }
                    } else {
                      _selectedParticipants.remove(user.id);
                      _percentages.remove(user.id);
                      _exactAmounts.remove(user.id);
                      _shares.remove(user.id);
                    }
                  });
                },
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: user.color,
                      radius: 16,
                      child: Text(
                        user.getInitials(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(user.name)),
                  ],
                ),
                subtitle: isSelected ? _buildSplitInput(user) : null,
                activeColor: const Color(0xFF6C63FF),
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Split breakdown
          if (totalAmount > 0 && _selectedParticipants.isNotEmpty) ...[
            const Text(
              'Split Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...widget.users
                        .where((u) => _selectedParticipants.contains(u.id))
                        .map((user) {
                      final amount = amountPerPerson?[user.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: user.color,
                              radius: 16,
                              child: Text(
                                user.getInitials(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(user.name)),
                            Text(
                              '\$${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSplitExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Split Expense',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitInput(User user) {
    switch (_splitType) {
      case SplitType.equal:
        final amount = _amountController.text.isEmpty
            ? 0.0
            : (double.parse(_amountController.text) / _selectedParticipants.length);
        return Text('\$${amount.toStringAsFixed(2)}');

      case SplitType.percentage:
        return TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: '%',
            isDense: true,
          ),
          onChanged: (value) {
            setState(() {
              _percentages[user.id] = double.tryParse(value) ?? 0;
            });
          },
          controller: TextEditingController(
            text: _percentages[user.id]?.toStringAsFixed(1) ?? '',
          ),
        );

      case SplitType.exact:
        return TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '\$ ',
            isDense: true,
          ),
          onChanged: (value) {
            setState(() {
              _exactAmounts[user.id] = double.tryParse(value) ?? 0;
            });
          },
          controller: TextEditingController(
            text: _exactAmounts[user.id]?.toStringAsFixed(2) ?? '',
          ),
        );

      case SplitType.shares:
        return TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: 'shares',
            isDense: true,
          ),
          onChanged: (value) {
            setState(() {
              _shares[user.id] = double.tryParse(value) ?? 0;
            });
          },
          controller: TextEditingController(
            text: _shares[user.id]?.toStringAsFixed(0) ?? '',
          ),
        );
    }
  }
}
