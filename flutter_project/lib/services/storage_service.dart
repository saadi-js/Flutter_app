import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/recurring_expense.dart';
import '../models/budget.dart';
import '../models/user.dart';
import '../models/shared_expense.dart';

/// Service for persisting data locally using Hive
class StorageService {
  static const String _expensesBox = 'expenses';
  static const String _recurringExpensesBox = 'recurring_expenses';
  static const String _budgetsBox = 'budgets';
  static const String _usersBox = 'users';
  static const String _sharedExpensesBox = 'shared_expenses';

  /// Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter('trackwise_db');
    
    // Open boxes
    await Hive.openBox<Map>(_expensesBox);
    await Hive.openBox<Map>(_recurringExpensesBox);
    await Hive.openBox<Map>(_budgetsBox);
    await Hive.openBox<Map>(_usersBox);
    await Hive.openBox<Map>(_sharedExpensesBox);
    
    print('✅ Hive initialized successfully');
  }

  // EXPENSES
  static Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final box = Hive.box<Map>(_expensesBox);
      await box.clear();
      
      for (var i = 0; i < expenses.length; i++) {
        await box.put(i, expenses[i].toJson());
      }
      
      print('💾 SAVED ${expenses.length} expenses to Hive');
    } catch (e) {
      print('❌ ERROR saving expenses: $e');
    }
  }

  static Future<List<Expense>> loadExpenses() async {
    try {
      print('📂 LOADING expenses from Hive');
      final box = Hive.box<Map>(_expensesBox);
      
      final expenses = <Expense>[];
      for (var i = 0; i < box.length; i++) {
        final data = box.get(i);
        if (data != null) {
          expenses.add(Expense.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      
      print('✅ Loaded ${expenses.length} expenses from Hive');
      return expenses;
    } catch (e) {
      print('❌ ERROR loading expenses: $e');
      return [];
    }
  }

  // RECURRING EXPENSES
  static Future<void> saveRecurringExpenses(List<RecurringExpense> expenses) async {
    try {
      final box = Hive.box<Map>(_recurringExpensesBox);
      await box.clear();
      
      for (var i = 0; i < expenses.length; i++) {
        await box.put(i, expenses[i].toJson());
      }
      
      print('💾 Saved ${expenses.length} recurring expenses to Hive');
    } catch (e) {
      print('❌ ERROR saving recurring expenses: $e');
    }
  }

  static Future<List<RecurringExpense>> loadRecurringExpenses() async {
    try {
      final box = Hive.box<Map>(_recurringExpensesBox);
      
      final expenses = <RecurringExpense>[];
      for (var i = 0; i < box.length; i++) {
        final data = box.get(i);
        if (data != null) {
          expenses.add(RecurringExpense.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      
      print('✅ Loaded ${expenses.length} recurring expenses from Hive');
      return expenses;
    } catch (e) {
      print('❌ ERROR loading recurring expenses: $e');
      return [];
    }
  }

  // BUDGETS
  static Future<void> saveBudgets(List<Budget> budgets) async {
    try {
      final box = Hive.box<Map>(_budgetsBox);
      await box.clear();
      
      for (var i = 0; i < budgets.length; i++) {
        await box.put(i, {
          'category': budgets[i].category,
          'amount': budgets[i].amount,
          'period': budgets[i].period,
        });
      }
      
      print('💾 Saved ${budgets.length} budgets to Hive');
    } catch (e) {
      print('❌ ERROR saving budgets: $e');
    }
  }

  static Future<List<Budget>> loadBudgets() async {
    try {
      final box = Hive.box<Map>(_budgetsBox);
      
      final budgets = <Budget>[];
      for (var i = 0; i < box.length; i++) {
        final data = box.get(i);
        if (data != null) {
          budgets.add(Budget(
            category: data['category'] as String,
            amount: (data['amount'] as num).toDouble(),
            period: data['period'] as String,
          ));
        }
      }
      
      print('✅ Loaded ${budgets.length} budgets from Hive');
      return budgets;
    } catch (e) {
      print('❌ ERROR loading budgets: $e');
      return [];
    }
  }

  // USERS
  static Future<void> saveUsers(List<User> users) async {
    try {
      final box = Hive.box<Map>(_usersBox);
      await box.clear();
      
      for (var i = 0; i < users.length; i++) {
        await box.put(i, users[i].toJson());
      }
      
      print('💾 Saved ${users.length} users to Hive');
    } catch (e) {
      print('❌ ERROR saving users: $e');
    }
  }

  static Future<List<User>> loadUsers() async {
    try {
      final box = Hive.box<Map>(_usersBox);
      
      final users = <User>[];
      for (var i = 0; i < box.length; i++) {
        final data = box.get(i);
        if (data != null) {
          users.add(User.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      
      print('✅ Loaded ${users.length} users from Hive');
      return users;
    } catch (e) {
      print('❌ ERROR loading users: $e');
      return [];
    }
  }

  // SHARED EXPENSES
  static Future<void> saveSharedExpenses(List<SharedExpense> expenses) async {
    try {
      final box = Hive.box<Map>(_sharedExpensesBox);
      await box.clear();
      
      for (var i = 0; i < expenses.length; i++) {
        await box.put(i, expenses[i].toJson());
      }
      
      print('💾 Saved ${expenses.length} shared expenses to Hive');
    } catch (e) {
      print('❌ ERROR saving shared expenses: $e');
    }
  }

  static Future<List<SharedExpense>> loadSharedExpenses() async {
    try {
      final box = Hive.box<Map>(_sharedExpensesBox);
      
      final expenses = <SharedExpense>[];
      for (var i = 0; i < box.length; i++) {
        final data = box.get(i);
        if (data != null) {
          expenses.add(SharedExpense.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      
      print('✅ Loaded ${expenses.length} shared expenses from Hive');
      return expenses;
    } catch (e) {
      print('❌ ERROR loading shared expenses: $e');
      return [];
    }
  }

  // Clear all data
  static Future<void> clearAll() async {
    await Hive.box<Map>(_expensesBox).clear();
    await Hive.box<Map>(_recurringExpensesBox).clear();
    await Hive.box<Map>(_budgetsBox).clear();
    await Hive.box<Map>(_usersBox).clear();
    await Hive.box<Map>(_sharedExpensesBox).clear();
    print('🗑️ All Hive storage cleared');
  }
}
