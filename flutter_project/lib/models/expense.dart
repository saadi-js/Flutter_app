/// Data model representing a single expense entry
/// Used throughout the app for expense management
class Expense {
  final String id; // Unique identifier
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final DateTime? lastEdited; // Track when expense was last edited
  final List<String> tags; // Optional tags
  final String notes; // Optional notes

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.lastEdited,
    this.tags = const [],
    this.notes = '',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Get formatted date string for display
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get formatted amount with currency symbol
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Check if expense was edited
  bool get wasEdited => lastEdited != null;

  /// Create a copy of expense with updated fields
  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    DateTime? lastEdited,
    List<String>? tags,
    String? notes,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      lastEdited: lastEdited ?? this.lastEdited,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'lastEdited': lastEdited?.toIso8601String(),
      'tags': tags,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      lastEdited: json['lastEdited'] != null ? DateTime.parse(json['lastEdited']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'] ?? '',
    );
  }
}
