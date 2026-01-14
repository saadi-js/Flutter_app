enum RecurrencePattern {
  daily,
  weekly,
  monthly,
  yearly,
}

class RecurringExpense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final RecurrencePattern pattern;
  final DateTime lastGenerated;
  final DateTime nextDue;
  final bool isActive;
  final String notes;

  RecurringExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.pattern,
    required this.lastGenerated,
    required this.nextDue,
    this.isActive = true,
    this.notes = '',
  });

  RecurringExpense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    RecurrencePattern? pattern,
    DateTime? lastGenerated,
    DateTime? nextDue,
    bool? isActive,
    String? notes,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      pattern: pattern ?? this.pattern,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      nextDue: nextDue ?? this.nextDue,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  DateTime calculateNextDue() {
    DateTime next = nextDue;
    switch (pattern) {
      case RecurrencePattern.daily:
        next = nextDue.add(const Duration(days: 1));
        break;
      case RecurrencePattern.weekly:
        next = nextDue.add(const Duration(days: 7));
        break;
      case RecurrencePattern.monthly:
        next = DateTime(nextDue.year, nextDue.month + 1, nextDue.day);
        break;
      case RecurrencePattern.yearly:
        next = DateTime(nextDue.year + 1, nextDue.month, nextDue.day);
        break;
    }
    return next;
  }

  String getPatternString() {
    switch (pattern) {
      case RecurrencePattern.daily:
        return 'Daily';
      case RecurrencePattern.weekly:
        return 'Weekly';
      case RecurrencePattern.monthly:
        return 'Monthly';
      case RecurrencePattern.yearly:
        return 'Yearly';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'pattern': pattern.index,
      'lastGenerated': lastGenerated.toIso8601String(),
      'nextDue': nextDue.toIso8601String(),
      'isActive': isActive,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    return RecurringExpense(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      pattern: RecurrencePattern.values[json['pattern']],
      lastGenerated: DateTime.parse(json['lastGenerated']),
      nextDue: DateTime.parse(json['nextDue']),
      isActive: json['isActive'] ?? true,
      notes: json['notes'] ?? '',
    );
  }
}
