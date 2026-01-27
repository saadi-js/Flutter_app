import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/recurring_expense.dart';
import '../models/budget.dart';
import '../models/user.dart';
import '../models/shared_expense.dart';

/// Service for persisting data locally using SharedPreferences
class StorageService {
  static const String _expensesKey = 'trackwise_expenses_v1';
  static const String _recurringExpensesKey = 'trackwise_recurring_v1';
  static const String _budgetsKey = 'trackwise_budgets_v1';
  static const String _usersKey = 'trackwise_users_v1';
  static const String _sharedExpensesKey = 'trackwise_shared_v1';

  static Future<void> init() async {
    print('✅ SharedPreferences initialized');
    await _logStorageStatus();
  }

  static Future<void> _logStorageStatus() async {
    final prefs = await SharedPreferences.getInstance();
    
    print('📊 STORAGE STATUS:');
    print('  🔑 All keys: ${prefs.getKeys()}');
    print('  📦 Expenses: ${prefs.getString(_expensesKey)?.length ?? 0} chars');
    print('  📦 Recurring: ${prefs.getString(_recurringExpensesKey)?.length ?? 0} chars');
    print('  📦 Budgets: ${prefs.getString(_budgetsKey)?.length ?? 0} chars');
    print('  📦 Users: ${prefs.getString(_usersKey)?.length ?? 0} chars');
    print('  📦 Shared: ${prefs.getString(_sharedExpensesKey)?.length ?? 0} chars');
  }

  // EXPENSES
  static Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = expenses.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      print('🔄 Attempting to save ${expenses.length} expenses...');
      print('🔄 JSON length: ${jsonString.length} chars');
      
      final success = await prefs.setString(_expensesKey, jsonString);
      
      print('💾 Save result: $success');
      
      // Verify immediately
      final verify = prefs.getString(_expensesKey);
      print('✅ Verification: ${verify != null ? "SUCCESS - ${verify.length} chars" : "FAILED - null"}');
      
      // Log all keys after save
      print('🔑 All keys after save: ${prefs.getKeys()}');
      
    } catch (e) {
      print('❌ ERROR saving expenses: $e');
    }
  }

  static Future<List<Expense>> loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('🔍 Loading expenses...');
      print('🔑 Available keys: ${prefs.getKeys()}');
      
      final jsonString = prefs.getString(_expensesKey);
      
      print('📥 Raw data: ${jsonString?.substring(0, jsonString.length > 100 ? 100 : jsonString.length) ?? "null"}');
      
      if (jsonString == null || jsonString.isEmpty) {
        print('📂 No expenses found in storage');
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      final expenses = jsonList.map((json) => Expense.fromJson(json)).toList();
      
      print('✅ Loaded ${expenses.length} expenses');
      return expenses;
    } catch (e) {
      print('❌ ERROR loading expenses: $e');
      return [];
    }
  }

  // RECURRING EXPENSES
  static Future<void> saveRecurringExpenses(List<RecurringExpense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = expenses.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await prefs.setString(_recurringExpensesKey, jsonString);
      print('💾 Saved ${expenses.length} recurring expenses');
    } catch (e) {
      print('❌ ERROR saving recurring expenses: $e');
    }
  }

  static Future<List<RecurringExpense>> loadRecurringExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recurringExpensesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        print('📂 No recurring expenses found');
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      final expenses = jsonList.map((json) => RecurringExpense.fromJson(json)).toList();
      
      print('✅ Loaded ${expenses.length} recurring expenses');
      return expenses;
    } catch (e) {
      print('❌ ERROR loading recurring expenses: $e');
      return [];
    }
  }

  // BUDGETS
  static Future<void> saveBudgets(List<Budget> budgets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = budgets.map((b) => {
        'category': b.category,
        'amount': b.amount,
        'period': b.period,
      }).toList();
      final jsonString = jsonEncode(jsonList);
      
      await prefs.setString(_budgetsKey, jsonString);
      print('💾 Saved ${budgets.length} budgets');
    } catch (e) {
      print('❌ ERROR saving budgets: $e');
    }
  }

  static Future<List<Budget>> loadBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_budgetsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        print('📂 No budgets found');
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      final budgets = jsonList.map((json) => Budget(
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
        period: json['period'] as String,
      )).toList();
      
      print('✅ Loaded ${budgets.length} budgets');
      return budgets;
    } catch (e) {
      print('❌ ERROR loading budgets: $e');
      return [];
    }
  }

  // USERS
  static Future<void> saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = users.map((u) => u.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await prefs.setString(_usersKey, jsonString);
      print('💾 Saved ${users.length} users');
    } catch (e) {
      print('❌ ERROR saving users: $e');
    }
  }

  static Future<List<User>> loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_usersKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        print('📂 No users found');
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      final users = jsonList.map((json) => User.fromJson(json)).toList();
      
      print('✅ Loaded ${users.length} users');
      return users;
    } catch (e) {
      print('❌ ERROR loading users: $e');
      return [];
    }
  }

  // SHARED EXPENSES
  static Future<void> saveSharedExpenses(List<SharedExpense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = expenses.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await prefs.setString(_sharedExpensesKey, jsonString);
      print('💾 Saved ${expenses.length} shared expenses');
    } catch (e) {
      print('❌ ERROR saving shared expenses: $e');
    }
  }

  static Future<List<SharedExpense>> loadSharedExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_sharedExpensesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        print('📂 No shared expenses found');
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      final expenses = jsonList.map((json) => SharedExpense.fromJson(json)).toList();
      
      print('✅ Loaded ${expenses.length} shared expenses');
      return expenses;
    } catch (e) {
      print('❌ ERROR loading shared expenses: $e');
      return [];
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expensesKey);
    await prefs.remove(_recurringExpensesKey);
    await prefs.remove(_budgetsKey);
    await prefs.remove(_usersKey);
    await prefs.remove(_sharedExpensesKey);
    print('🗑️ All storage cleared');
  }
}
