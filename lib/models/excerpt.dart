import 'package:equatable/equatable.dart';

/// Represents an excerpt (highlight/quote) from a media entry.
class Excerpt extends Equatable {
  const Excerpt({
    required this.id,
    required this.entryId,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    this.pageNumber,
    this.imageUrl,
    this.aiAnalysis,
  });

  /// Unique identifier.
  final String id;

  /// Parent entry ID.
  final String entryId;

  /// OCR extracted text.
  final String text;

  /// Page number (for books).
  final int? pageNumber;

  /// Original image URL (optional).
  final String? imageUrl;

  /// AI analysis result.
  final String? aiAnalysis;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Creates a copy with updated fields.
  Excerpt copyWith({
    String? id,
    String? entryId,
    String? text,
    int? pageNumber,
    String? imageUrl,
    String? aiAnalysis,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Excerpt(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      text: text ?? this.text,
      pageNumber: pageNumber ?? this.pageNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts to Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'pageNumber': pageNumber,
      'imageUrl': imageUrl,
      'aiAnalysis': aiAnalysis,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates from Firestore document.
  factory Excerpt.fromFirestore(
    String id,
    String entryId,
    Map<String, dynamic> data,
  ) {
    return Excerpt(
      id: id,
      entryId: entryId,
      text: data['text'] as String? ?? '',
      pageNumber: data['pageNumber'] as int?,
      imageUrl: data['imageUrl'] as String?,
      aiAnalysis: data['aiAnalysis'] as String?,
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
        entryId,
        text,
        pageNumber,
        imageUrl,
        aiAnalysis,
        createdAt,
        updatedAt,
      ];
}
