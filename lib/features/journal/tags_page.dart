import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:cultainer/features/journal/tag_providers.dart';
import 'package:cultainer/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available preset colors for tags.
const _presetColors = [
  'E74C3C',
  'E67E22',
  'F1C40F',
  '2ECC71',
  '1ABC9C',
  '3498DB',
  '9B59B6',
  'E91E63',
  'FF5733',
  '607D8B',
];

/// Full-screen page for managing user-defined tags.
class TagsPage extends ConsumerWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Manage Tags',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: tagsAsync.when(
        data: (tags) => _TagList(tags: tags),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error loading tags: $error',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showTagDialog(context, ref),
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
    );
  }
}

class _TagList extends ConsumerWidget {
  const _TagList({required this.tags});

  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tags.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.label_outline,
                  size: 40,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No tags yet',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to create your first tag',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: tags.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tag = tags[index];
        return _TagCard(tag: tag);
      },
    );
  }
}

class _TagCard extends ConsumerWidget {
  const _TagCard({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagColor = tag.colorValue ?? AppColors.primary;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Color swatch
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),

          // Tag name
          Expanded(
            child: Text(
              tag.name,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.textSecondary,
            onPressed: () => _showTagDialog(context, ref, tag: tag),
            tooltip: 'Edit',
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.error,
            onPressed: () => _confirmDelete(context, ref),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Tag',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Delete "${tag.name}"? This will remove it from all entries.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(tagActionProvider.notifier)
                  .deleteTag(tag.id);
            },
            child: Text(
              'Delete',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a dialog for creating or editing a tag.
void _showTagDialog(
  BuildContext context,
  WidgetRef ref, {
  Tag? tag,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _TagDialog(existingTag: tag, ref: ref),
  );
}

class _TagDialog extends StatefulWidget {
  const _TagDialog({
    required this.ref,
    this.existingTag,
  });

  final Tag? existingTag;
  final WidgetRef ref;

  @override
  State<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<_TagDialog> {
  late final TextEditingController _nameController;
  String? _selectedColor;

  bool get _isEditing => widget.existingTag != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingTag?.name ?? '',
    );
    _selectedColor = widget.existingTag?.color ?? _presetColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_isEditing) {
      final updated = widget.existingTag!.copyWith(
        name: name,
        color: _selectedColor,
      );
      await widget.ref.read(tagActionProvider.notifier).updateTag(updated);
    } else {
      await widget.ref.read(tagActionProvider.notifier).createTag(
            name: name,
            color: _selectedColor,
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        _isEditing ? 'Edit Tag' : 'New Tag',
        style: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              autofocus: true,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Tag name',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            // Color picker
            Text(
              'Color',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presetColors.map((hex) {
                final color = Color(int.parse('FF$hex', radix: 16));
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.textPrimary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
          ),
          child: Text(_isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
