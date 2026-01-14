import 'package:flutter/material.dart';

/// Budget model to track category-wise budgets
class Budget {
  final String category;
  final double amount;
  final String period; // 'daily', 'weekly', 'monthly'

  Budget({
    required this.category,
    required this.amount,
    required this.period,
  });

  Budget copyWith({
    String? category,
    double? amount,
    String? period,
  }) {
    return Budget(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
    );
  }
}
