import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/recurring_expense.dart';
import '../models/user.dart';
import '../models/shared_expense.dart';
import '../services/storage_service.dart';
import '../widgets/expense_card.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'budget_screen.dart';
import 'recurring_screen.dart';
import 'splitwise_screen.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

/// Main navigation wrapper with bottom navigation bar
/// Manages navigation between Home, Analytics, and future screens
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  
  // Shared expenses list across tabs
  List<Expense> _expenses = [];
  
  // Recurring expenses
  List<RecurringExpense> _recurringExpenses = [];
  
  // Splitwise data
  List<User> _users = [];
  List<SharedExpense> _sharedExpenses = [];
  
  // Bulk delete mode
  bool _isBulkDeleteMode = false;
  Set<String> _selectedExpenseIds = {};
  
  // Search and filter
  String _searchQuery = '';
  Set<String> _selectedCategories = {};
  String _sortBy = 'date_desc';
  
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Load saved data from storage
    _loadData();
  }

  /// Load all data from storage
  Future<void> _loadData() async {
    print('🔄 Starting to load all data...');
    final expenses = await StorageService.loadExpenses();
    final recurring = await StorageService.loadRecurringExpenses();
    final users = await StorageService.loadUsers();
    final sharedExpenses = await StorageService.loadSharedExpenses();
    
    print('🔄 Setting state with loaded data: ${expenses.length} expenses');
    setState(() {
      _expenses = expenses;
      _recurringExpenses = recurring;
      _users = users;
      _sharedExpenses = sharedExpenses;
    });
    print('✅ Data loaded and state updated');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Add expense
  Future<void> _addExpense(Expense expense) async {
    print('➕ Adding expense: ${expense.title} - \$${expense.amount}');
    setState(() {
      _expenses.insert(0, expense);
    });
    _animationController.forward(from: 0.0);
    print('➕ Total expenses in list: ${_expenses.length}');
    await StorageService.saveExpenses(_expenses);
    print('✅ Expense saved');
  }

  /// Update expense
  Future<void> _updateExpense(Expense oldExpense, Expense newExpense) async {
    setState(() {
      final index = _expenses.indexWhere((e) => e.id == oldExpense.id);
      if (index != -1) {
        _expenses[index] = newExpense;
      }
    });
    await StorageService.saveExpenses(_expenses);
  }

  /// Delete expense
  Future<void> _deleteExpense(Expense expense) async {
    setState(() {
      _expenses.removeWhere((e) => e.id == expense.id);
    });
    await StorageService.saveExpenses(_expenses);
  }

  /// Add recurring expense
  Future<void> _addRecurring(RecurringExpense recurring) async {
    setState(() {
      _recurringExpenses.add(recurring);
    });
    await StorageService.saveRecurringExpenses(_recurringExpenses);
  }

  /// Update recurring expense
  Future<void> _updateRecurring(RecurringExpense recurring) async {
    setState(() {
      final index = _recurringExpenses.indexWhere((r) => r.id == recurring.id);
      if (index != -1) {
        _recurringExpenses[index] = recurring;
      }
    });
    await StorageService.saveRecurringExpenses(_recurringExpenses);
  }

  /// Delete recurring expense
  Future<void> _deleteRecurring(String id) async {
    setState(() {
      _recurringExpenses.removeWhere((r) => r.id == id);
    });
    await StorageService.saveRecurringExpenses(_recurringExpenses);
  }

  /// Add user
  Future<void> _addUser(User user) async {
    setState(() {
      _users.add(user);
    });
    await StorageService.saveUsers(_users);
  }

  /// Update user
  Future<void> _updateUser(User user) async {
    setState(() {
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
      }
    });
    await StorageService.saveUsers(_users);
  }

  /// Delete user
  Future<void> _deleteUser(String id) async {
    setState(() {
      _users.removeWhere((u) => u.id == id);
    });
    await StorageService.saveUsers(_users);
  }

  /// Add shared expense
  Future<void> _addSharedExpense(SharedExpense expense) async {
    setState(() {
      _sharedExpenses.insert(0, expense);
    });
    await StorageService.saveSharedExpenses(_sharedExpenses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Screen - pass all state and callbacks
          HomeScreenContent(
            expenses: _expenses,
            onAddExpense: _addExpense,
            onUpdateExpense: _updateExpense,
            onDeleteExpense: _deleteExpense,
            animationController: _animationController,
            isBulkDeleteMode: _isBulkDeleteMode,
            selectedExpenseIds: _selectedExpenseIds,
            searchQuery: _searchQuery,
            selectedCategories: _selectedCategories,
            sortBy: _sortBy,
            searchController: _searchController,
            onBulkDeleteModeChanged: (value) => setState(() => _isBulkDeleteMode = value),
            onSelectedIdsChanged: (ids) => setState(() => _selectedExpenseIds = ids),
            onSearchQueryChanged: (query) => setState(() => _searchQuery = query),
            onCategoriesChanged: (cats) => setState(() => _selectedCategories = cats),
            onSortByChanged: (sort) => setState(() => _sortBy = sort),
          ),
          // Analytics Screen
          AnalyticsScreen(expenses: _expenses),
          // Calendar Screen
          CalendarScreen(
            expenses: _expenses,
            onUpdateExpense: _updateExpense,
            onDeleteExpense: _deleteExpense,
          ),
          // Budget Screen
          BudgetScreen(expenses: _expenses),
          // Recurring Screen
          RecurringScreen(
            recurringExpenses: _recurringExpenses,
            onAddRecurring: _addRecurring,
            onUpdateRecurring: _updateRecurring,
            onDeleteRecurring: _deleteRecurring,
            onGenerateExpense: _addExpense,
          ),
          // Splitwise Screen
          SplitwiseScreen(
            users: _users,
            sharedExpenses: _sharedExpenses,
            onAddUser: _addUser,
            onUpdateUser: _updateUser,
            onDeleteUser: _deleteUser,
            onSplitExpense: _addSharedExpense,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Recurring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Splitwise',
          ),
        ],
      ),
    );
  }
}

