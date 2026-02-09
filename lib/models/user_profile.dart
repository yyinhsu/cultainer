import 'package:equatable/equatable.dart';

/// Represents a user profile in Cultainer.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.displayName,
    this.avatarUrl,
    this.geminiApiKey,
  });

  /// Firebase Auth UID.
  final String id;

  /// Display name.
  final String? displayName;

  /// Email address.
  final String email;

  /// Avatar URL.
  final String? avatarUrl;

  /// Encrypted Gemini API key.
  final String? geminiApiKey;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Creates a copy with updated fields.
  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? geminiApiKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'geminiApiKey': geminiApiKey,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates from Firestore document.
  factory UserProfile.fromFirestore(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      displayName: data['displayName'] as String?,
      email: data['email'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      geminiApiKey: data['geminiApiKey'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        data['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        data['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        avatarUrl,
        geminiApiKey,
        createdAt,
        updatedAt,
      ];
}
