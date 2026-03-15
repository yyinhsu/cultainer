import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:cultainer/features/profile/profile_page.dart';

/// Provider for the [GeminiService].
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);
  return GeminiService(apiKey: apiKey);
});

/// Service for interacting with Google's Gemini API.
class GeminiService {
  GeminiService({
    this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String? apiKey;
  final http.Client _client;

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const _model = 'gemini-2.0-flash';

  /// Whether the service has a valid API key configured.
  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  /// Validates the API key by making a test request.
  Future<bool> validateApiKey() async {
    if (!isConfigured) return false;

    try {
      final response = await _generateContent('Hello');
      return response != null;
    } on GeminiException {
      return false;
    }
  }

  /// Analyzes an excerpt text and returns key insights.
  Future<String?> analyzeExcerpt(String text) async {
    return _generateContent(
      '你是一位知識擷取助手。請分析以下段落，提供：\n'
      '1. 重點概念\n'
      '2. 背景知識\n'
      '3. 延伸思考\n\n'
      '請以繁體中文回覆，使用簡潔的條列格式。\n\n'
      '段落：\n$text',
    );
  }

  /// Generates a summary from multiple excerpts.
  Future<String?> summarizeExcerpts(List<String> texts) async {
    final combined = texts.asMap().entries.map((e) {
      return '段落 ${e.key + 1}：\n${e.value}';
    }).join('\n\n');

    return _generateContent(
      '你是一位知識整理助手。請將以下多個段落整合成一篇簡潔的摘要，'
      '保留核心觀點和重要細節。\n'
      '請以繁體中文回覆。\n\n$combined',
    );
  }

  /// Enhances a user's review text.
  Future<String?> enhanceReview(String review, String entryTitle) async {
    return _generateContent(
      '你是一位寫作助手。請潤飾以下關於「$entryTitle」的心得，'
      '保持原意但讓文字更流暢、更有深度。\n'
      '請以繁體中文回覆，不要加入原文沒有的觀點。\n\n'
      '原文心得：\n$review',
    );
  }

  /// Sends a prompt to the Gemini API and returns the response text.
  Future<String?> _generateContent(String prompt) async {
    if (!isConfigured) {
      throw const GeminiException('API key not configured');
    }

    final uri = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    final body = json.encode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
      },
    });

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 400) {
        throw const GeminiException('Invalid request');
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const GeminiException('Invalid API key');
      }
      if (response.statusCode == 429) {
        throw const GeminiException('Rate limit exceeded. Please try later.');
      }
      if (response.statusCode != 200) {
        throw GeminiException(
          'API error: ${response.statusCode}',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;

      final content = (candidates.first as Map<String, dynamic>)['content']
          as Map<String, dynamic>?;
      if (content == null) return null;

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;

      return (parts.first as Map<String, dynamic>)['text'] as String?;
    } on GeminiException {
      rethrow;
    } on Exception catch (e) {
      throw GeminiException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Exception thrown by [GeminiService].
class GeminiException implements Exception {
  const GeminiException(this.message);

  final String message;

  @override
  String toString() => 'GeminiException: $message';
}
