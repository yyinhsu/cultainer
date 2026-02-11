import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_button.dart';
import 'package:cultainer/core/widgets/app_text_field.dart';
import 'package:cultainer/models/entry.dart';
import 'package:cultainer/services/media_search_service.dart';
import 'package:cultainer/features/journal/entry_providers.dart';
import 'package:cultainer/features/journal/widgets/tag_selector.dart';

/// Entry edit page for creating or editing entries.
class EntryEditPage extends ConsumerStatefulWidget {
  const EntryEditPage({
    this.entryId,
    this.prefillData,
    super.key,
  });

  /// Entry ID for editing, null for creating new entry.
  final String? entryId;

  /// Prefill data from media search.
  final MediaSearchResult? prefillData;

  bool get isEditing => entryId != null;

  @override
  ConsumerState<EntryEditPage> createState() => _EntryEditPageState();
}

class _EntryEditPageState extends ConsumerState<EntryEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _reviewController = TextEditingController();
  final _coverUrlController = TextEditingController();

  MediaType _selectedType = MediaType.book;
  EntryStatus _selectedStatus = EntryStatus.wishlist;
  double? _rating;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadEntry();
    } else if (widget.prefillData != null) {
      _initializeFromPrefill(widget.prefillData!);
    }
  }

  void _initializeFromPrefill(MediaSearchResult data) {
    _titleController.text = data.title;
    _creatorController.text = data.creator ?? '';
    _reviewController.text = data.description ?? '';
    _coverUrlController.text = data.coverUrl ?? '';
    _selectedType = data.type;
    _selectedStatus = EntryStatus.wishlist;
  }

  Future<void> _loadEntry() async {
    // Entry data will be loaded via provider
  }

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _reviewController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If editing, watch the entry
    if (widget.isEditing) {
      final entryAsync = ref.watch(entryProvider(widget.entryId!));
      return entryAsync.when(
        data: (entry) {
          if (entry == null) {
            return _buildNotFound();
          }
          // Initialize form with entry data once
          if (_titleController.text.isEmpty && entry.title.isNotEmpty) {
            _initializeFromEntry(entry);
          }
          return _buildForm(entry: entry);
        },
        loading: _buildLoading,
        error: (error, _) => _buildError(error),
      );
    }

    return _buildForm();
  }

  void _initializeFromEntry(Entry entry) {
    _titleController.text = entry.title;
    _creatorController.text = entry.creator;
    _reviewController.text = entry.review ?? '';
    _coverUrlController.text = entry.coverUrl ?? '';
    _selectedType = entry.type;
    _selectedStatus = entry.status;
    _rating = entry.rating;
    _startDate = entry.startDate;
    _endDate = entry.endDate;
    _selectedTags = List.from(entry.tags);
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('Entry not found',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildForm({Entry? entry}) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.isEditing ? 'Edit Entry' : 'Add Entry',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppButton(
              label: _isLoading ? 'Saving...' : 'Save',
              onPressed: _isLoading ? null : () => _saveEntry(entry),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Media type selector
            Text(
              'Media Type',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _MediaTypeSelector(
              selectedType: _selectedType,
              onChanged: (type) => setState(() => _selectedType = type),
            ),
            const SizedBox(height: 24),

            // Title
            AppTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter title...',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Creator
            AppTextField(
              controller: _creatorController,
              label: _getCreatorLabel(),
              hint: 'Enter ${_getCreatorLabel().toLowerCase()}...',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${_getCreatorLabel()} is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Status
            Text(
              'Status',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _StatusSelector(
              selectedStatus: _selectedStatus,
              onChanged: (status) => setState(() => _selectedStatus = status),
            ),
            const SizedBox(height: 24),

            // Rating
            Text(
              'Rating',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _RatingSelector(
              rating: _rating,
              onChanged: (rating) => setState(() => _rating = rating),
            ),
            const SizedBox(height: 24),

            // Cover URL
            AppTextField(
              controller: _coverUrlController,
              label: 'Cover Image URL (Optional)',
              hint: 'https://...',
            ),
            const SizedBox(height: 24),

            // Dates
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    date: _startDate,
                    onChanged: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateField(
                    label: 'End Date',
                    date: _endDate,
                    onChanged: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tags
            TagSelector(
              selectedTagIds: _selectedTags,
              onTagsChanged: (tags) => setState(() => _selectedTags = tags),
            ),
            const SizedBox(height: 24),

            // Review
            AppTextField(
              controller: _reviewController,
              label: 'Review (Optional)',
              hint: 'Write your thoughts...',
              maxLines: 5,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _getCreatorLabel() {
    switch (_selectedType) {
      case MediaType.book:
        return 'Author';
      case MediaType.movie:
        return 'Director';
      case MediaType.tv:
        return 'Creator';
      case MediaType.music:
        return 'Artist';
      case MediaType.other:
        return 'Creator';
    }
  }

  Future<void> _saveEntry(Entry? existingEntry) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(entryActionProvider.notifier);

      if (widget.isEditing && existingEntry != null) {
        // Update existing entry
        final updated = existingEntry.copyWith(
          type: _selectedType,
          title: _titleController.text.trim(),
          creator: _creatorController.text.trim(),
          status: _selectedStatus,
          rating: _rating,
          review: _reviewController.text.trim().isEmpty
              ? null
              : _reviewController.text.trim(),
          coverUrl: _coverUrlController.text.trim().isEmpty
              ? null
              : _coverUrlController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          tags: _selectedTags,
        );
        await notifier.updateEntry(updated);
      } else {
        // Create new entry
        await notifier.createEntry(
          type: _selectedType,
          title: _titleController.text.trim(),
          creator: _creatorController.text.trim(),
          status: _selectedStatus,
          rating: _rating,
          review: _reviewController.text.trim().isEmpty
              ? null
              : _reviewController.text.trim(),
          coverUrl: _coverUrlController.text.trim().isEmpty
              ? null
              : _coverUrlController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          tags: _selectedTags,
        );
      }

      if (mounted) {
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _MediaTypeSelector extends StatelessWidget {
  const _MediaTypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  final MediaType selectedType;
  final ValueChanged<MediaType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MediaType.values.map((type) {
          final isSelected = type == selectedType;
          final color = _getTypeColor(type);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      size: 18,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected ? color : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getTypeColor(MediaType type) {
    switch (type) {
      case MediaType.book:
        return AppColors.bookColor;
      case MediaType.movie:
        return AppColors.movieColor;
      case MediaType.tv:
        return AppColors.tvColor;
      case MediaType.music:
        return AppColors.musicColor;
      case MediaType.other:
        return AppColors.otherColor;
    }
  }

  IconData _getTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.book:
        return Icons.menu_book;
      case MediaType.movie:
        return Icons.movie;
      case MediaType.tv:
        return Icons.tv;
      case MediaType.music:
        return Icons.music_note;
      case MediaType.other:
        return Icons.category;
    }
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.selectedStatus,
    required this.onChanged,
  });

  final EntryStatus selectedStatus;
  final ValueChanged<EntryStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EntryStatus.values.map((status) {
        final isSelected = status == selectedStatus;
        final color = _getStatusColor(status);
        return GestureDetector(
          onTap: () => onChanged(status),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color:
                  isSelected ? color.withValues(alpha: 0.2) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
              ),
            ),
            child: Text(
              status.label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(EntryStatus status) {
    switch (status) {
      case EntryStatus.wishlist:
        return AppColors.wishlistColor;
      case EntryStatus.inProgress:
        return AppColors.inProgressColor;
      case EntryStatus.completed:
        return AppColors.completedColor;
      case EntryStatus.dropped:
        return AppColors.droppedColor;
      case EntryStatus.recall:
        return AppColors.recallColor;
    }
  }
}

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({
    required this.rating,
    required this.onChanged,
  });

  final double? rating;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surfaceVariant,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: rating ?? 0,
                  max: 10,
                  divisions: 20,
                  onChanged: (value) => onChanged(value == 0 ? null : value),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                rating != null ? rating!.toStringAsFixed(1) : 'N/A',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        if (rating != null)
          TextButton(
            onPressed: () => onChanged(null),
            child: Text(
              'Clear rating',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? '${date!.month}/${date!.day}/${date!.year}'
                        : 'Select...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      onChanged(selected);
    }
  }
}
