import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:cultainer/features/journal/excerpt_providers.dart';
import 'package:cultainer/models/excerpt.dart';
import 'package:cultainer/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that displays a list of excerpts for an entry.
class ExcerptListSection extends ConsumerWidget {
  const ExcerptListSection({
    required this.entryId,
    required this.onAddExcerpt,
    required this.onTapExcerpt,
    this.onOcrCapture,
    super.key,
  });

  final String entryId;
  final VoidCallback onAddExcerpt;
  final ValueChanged<Excerpt> onTapExcerpt;
  final VoidCallback? onOcrCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excerptsAsync = ref.watch(excerptsProvider(entryId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Excerpts',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onOcrCapture != null)
                  TextButton.icon(
                    onPressed: onOcrCapture,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('OCR'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                TextButton.icon(
                  onPressed: onAddExcerpt,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        excerptsAsync.when(
          data: (excerpts) {
            if (excerpts.isEmpty) {
              return _buildEmptyState();
            }
            return Column(
              children: [
                ...excerpts.map(
                  (excerpt) => _ExcerptCard(
                    excerpt: excerpt,
                    onTap: () => onTapExcerpt(excerpt),
                  ),
                ),
                if (excerpts.length >= 2) _SummarizeButton(excerpts: excerpts),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (error, _) => Text(
            'Error loading excerpts: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: onAddExcerpt,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.format_quote,
              size: 32,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              'No excerpts yet',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to add a highlight or quote',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarizeButton extends ConsumerStatefulWidget {
  const _SummarizeButton({required this.excerpts});

  final List<Excerpt> excerpts;

  @override
  ConsumerState<_SummarizeButton> createState() => _SummarizeButtonState();
}

class _SummarizeButtonState extends ConsumerState<_SummarizeButton> {
  bool _isSummarizing = false;

  @override
  Widget build(BuildContext context) {
    final gemini = ref.watch(geminiServiceProvider);
    if (!gemini.isConfigured) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isSummarizing ? null : _summarize,
          icon: _isSummarizing
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(Icons.auto_awesome, size: 16),
          label: Text(_isSummarizing ? 'Summarizing...' : 'Summarize All'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _summarize() async {
    setState(() => _isSummarizing = true);

    try {
      final gemini = ref.read(geminiServiceProvider);
      final texts = widget.excerpts.map((e) => e.text).toList();
      final result = await gemini.summarizeExcerpts(texts);
      if (!mounted || result == null) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                result,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } on GeminiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Summary failed: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSummarizing = false);
    }
  }
}

class _ExcerptCard extends StatelessWidget {
  const _ExcerptCard({
    required this.excerpt,
    required this.onTap,
  });

  final Excerpt excerpt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.format_quote,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  if (excerpt.pageNumber != null)
                    Text(
                      'p. ${excerpt.pageNumber}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  const Spacer(),
                  if (excerpt.aiAnalysis != null)
                    const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                excerpt.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