/// Home screen content widget
class HomeScreenContent extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense) onAddExpense;
  final Function(Expense, Expense) onUpdateExpense;
  final Function(Expense) onDeleteExpense;
  final AnimationController animationController;
  final bool isBulkDeleteMode;
  final Set<String> selectedExpenseIds;
  final String searchQuery;
  final Set<String> selectedCategories;
  final String sortBy;
  final TextEditingController searchController;
  final Function(bool) onBulkDeleteModeChanged;
  final Function(Set<String>) onSelectedIdsChanged;
  final Function(String) onSearchQueryChanged;
  final Function(Set<String>) onCategoriesChanged;
  final Function(String) onSortByChanged;

  const HomeScreenContent({
    Key? key,
    required this.expenses,
    required this.onAddExpense,
    required this.onUpdateExpense,
    required this.onDeleteExpense,
    required this.animationController,
    required this.isBulkDeleteMode,
    required this.selectedExpenseIds,
    required this.searchQuery,
    required this.selectedCategories,
    required this.sortBy,
    required this.searchController,
    required this.onBulkDeleteModeChanged,
    required this.onSelectedIdsChanged,
    required this.onSearchQueryChanged,
    required this.onCategoriesChanged,
    required this.onSortByChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the original HomeScreen but we need to refactor it
    // For now, import and wrap the existing functionality
    return _HomeScreenStateful(
      expenses: expenses,
      onAddExpense: onAddExpense,
      onUpdateExpense: onUpdateExpense,
      onDeleteExpense: onDeleteExpense,
      animationController: animationController,
      isBulkDeleteMode: isBulkDeleteMode,
      selectedExpenseIds: selectedExpenseIds,
      searchQuery: searchQuery,
      selectedCategories: selectedCategories,
      sortBy: sortBy,
      searchController: searchController,
      onBulkDeleteModeChanged: onBulkDeleteModeChanged,
      onSelectedIdsChanged: onSelectedIdsChanged,
      onSearchQueryChanged: onSearchQueryChanged,
      onCategoriesChanged: onCategoriesChanged,
      onSortByChanged: onSortByChanged,
    );
  }
}

