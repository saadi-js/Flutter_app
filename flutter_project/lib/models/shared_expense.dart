import '../models/expense.dart';

enum SplitType {
  equal,
  percentage,
  exact,
  shares,
}

class SharedExpense extends Expense {
  final List<String> participantIds;
  final SplitType splitType;
  final Map<String, double> amountPerPerson;

  SharedExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String notes = '',
    List<String> tags = const [],
    required this.participantIds,
    required this.splitType,
    required this.amountPerPerson,
  }) : super(
          id: id,
          title: title,
          amount: amount,
          category: category,
          date: date,
          notes: notes,
          tags: tags,
        );

  @override
  SharedExpense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    List<String>? tags,
    DateTime? lastEdited,
    List<String>? participantIds,
    SplitType? splitType,
    Map<String, double>? amountPerPerson,
  }) {
    return SharedExpense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      participantIds: participantIds ?? this.participantIds,
      splitType: splitType ?? this.splitType,
      amountPerPerson: amountPerPerson ?? this.amountPerPerson,
    );
  }

  String getSplitTypeString() {
    switch (splitType) {
      case SplitType.equal:
        return 'Split Equally';
      case SplitType.percentage:
        return 'Split by Percentage';
      case SplitType.exact:
        return 'Split by Exact Amount';
      case SplitType.shares:
        return 'Split by Shares';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
      'tags': tags,
      'participantIds': participantIds,
      'splitType': splitType.index,
      'amountPerPerson': amountPerPerson,
    };
  }

  /// Create from JSON
  factory SharedExpense.fromJson(Map<String, dynamic> json) {
    return SharedExpense(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      notes: json['notes'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      participantIds: List<String>.from(json['participantIds']),
      splitType: SplitType.values[json['splitType']],
      amountPerPerson: Map<String, double>.from(json['amountPerPerson']),
    );
  }
}
