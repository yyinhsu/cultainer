import 'package:cultainer/services/ocr_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OcrService', () {
    test('can be instantiated', () {
      final service = OcrService();
      expect(service, isNotNull);
      expect(service, isA<OcrService>());
    });
  });
}