// Import the home screen implementation
class _HomeScreenStateful extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense) onAddExpense;
  final Function(Expense, Expense) onUpdateExpense;
  final Function(Expense) onDeleteExpense;
  final AnimationController animationController;
  final bool isBulkDeleteMode;
  final Set<String> selectedExpenseIds;
  final String searchQuery;
  final Set<String> selectedCategories;
  final String sortBy;
  final TextEditingController searchController;
  final Function(bool) onBulkDeleteModeChanged;
  final Function(Set<String>) onSelectedIdsChanged;
  final Function(String) onSearchQueryChanged;
  final Function(Set<String>) onCategoriesChanged;
  final Function(String) onSortByChanged;

  const _HomeScreenStateful({
    required this.expenses,
    required this.onAddExpense,
    required this.onUpdateExpense,
    required this.onDeleteExpense,
    required this.animationController,
    required this.isBulkDeleteMode,
    required this.selectedExpenseIds,
    required this.searchQuery,
    required this.selectedCategories,
    required this.sortBy,
    required this.searchController,
    required this.onBulkDeleteModeChanged,
    required this.onSelectedIdsChanged,
    required this.onSearchQueryChanged,
    required this.onCategoriesChanged,
    required this.onSortByChanged,
  });

  @override
  State<_HomeScreenStateful> createState() => _HomeScreenStatefulState();
}

// Import the implementation from home_screen_impl.dart
class _HomeScreenStatefulState extends State<_HomeScreenStateful> {
  @override
  Widget build(BuildContext context) {
    return _buildHomeScreen();
  }

