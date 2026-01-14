import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import '../widgets/total_summary_card.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

/// Home screen displaying expense dashboard
/// Shows total expenses and list of all expenses
/// Implements swipe to delete, long-press to edit, and search/filter
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Store all expenses in a list
  List<Expense> _expenses = [];
  
  // Bulk delete mode
  bool _isBulkDeleteMode = false;
  Set<String> _selectedExpenseIds = {};
  
  // Search and filter
  String _searchQuery = '';
  Set<String> _selectedCategories = {};
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc
  
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Add some sample data for demonstration
    _expenses = [
      Expense(
        title: 'Grocery Shopping',
        amount: 45.50,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Expense(
        title: 'Electricity Bill',
        amount: 120.00,
        category: 'Bills',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Get filtered and sorted expenses
  List<Expense> get _filteredExpenses {
    var filtered = _expenses.where((expense) {
      // Search filter
      final matchesSearch = expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.notes.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Category filter
      final matchesCategory = _selectedCategories.isEmpty || _selectedCategories.contains(expense.category);
      
      return matchesSearch && matchesCategory;
    }).toList();
    
    // Sort
    switch (_sortBy) {
      case 'date_asc':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_desc':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'amount_asc':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'amount_desc':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
    }
    
    return filtered;
  }

  /// Calculate total expenses
  double get _totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Add new expense to the list
  void _addExpense(Expense expense) {
    setState(() {
      _expenses.insert(0, expense); // Add at the beginning for newest first
    });
    
    // Trigger animation
    _animationController.forward(from: 0.0);
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense added successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Delete expense from the list
  void _deleteExpense(int index) {
    final deletedExpense = _expenses[index];
    
    setState(() {
      _expenses.removeAt(index);
    });
    
    // Show snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedExpense.title} deleted'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _expenses.insert(index, deletedExpense);
            });
          },
        ),
      ),
    );
  }

  /// Navigate to add expense screen
  void _navigateToAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
    
    // If expense was added, add it to the list
    if (result != null && result is Expense) {
      _addExpense(result);
    }
  }

  /// Navigate to edit expense screen
  void _navigateToEditExpense(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(expense: expense),
      ),
    );
    
    // If expense was edited, update it in the list
    if (result != null && result is Expense) {
      setState(() {
        final index = _expenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _expenses[index] = result;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense updated successfully!'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Toggle bulk delete mode
  void _toggleBulkDeleteMode() {
    setState(() {
      _isBulkDeleteMode = !_isBulkDeleteMode;
      _selectedExpenseIds.clear();
    });
  }

  /// Toggle expense selection in bulk mode
  void _toggleExpenseSelection(String expenseId) {
    setState(() {
      if (_selectedExpenseIds.contains(expenseId)) {
        _selectedExpenseIds.remove(expenseId);
      } else {
        _selectedExpenseIds.add(expenseId);
      }
    });
  }

  /// Delete selected expenses in bulk mode
  void _deleteSelectedExpenses() async {
    if (_selectedExpenseIds.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Expenses'),
        content: Text(
          'Are you sure you want to delete ${_selectedExpenseIds.length} expense(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _expenses.removeWhere((expense) => _selectedExpenseIds.contains(expense.id));
        _selectedExpenseIds.clear();
        _isBulkDeleteMode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Selected expenses deleted'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Filter & Sort'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Food', 'Travel', 'Bills', 'Shopping', 'Other'].map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: _selectedCategories.contains(category),
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort By',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<String>(
                    title: const Text('Date (Newest First)'),
                    value: 'date_desc',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setDialogState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Date (Oldest First)'),
                    value: 'date_asc',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setDialogState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Amount (High to Low)'),
                    value: 'amount_desc',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setDialogState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Amount (Low to High)'),
                    value: 'amount_asc',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setDialogState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setDialogState(() {
                    _selectedCategories.clear();
                    _sortBy = 'date_desc';
                  });
                },
                child: const Text('Clear All'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {}); // Update main screen
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Show expense details dialog
  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Expense Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildDetailRow('Title', expense.title),
              const SizedBox(height: 12),
              _buildDetailRow('Amount', expense.formattedAmount),
              const SizedBox(height: 12),
              _buildDetailRow('Category', expense.category),
              const SizedBox(height: 12),
              _buildDetailRow('Date', expense.formattedDate),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
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
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _filteredExpenses;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: _isBulkDeleteMode
            ? Text('${_selectedExpenseIds.length} selected')
            : const Text(
                'TrackWise',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          if (_isBulkDeleteMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  if (_selectedExpenseIds.length == filteredExpenses.length) {
                    _selectedExpenseIds.clear();
                  } else {
                    _selectedExpenseIds = filteredExpenses.map((e) => e.id).toSet();
                  }
                });
              },
              tooltip: 'Select All',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedExpenses,
              tooltip: 'Delete Selected',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleBulkDeleteMode,
              tooltip: 'Cancel',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
              tooltip: 'Filter & Sort',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'bulk_delete') {
                  _toggleBulkDeleteMode();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'bulk_delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep),
                      SizedBox(width: 8),
                      Text('Bulk Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Total summary card
          TotalSummaryCard(totalAmount: _totalExpenses),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filter chips
          if (_selectedCategories.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _selectedCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(category),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedCategories.remove(category);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // Result count
          if (_searchQuery.isNotEmpty || _selectedCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${filteredExpenses.length} expense(s) found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          
          // Expenses list
          Expanded(
            child: filteredExpenses.isEmpty
                ? _buildEmptyState()
                : _buildExpensesList(filteredExpenses),
          ),
        ],
      ),
      
      // Floating action button to add expense (hidden in bulk delete mode)
      floatingActionButton: _isBulkDeleteMode
          ? null
          : FloatingActionButton.extended(
              heroTag: 'home_fab',
              onPressed: _navigateToAddExpense,
              backgroundColor: const Color(0xFF6C63FF),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
    );
  }

  /// Build empty state UI when no expenses exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add one.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Build scrollable list of expenses with swipe to delete
  Widget _buildExpensesList(List<Expense> expenses) {
    return ListView.builder(
      itemCount: expenses.length,
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final isSelected = _selectedExpenseIds.contains(expense.id);
        
        Widget expenseWidget = ExpenseCard(
          expense: expense,
          onTap: () {
            if (_isBulkDeleteMode) {
              _toggleExpenseSelection(expense.id);
            } else {
              _showExpenseDetails(expense);
            }
          },
          onEdit: _isBulkDeleteMode ? null : () => _navigateToEditExpense(expense),
          onDelete: _isBulkDeleteMode ? null : () => _deleteExpense(_expenses.indexOf(expense)),
        );
        
        // Wrap in checkbox for bulk delete mode
        if (_isBulkDeleteMode) {
          expenseWidget = Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleExpenseSelection(expense.id),
              ),
              Expanded(child: expenseWidget),
            ],
          );
        } else {
          // Dismissible only in normal mode
          expenseWidget = Dismissible(
            key: Key(expense.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 32,
              ),
            ),
            confirmDismiss: (direction) async {
              // Show confirmation dialog
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Delete Expense'),
                  content: Text(
                    'Are you sure you want to delete "${expense.title}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              final expenseIndex = _expenses.indexWhere((e) => e.id == expense.id);
              if (expenseIndex != -1) {
                _deleteExpense(expenseIndex);
              }
            },
            child: expenseWidget,
          );
        }
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: index == 0 && !_isBulkDeleteMode
                  ? _animationController
                  : const AlwaysStoppedAnimation(1.0),
              child: SlideTransition(
                position: index == 0 && !_isBulkDeleteMode
                    ? Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      ))
                    : const AlwaysStoppedAnimation(Offset.zero),
                child: child,
              ),
            );
          },
          child: expenseWidget,
        );
      },
    );
  }
}
