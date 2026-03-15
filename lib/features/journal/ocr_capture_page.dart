import 'dart:io';

import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_button.dart';
import 'package:cultainer/features/journal/excerpt_providers.dart';
import 'package:cultainer/services/ocr_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Page for capturing text via OCR from camera or gallery images.
class OcrCapturePage extends ConsumerStatefulWidget {
  const OcrCapturePage({
    required this.entryId,
    super.key,
  });

  final String entryId;

  @override
  ConsumerState<OcrCapturePage> createState() => _OcrCapturePageState();
}

class _OcrCapturePageState extends ConsumerState<OcrCapturePage> {
  final _textController = TextEditingController();
  final _pageController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isRecognizing = false;
  bool _isSaving = false;
  String? _imagePath;

  bool get _isSupported => !kIsWeb && Platform.isIOS;

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          'OCR Capture',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_isSupported && _textController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppButton(
                label: _isSaving ? 'Saving...' : 'Save',
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
              ),
            ),
        ],
      ),
      body: _isSupported ? _buildOcrContent() : _buildUnsupportedMessage(),
    );
  }

  Widget _buildUnsupportedMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_photography,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'OCR Not Supported',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Text recognition is only available on iOS. '
              'Please use an iOS device to capture text from images.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOcrContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image source buttons
          if (_imagePath == null && !_isRecognizing) ...[
            _buildImageSourceButtons(),
            const SizedBox(height: 24),
          ],

          // Recognizing indicator
          if (_isRecognizing) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Recognizing text...',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Recognized text editor
          if (_imagePath != null && !_isRecognizing) ...[
            // Retake / re-pick buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Retake'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Re-pick'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Recognized Text',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Edit recognized text here...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Page number (optional)',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.menu_book,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildImageSourceButtons() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.document_scanner,
          size: 64,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 16),
        Text(
          'Capture text from an image',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Camera',
                icon: Icons.camera_alt,
                onPressed: () => _pickImage(ImageSource.camera),
                isExpanded: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Gallery',
                icon: Icons.photo_library,
                variant: AppButtonVariant.secondary,
                onPressed: () => _pickImage(ImageSource.gallery),
                isExpanded: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _isRecognizing = true;
        _imagePath = pickedFile.path;
      });

      final ocrService = ref.read(ocrServiceProvider);
      final text = await ocrService.recognizeText(pickedFile.path);

      if (!mounted) return;

      setState(() {
        _isRecognizing = false;
        if (text != null) {
          _textController.text = text;
        } else {
          _textController.text = '';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No text recognized from image'),
            ),
          );
        }
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isRecognizing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _save() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or enter some text')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(excerptActionProvider.notifier).createExcerpt(
            entryId: widget.entryId,
            text: text,
            pageNumber: int.tryParse(_pageController.text.trim()),
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
