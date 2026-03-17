import 'package:cultainer/core/constants/enums.dart';
import 'package:cultainer/models/entry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the date calculation logic used in CalendarPage.
/// These test the pure algorithms extracted from the widget.
void main() {
  group('Calendar grid calculation', () {
    test('calculates correct days in month', () {
      // February 2026 (non-leap year)
      expect(DateTime(2026, 3, 0).day, 28);
      // February 2024 (leap year)
      expect(DateTime(2024, 3, 0).day, 29);
      // January
      expect(DateTime(2026, 2, 0).day, 31);
      // April
      expect(DateTime(2026, 5, 0).day, 30);
    });

    test('calculates correct start weekday offset', () {
      // March 2026 starts on Sunday (weekday 7), offset = 6 (Mon=0 based)
      final march2026 = DateTime(2026, 3);
      expect(march2026.weekday, 7); // Sunday
      expect(march2026.weekday - 1, 6); // offset for Mon-start grid

      // January 2026 starts on Thursday (weekday 4), offset = 3
      final jan2026 = DateTime(2026, 1);
      expect(jan2026.weekday, 4);
      expect(jan2026.weekday - 1, 3);

      // June 2026 starts on Monday (weekday 1), offset = 0
      final june2026 = DateTime(2026, 6);
      expect(june2026.weekday, 1);
      expect(june2026.weekday - 1, 0);
    });

    test('calculates correct number of grid rows', () {
      // March 2026: offset=6, 31 days, total=37, rows=ceil(37/7)=6
      final marchOffset = DateTime(2026, 3).weekday - 1;
      final marchDays = DateTime(2026, 4, 0).day;
      expect(((marchOffset + marchDays) / 7).ceil(), 6);

      // June 2026: offset=0, 30 days, total=30, rows=ceil(30/7)=5
      final juneOffset = DateTime(2026, 6).weekday - 1;
      final juneDays = DateTime(2026, 7, 0).day;
      expect(((juneOffset + juneDays) / 7).ceil(), 5);

      // February 2026: offset=6 (Sunday start), 28 days, total=34, rows=5
      final febOffset = DateTime(2026, 2).weekday - 1;
      final febDays = DateTime(2026, 3, 0).day;
      expect(((febOffset + febDays) / 7).ceil(), 5);
    });
  });

  group('Entry date mapping', () {
    Entry createEntry({
      required String id,
      DateTime? endDate,
      required DateTime createdAt,
    }) {
      return Entry(
        id: id,
        type: MediaType.movie,
        title: 'Test',
        creator: 'Creator',
        status: EntryStatus.completed,
        endDate: endDate,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
    }

    test('uses endDate when available', () {
      final entry = createEntry(
        id: '1',
        endDate: DateTime(2026, 3, 15),
        createdAt: DateTime(2026, 3, 1),
      );
      final entryDate = entry.endDate ?? entry.createdAt;
      expect(entryDate.day, 15);
    });

    test('falls back to createdAt when endDate is null', () {
      final entry = createEntry(
        id: '1',
        createdAt: DateTime(2026, 3, 1),
      );
      final entryDate = entry.endDate ?? entry.createdAt;
      expect(entryDate.day, 1);
    });

    test('counts entries per day correctly', () {
      final currentMonth = DateTime(2026, 3);
      final entries = [
        createEntry(id: '1', createdAt: DateTime(2026, 3, 5)),
        createEntry(id: '2', createdAt: DateTime(2026, 3, 5)),
        createEntry(id: '3', createdAt: DateTime(2026, 3, 10)),
        createEntry(
          id: '4',
          endDate: DateTime(2026, 3, 5),
          createdAt: DateTime(2026, 2, 28),
        ),
        // Entry from different month — should be excluded
        createEntry(id: '5', createdAt: DateTime(2026, 2, 15)),
      ];

      final counts = <int, int>{};
      for (final entry in entries) {
        final entryDate = entry.endDate ?? entry.createdAt;
        if (entryDate.year == currentMonth.year &&
            entryDate.month == currentMonth.month) {
          counts[entryDate.day] = (counts[entryDate.day] ?? 0) + 1;
        }
      }

      expect(counts[5], 3); // Two created + one endDate on day 5
      expect(counts[10], 1);
      expect(counts.containsKey(15), isFalse); // Feb entry excluded
    });

    test('filters entries for selected date correctly', () {
      final date = DateTime(2026, 3, 5);
      final entries = [
        createEntry(id: '1', createdAt: DateTime(2026, 3, 5)),
        createEntry(id: '2', createdAt: DateTime(2026, 3, 6)),
        createEntry(
          id: '3',
          endDate: DateTime(2026, 3, 5),
          createdAt: DateTime(2026, 2, 1),
        ),
      ];

      final filtered = entries.where((entry) {
        final entryDate = entry.endDate ?? entry.createdAt;
        return entryDate.year == date.year &&
            entryDate.month == date.month &&
            entryDate.day == date.day;
      }).toList();

      expect(filtered.length, 2);
      expect(filtered.map((e) => e.id), containsAll(['1', '3']));
    });
  });

  group('Day suffix', () {
    String getDaySuffix(int day) {
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

    test('returns st for 1st, 21st, 31st', () {
      expect(getDaySuffix(1), 'st');
      expect(getDaySuffix(21), 'st');
      expect(getDaySuffix(31), 'st');
    });

    test('returns nd for 2nd, 22nd', () {
      expect(getDaySuffix(2), 'nd');
      expect(getDaySuffix(22), 'nd');
    });

    test('returns rd for 3rd, 23rd', () {
      expect(getDaySuffix(3), 'rd');
      expect(getDaySuffix(23), 'rd');
    });

    test('returns th for 11th, 12th, 13th', () {
      expect(getDaySuffix(11), 'th');
      expect(getDaySuffix(12), 'th');
      expect(getDaySuffix(13), 'th');
    });

    test('returns th for other numbers', () {
      expect(getDaySuffix(4), 'th');
      expect(getDaySuffix(15), 'th');
      expect(getDaySuffix(20), 'th');
      expect(getDaySuffix(30), 'th');
    });
  });

  group('Month navigation', () {
    test('previous month wraps year boundary', () {
      final jan2026 = DateTime(2026, 1);
      final prev = DateTime(jan2026.year, jan2026.month - 1);
      expect(prev.year, 2025);
      expect(prev.month, 12);
    });

    test('next month wraps year boundary', () {
      final dec2025 = DateTime(2025, 12);
      final next = DateTime(dec2025.year, dec2025.month + 1);
      expect(next.year, 2026);
      expect(next.month, 1);
    });

    test('today detection', () {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final isCurrentMonth =
          currentMonth.year == now.year && currentMonth.month == now.month;
      expect(isCurrentMonth, isTrue);

      final otherMonth = DateTime(now.year, now.month - 1);
      final isOtherCurrentMonth =
          otherMonth.year == now.year && otherMonth.month == now.month;
      expect(isOtherCurrentMonth, isFalse);
    });
  });
}
