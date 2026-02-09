import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a user-defined tag.
class Tag extends Equatable {
  const Tag({
    required this.id,
    required this.name,
    required this.createdAt,
    this.color,
  });

  /// Unique identifier.
  final String id;

  /// Tag name.
  final String name;

  /// Tag color (hex string).
  final String? color;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Gets the Color object from hex string.
  Color? get colorValue {
    if (color == null) return null;
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Creates a copy with updated fields.
  Tag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Creates from Firestore document.
  factory Tag.fromFirestore(String id, Map<String, dynamic> data) {
    return Tag(
      id: id,
      name: data['name'] as String? ?? '',
      color: data['color'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt];
}
