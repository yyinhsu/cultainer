import 'dart:convert';

import 'package:cultainer/services/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
  });

  group('GeminiService', () {
    group('isConfigured', () {
      test('returns false when no API key', () {
        final service = GeminiService(client: mockClient);
        expect(service.isConfigured, isFalse);
      });

      test('returns false when API key is empty string', () {
        final service = GeminiService(apiKey: '', client: mockClient);
        expect(service.isConfigured, isFalse);
      });

      test('returns true when API key is set', () {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);
        expect(service.isConfigured, isTrue);
      });
    });

    group('validateApiKey', () {
      test('returns false when not configured', () async {
        final service = GeminiService(client: mockClient);
        final result = await service.validateApiKey();
        expect(result, isFalse);
      });

      test('returns true when API call succeeds', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            _validGeminiResponse('Hello!'),
            200,
          ),
        );

        final result = await service.validateApiKey();
        expect(result, isTrue);
      });

      test('returns false when API returns 401', () async {
        final service = GeminiService(apiKey: 'bad-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        final result = await service.validateApiKey();
        expect(result, isFalse);
      });
    });

    group('_generateContent (via analyzeExcerpt)', () {
      test('throws GeminiException when not configured', () async {
        final service = GeminiService(client: mockClient);

        expect(
          () => service.analyzeExcerpt('some text'),
          throwsA(
            isA<GeminiException>().having(
              (e) => e.message,
              'message',
              'API key not configured',
            ),
          ),
        );
      });
    });

    group('analyzeExcerpt', () {
      test('returns response text on success', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);
        const analysisResult = '1. 重點概念\n2. 背景知識';

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response.bytes(
            utf8.encode(_validGeminiResponse(analysisResult)),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        );

        final result = await service.analyzeExcerpt('test excerpt');
        expect(result, equals(analysisResult));
      });

      test('sends correct prompt containing the excerpt text', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            _validGeminiResponse('analysis'),
            200,
          ),
        );

        await service.analyzeExcerpt('my excerpt text');

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body =
            json.decode(captured.last as String) as Map<String, dynamic>;
        final contents = body['contents'] as List<dynamic>;
        final parts =
            (contents.first as Map<String, dynamic>)['parts'] as List<dynamic>;
        final text = (parts.first as Map<String, dynamic>)['text'] as String;

        expect(text, contains('my excerpt text'));
      });

      test('throws GeminiException on HTTP 401', () async {
        final service = GeminiService(apiKey: 'bad-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        expect(
          () => service.analyzeExcerpt('text'),
          throwsA(
            isA<GeminiException>().having(
              (e) => e.message,
              'message',
              'Invalid API key',
            ),
          ),
        );
      });

      test('throws GeminiException on HTTP 403', () async {
        final service = GeminiService(apiKey: 'bad-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Forbidden', 403),
        );

        expect(
          () => service.analyzeExcerpt('text'),
          throwsA(
            isA<GeminiException>().having(
              (e) => e.message,
              'message',
              'Invalid API key',
            ),
          ),
        );
      });

      test('throws GeminiException on HTTP 429 (rate limit)', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Too Many Requests', 429),
        );

        expect(
          () => service.analyzeExcerpt('text'),
          throwsA(
            isA<GeminiException>().having(
              (e) => e.message,
              'message',
              'Rate limit exceeded. Please try later.',
            ),
          ),
        );
      });

      test('throws GeminiException on HTTP 400', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Bad Request', 400),
        );

        expect(
          () => service.analyzeExcerpt('text'),
          throwsA(
            isA<GeminiException>().having(
              (e) => e.message,
              'message',
              'Invalid request',
            ),
          ),
        );
      });

      test('throws GeminiException on unexpected status code', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('Server Error', 500),
        );

        expect(
          () => service.analyzeExcerpt('text'),
          throwsA(
            isA<GeminiException>().having(
              (e) => e.message,
              'message',
              'API error: 500',
            ),
          ),
        );
      });

      test('returns null when candidates list is empty', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            json.encode({'candidates': <dynamic>[]}),
            200,
          ),
        );

        final result = await service.analyzeExcerpt('text');
        expect(result, isNull);
      });

      test('returns null when candidates is null', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            json.encode(<String, dynamic>{}),
            200,
          ),
        );

        final result = await service.analyzeExcerpt('text');
        expect(result, isNull);
      });
    });

    group('summarizeExcerpts', () {
      test('calls API with combined texts in prompt', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            _validGeminiResponse('summary'),
            200,
          ),
        );

        final result =
            await service.summarizeExcerpts(['excerpt one', 'excerpt two']);
        expect(result, equals('summary'));

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body =
            json.decode(captured.last as String) as Map<String, dynamic>;
        final contents = body['contents'] as List<dynamic>;
        final parts =
            (contents.first as Map<String, dynamic>)['parts'] as List<dynamic>;
        final text = (parts.first as Map<String, dynamic>)['text'] as String;

        expect(text, contains('excerpt one'));
        expect(text, contains('excerpt two'));
        expect(text, contains('段落 1'));
        expect(text, contains('段落 2'));
      });

      test('throws GeminiException when not configured', () async {
        final service = GeminiService(client: mockClient);

        expect(
          () => service.summarizeExcerpts(['text']),
          throwsA(isA<GeminiException>()),
        );
      });
    });

    group('enhanceReview', () {
      test('calls API with review and title in prompt', () async {
        final service = GeminiService(apiKey: 'test-key', client: mockClient);

        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            _validGeminiResponse('enhanced review'),
            200,
          ),
        );

        final result = await service.enhanceReview('my review', 'Book Title');
        expect(result, equals('enhanced review'));

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body =
            json.decode(captured.last as String) as Map<String, dynamic>;
        final contents = body['contents'] as List<dynamic>;
        final parts =
            (contents.first as Map<String, dynamic>)['parts'] as List<dynamic>;
        final text = (parts.first as Map<String, dynamic>)['text'] as String;

        expect(text, contains('my review'));
        expect(text, contains('Book Title'));
      });

      test('throws GeminiException when not configured', () async {
        final service = GeminiService(client: mockClient);

        expect(
          () => service.enhanceReview('review', 'title'),
          throwsA(isA<GeminiException>()),
        );
      });
    });

    group('GeminiException', () {
      test('toString returns formatted message', () {
        const exception = GeminiException('test error');
        expect(exception.toString(), equals('GeminiException: test error'));
      });

      test('message property returns the message', () {
        const exception = GeminiException('some message');
        expect(exception.message, equals('some message'));
      });
    });
  });
}

/// Helper to build a valid Gemini API response JSON string.
String _validGeminiResponse(String text) {
  return json.encode({
    'candidates': [
      {
        'content': {
          'parts': [
            {'text': text},
          ],
        },
      },
    ],
  });
}