  Widget _buildHomeScreen() {
    final filteredExpenses = _filteredExpenses;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (widget.selectedCategories.isNotEmpty) _buildFilterChips(),
          _buildTotalSummary(),
          Expanded(child: _buildExpenseList(filteredExpenses)),
        ],
      ),
      floatingActionButton: widget.isBulkDeleteMode ? null : _buildFAB(),
    );
  }

  // Methods moved from home_screen_impl.dart
  List<Expense> get _filteredExpenses {
    var filtered = widget.expenses.where((expense) {
      final matchesSearch = expense.title.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          expense.notes.toLowerCase().contains(widget.searchQuery.toLowerCase());
      final matchesCategory = widget.selectedCategories.isEmpty || widget.selectedCategories.contains(expense.category);
      return matchesSearch && matchesCategory;
    }).toList();
    
    switch (widget.sortBy) {
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

  double get _totalExpenses {
    return widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('TrackWise', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6C63FF),
      actions: [
        if (widget.isBulkDeleteMode)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _deleteSelectedExpenses,
            tooltip: 'Delete Selected',
          ),
        IconButton(
          icon: Icon(widget.isBulkDeleteMode ? Icons.close : Icons.checklist, color: Colors.white),
          onPressed: () => widget.onBulkDeleteModeChanged(!widget.isBulkDeleteMode),
          tooltip: widget.isBulkDeleteMode ? 'Cancel' : 'Bulk Delete',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterDialog,
          tooltip: 'Filter & Sort',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF6C63FF),
      child: TextField(
        controller: widget.searchController,
        onChanged: (value) => widget.onSearchQueryChanged(value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.9)),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    widget.searchController.clear();
                    widget.onSearchQueryChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: widget.selectedCategories.map((category) {
          return Chip(
            label: Text(category),
            onDeleted: () {
              final newSet = Set<String>.from(widget.selectedCategories);
              newSet.remove(category);
              widget.onCategoriesChanged(newSet);
            },
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalSummary() {
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
              Text('Total Expenses', style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
            ],
          ),
          Text(
            '\$${_totalExpenses.toStringAsFixed(2)}',
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

  Widget _buildExpenseList(List<Expense> filteredExpenses) {
    if (filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              widget.searchQuery.isNotEmpty || widget.selectedCategories.isNotEmpty
                  ? 'No matching expenses found'
                  : 'No expenses yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) => _buildExpenseItem(filteredExpenses[index]),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    final isSelected = widget.selectedExpenseIds.contains(expense.id);
    
    return Dismissible(
      key: Key(expense.id),
      direction: widget.isBulkDeleteMode ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
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
      },
      onDismissed: (direction) {
        widget.onDeleteExpense(expense);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${expense.title} deleted'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: widget.isBulkDeleteMode
          ? CheckboxListTile(
              value: isSelected,
              onChanged: (value) => _toggleExpenseSelection(expense.id),
              title: ExpenseCard(
                expense: expense,
                onTap: () => _toggleExpenseSelection(expense.id),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF6C63FF),
            )
          : ExpenseCard(
              expense: expense,
              onTap: () => _showExpenseDetails(expense),
              onEdit: () => _navigateToEditExpense(expense),
              onDelete: () => _deleteExpenseWithConfirmation(expense),
            ),
    );
  }

  /// Show expense details dialog
  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                expense.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getCategoryColor(expense.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    Text(
                      expense.formattedAmount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(expense.category),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Details
              _buildDetailRow(Icons.category, 'Category', expense.category),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.calendar_today, 'Date', expense.formattedDate),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.access_time, 'Created', '${expense.date.hour}:${expense.date.minute.toString().padLeft(2, '0')}'),
              
              if (expense.wasEdited) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.edit, 'Last Edited', expense.lastEdited != null 
                    ? '${expense.lastEdited!.day}/${expense.lastEdited!.month}/${expense.lastEdited!.year}'
                    : 'N/A'),
              ],
              
              if (expense.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    expense.notes,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
              
              if (expense.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Tags', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: expense.tags.map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                    padding: EdgeInsets.zero,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _navigateToEditExpense(expense);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text('$label:', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${expense.title} deleted'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddExpense,
      backgroundColor: const Color(0xFF6C63FF),
      icon: const Icon(Icons.add),
      label: const Text('Add Expense'),
    );
  }

  void _navigateToAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
    
    if (result != null && result is Expense) {
      widget.onAddExpense(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Expense added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToEditExpense(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditExpenseScreen(expense: expense)),
    );
    
    if (result != null && result is Expense) {
      widget.onUpdateExpense(expense, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Expense updated successfully!'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _toggleExpenseSelection(String expenseId) {
    final newSet = Set<String>.from(widget.selectedExpenseIds);
    if (newSet.contains(expenseId)) {
      newSet.remove(expenseId);
    } else {
      newSet.add(expenseId);
    }
    widget.onSelectedIdsChanged(newSet);
  }

  void _deleteSelectedExpenses() async {
    if (widget.selectedExpenseIds.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Expenses'),
        content: Text('Are you sure you want to delete ${widget.selectedExpenseIds.length} expense(s)?'),
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
      for (final id in widget.selectedExpenseIds) {
        final expense = widget.expenses.firstWhere((e) => e.id == id);
        widget.onDeleteExpense(expense);
      }
      widget.onSelectedIdsChanged({});
      widget.onBulkDeleteModeChanged(false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Selected expenses deleted'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Filter & Sort'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Food', 'Travel', 'Bills', 'Shopping', 'Other'].map((category) {
                      final isSelected = widget.selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            final newSet = Set<String>.from(widget.selectedCategories);
                            if (selected) {
                              newSet.add(category);
                            } else {
                              newSet.remove(category);
                            }
                            widget.onCategoriesChanged(newSet);
                          });
                        },
                        selectedColor: const Color(0xFF6C63FF).withOpacity(0.3),
                        checkmarkColor: const Color(0xFF6C63FF),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...{
                    'date_desc': 'Date (Newest First)',
                    'date_asc': 'Date (Oldest First)',
                    'amount_desc': 'Amount (Highest First)',
                    'amount_asc': 'Amount (Lowest First)',
                  }.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: widget.sortBy,
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => widget.onSortByChanged(value));
                        }
                      },
                      activeColor: const Color(0xFF6C63FF),
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  widget.onCategoriesChanged({});
                  widget.onSortByChanged('date_desc');
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Travel':
        return Colors.blue;
      case 'Bills':
        return Colors.red;
      case 'Shopping':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

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

