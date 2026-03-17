import 'package:cached_network_image/cached_network_image.dart';
import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:cultainer/features/journal/entry_providers.dart';
import 'package:cultainer/models/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Calendar page displaying entries by date.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
      );
    });
  }

  /// Gets entries for a specific date (by endDate or createdAt).
  List<Entry> _getEntriesForDate(List<Entry> entries, DateTime date) {
    return entries.where((entry) {
      final entryDate = entry.endDate ?? entry.createdAt;
      return entryDate.year == date.year &&
          entryDate.month == date.month &&
          entryDate.day == date.day;
    }).toList();
  }

  /// Gets all dates with entries in the current month.
  Map<int, int> _getEntryCountsByDay(List<Entry> entries) {
    final counts = <int, int>{};
    for (final entry in entries) {
      final entryDate = entry.endDate ?? entry.createdAt;
      if (entryDate.year == _currentMonth.year &&
          entryDate.month == _currentMonth.month) {
        counts[entryDate.day] = (counts[entryDate.day] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(entriesProvider);
    final entries = entriesAsync.valueOrNull ?? [];
    final entryCounts = _getEntryCountsByDay(entries);
    final selectedEntries = _selectedDate != null
        ? _getEntriesForDate(entries, _selectedDate!)
        : <Entry>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Month navigation
            _buildMonthNavigation(),

            // Weekday labels
            _buildWeekdayLabels(),

            // Calendar grid
            _buildCalendarGrid(entryCounts),

            const SizedBox(height: 16),

            // Selected date entries
            Expanded(
              child: _buildSelectedDateEntries(selectedEntries),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final monthFormat = DateFormat('MMMM yyyy');
    final now = DateTime.now();
    final isCurrentMonth =
        _currentMonth.year == now.year && _currentMonth.month == now.month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(
            monthFormat.format(_currentMonth),
            style: AppTypography.displayLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (!isCurrentMonth)
            IconButton(
              onPressed: _goToToday,
              icon: const Icon(Icons.today, color: AppColors.primary),
              tooltip: 'Today',
            ),
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: days.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<int, int> entryCounts) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month);
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;

    // Monday = 1, so offset is (weekday - 1)
    final startWeekday = firstDay.weekday - 1;
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              final day = index - startWeekday + 1;

              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox(height: 44));
              }

              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isSelected = _selectedDate != null &&
                  date.year == _selectedDate!.year &&
                  date.month == _selectedDate!.month &&
                  date.day == _selectedDate!.day;
              final entryCount = entryCounts[day] ?? 0;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.toString(),
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (entryCount > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              entryCount.clamp(0, 3),
                              (_) => Container(
                                width: 4,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedDateEntries(List<Entry> entries) {
    if (_selectedDate == null) {
      return const SizedBox.shrink();
    }

    final dateFormat = DateFormat('EEEE, d');
    final suffix = _getDaySuffix(_selectedDate!.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${dateFormat.format(_selectedDate!)}$suffix',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.event_note,
                      size: 32,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No entries on this day',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return _CalendarEntryCard(entry: entries[index]);
              },
            ),
          ),
      ],
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

Color _mediaTypeColor(MediaType type) {
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

class _CalendarEntryCard extends StatelessWidget {
  const _CalendarEntryCard({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final typeColor = _mediaTypeColor(entry.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => context.push('/entry/${entry.id}'),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: entry.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: entry.coverUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const _CoverPlaceholder(),
                      )
                    : const _CoverPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // Title and creator
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.creator,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Media type badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.type.label,
                style: AppTypography.labelSmall.copyWith(
                  color: typeColor,
                  fontSize: 10,
                ),
              ),
            ),

            // Rating
            if (entry.rating != null) ...[
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  Text(
                    entry.rating!.toStringAsFixed(1),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textTertiary,
          size: 20,
        ),
      ),
    );
  }
}
