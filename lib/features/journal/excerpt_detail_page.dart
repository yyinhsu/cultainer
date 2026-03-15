import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_button.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:cultainer/features/journal/excerpt_providers.dart';
import 'package:cultainer/models/excerpt.dart';
import 'package:cultainer/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Page for viewing and editing an excerpt, with AI analysis features.
class ExcerptDetailPage extends ConsumerStatefulWidget {
  const ExcerptDetailPage({
    required this.excerpt,
    super.key,
  });

  final Excerpt excerpt;

  @override
  ConsumerState<ExcerptDetailPage> createState() => _ExcerptDetailPageState();
}

class _ExcerptDetailPageState extends ConsumerState<ExcerptDetailPage> {
  late TextEditingController _textController;
  late TextEditingController _pageController;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isAnalyzing = false;
  String? _aiResult;
  String? _aiError;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.excerpt.text);
    _pageController = TextEditingController(
      text: widget.excerpt.pageNumber?.toString() ?? '',
    );
    _aiResult = widget.excerpt.aiAnalysis;
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gemini = ref.watch(geminiServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          _isEditing ? 'Edit Excerpt' : 'Excerpt',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: const Text('Save'),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text content
            if (_isEditing) ...[
              TextField(
                controller: _textController,
                maxLines: null,
                minLines: 5,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Excerpt text...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
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
                ),
              ),
            ] else ...[
              if (widget.excerpt.pageNumber != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Page ${widget.excerpt.pageNumber}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SelectableText(
                        widget.excerpt.text,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // AI Features
            if (!_isEditing && gemini.isConfigured) ...[
              Text(
                'AI Assistant',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Analyze',
                      icon: Icons.auto_awesome,
                      onPressed: _isAnalyzing ? null : _analyzeExcerpt,
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isAnalyzing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text(
                          'Analyzing...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_aiError != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _aiError!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_aiResult != null && !_isAnalyzing) ...[
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Analysis',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          if (_aiResult != widget.excerpt.aiAnalysis)
                            TextButton(
                              onPressed: _saveAiAnalysis,
                              child: const Text('Save'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _aiResult!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            if (!_isEditing && !gemini.isConfigured) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Set up your Gemini API key in Profile to '
                        'enable AI analysis.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final pageNum = int.tryParse(_pageController.text.trim());
      final updated = widget.excerpt.copyWith(
        text: text,
        pageNumber: pageNum,
      );
      await ref.read(excerptActionProvider.notifier).updateExcerpt(updated);
      if (mounted) {
        setState(() => _isEditing = false);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _analyzeExcerpt() async {
    setState(() {
      _isAnalyzing = true;
      _aiError = null;
    });

    try {
      final gemini = ref.read(geminiServiceProvider);
      final result = await gemini.analyzeExcerpt(widget.excerpt.text);
      if (mounted) {
        setState(() {
          _aiResult = result;
          _isAnalyzing = false;
        });
      }
    } on GeminiException catch (e) {
      if (mounted) {
        setState(() {
          _aiError = e.message;
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _saveAiAnalysis() async {
    if (_aiResult == null) return;

    final updated = widget.excerpt.copyWith(aiAnalysis: _aiResult);
    await ref.read(excerptActionProvider.notifier).updateExcerpt(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis saved')),
      );
    }
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Excerpt',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this excerpt?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(excerptActionProvider.notifier).deleteExcerpt(
                    entryId: widget.excerpt.entryId,
                    excerptId: widget.excerpt.id,
                  );
              Navigator.of(context).pop();
              this.context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
