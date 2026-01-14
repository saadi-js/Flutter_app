import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String? email;
  final Color color;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.color,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    Color? color,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      color: color ?? this.color,
    );
  }

  String getInitials() {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'color': color.value,
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      color: Color(json['color']),
    );
  }
}
