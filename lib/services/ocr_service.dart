import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Provider for the [OcrService].
final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});

/// Service for performing OCR text recognition using Google ML Kit.
class OcrService {
  /// Recognizes text from an image at the given [imagePath].
  ///
  /// Returns the recognized text as a string, or `null` if recognition fails.
  Future<String?> recognizeText(String imagePath) async {
    final textRecognizer = TextRecognizer();

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text.isNotEmpty ? recognizedText.text : null;
    } on Exception catch (_) {
      return null;
    } finally {
      await textRecognizer.close();
    }
  }
}
