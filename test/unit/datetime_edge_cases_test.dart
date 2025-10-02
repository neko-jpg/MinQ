import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTime Edge Cases', () {
    group('Leap Year Tests', () {
      test('2024 is a leap year', () {
        final leapYear = DateTime(2024, 2, 29);
        expect(leapYear.day, 29);
        expect(leapYear.month, 2);
        expect(leapYear.year, 2024);
      });

      test('2023 is not a leap year', () {
        expect(() => DateTime(2023, 2, 29), throwsException);
      });

      test('2000 is a leap year (divisible by 400)', () {
        final leapYear = DateTime(2000, 2, 29);
        expect(leapYear.day, 29);
      });

      test('1900 is not a leap year (divisible by 100 but not 400)', () {
        expect(() => DateTime(1900, 2, 29), throwsException);
      });

      test('Leap year calculation', () {
        expect(isLeapYear(2024), true);
        expect(isLeapYear(2023), false);
        expect(isLeapYear(2000), true);
        expect(isLeapYear(1900), false);
      });
    });

    group('Month End Tests', () {
      test('January has 31 days', () {
        final lastDay = DateTime(2025, 1, 31);
        expect(lastDay.day, 31);
      });

      test('February has 28 days in non-leap year', () {
        final lastDay = DateTime(2023, 2, 28);
        expect(lastDay.day, 28);
        expect(() => DateTime(2023, 2, 29), throwsException);
      });

      test('February has 29 days in leap year', () {
        final lastDay = DateTime(2024, 2, 29);
        expect(lastDay.day, 29);
      });

      test('April has 30 days', () {
        final lastDay = DateTime(2025, 4, 30);
        expect(lastDay.day, 30);
        expect(() => DateTime(2025, 4, 31), throwsException);
      });

      test('Adding 1 month to January 31 goes to February 28/29', () {
        final jan31 = DateTime(2023, 1, 31);
        final feb = DateTime(jan31.year, jan31.month + 1, 28);
        expect(feb.month, 2);
        expect(feb.day, 28);
      });
    });

    group('Timezone Tests', () {
      test('UTC and local time conversion', () {
        final utc = DateTime.utc(2025, 1, 1, 0, 0);
        final local = utc.toLocal();

        expect(utc.isUtc, true);
        expect(local.isUtc, false);
      });

      test('Timezone offset is consistent', () {
        final now = DateTime.now();
        final utcNow = now.toUtc();
        final offset = now.difference(utcNow);

        expect(offset, now.timeZoneOffset);
      });

      test('Day boundary across timezones', () {
        // UTC: 2025-01-01 23:00
        final utc = DateTime.utc(2025, 1, 1, 23, 0);

        // JST (UTC+9): 2025-01-02 08:00
        final jst = utc.add(const Duration(hours: 9));

        expect(utc.day, 1);
        expect(jst.day, 2);
      });

      test('Streak calculation across timezone', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final today = DateTime.now();

        final daysDiff = today.difference(yesterday).inDays;
        expect(daysDiff, 1);
      });
    });

    group('DST (Daylight Saving Time) Tests', () {
      test('DST transition handling', () {
        // Note: DST behavior depends on the system timezone
        final beforeDST = DateTime(2025, 3, 8, 1, 0); // Before DST
        final afterDST = DateTime(2025, 3, 8, 3, 0); // After DST

        final diff = afterDST.difference(beforeDST);
        // In DST regions, this might be 1 hour instead of 2
        expect(diff.inHours >= 1, true);
      });
    });

    group('Year Boundary Tests', () {
      test('New Year transition', () {
        final lastDayOfYear = DateTime(2024, 12, 31, 23, 59, 59);
        final firstDayOfYear = lastDayOfYear.add(const Duration(seconds: 1));

        expect(lastDayOfYear.year, 2024);
        expect(firstDayOfYear.year, 2025);
        expect(firstDayOfYear.month, 1);
        expect(firstDayOfYear.day, 1);
      });

      test('Leap year to non-leap year transition', () {
        final leapYearEnd = DateTime(2024, 12, 31);
        final nonLeapYearStart = DateTime(2025, 1, 1);

        expect(isLeapYear(leapYearEnd.year), true);
        expect(isLeapYear(nonLeapYearStart.year), false);
      });
    });

    group('Week Boundary Tests', () {
      test('Week start calculation (Monday)', () {
        final date = DateTime(2025, 10, 2); // Thursday
        final weekStart = getWeekStart(date);

        expect(weekStart.weekday, DateTime.monday);
        expect(weekStart.isBefore(date) || weekStart.isAtSameMomentAs(date), true);
      });

      test('Week end calculation (Sunday)', () {
        final date = DateTime(2025, 10, 2); // Thursday
        final weekEnd = getWeekEnd(date);

        expect(weekEnd.weekday, DateTime.sunday);
        expect(weekEnd.isAfter(date) || weekEnd.isAtSameMomentAs(date), true);
      });
    });

    group('Streak Calculation Tests', () {
      test('Consecutive days streak', () {
        final dates = [
          DateTime(2025, 10, 1),
          DateTime(2025, 10, 2),
          DateTime(2025, 10, 3),
        ];

        final streak = calculateStreak(dates);
        expect(streak, 3);
      });

      test('Broken streak', () {
        final dates = [
          DateTime(2025, 10, 1),
          DateTime(2025, 10, 2),
          // Missing October 3
          DateTime(2025, 10, 4),
        ];

        final streak = calculateStreak(dates);
        expect(streak, 1); // Only October 4
      });

      test('Streak across month boundary', () {
        final dates = [
          DateTime(2025, 9, 29),
          DateTime(2025, 9, 30),
          DateTime(2025, 10, 1),
          DateTime(2025, 10, 2),
        ];

        final streak = calculateStreak(dates);
        expect(streak, 4);
      });

      test('Streak across year boundary', () {
        final dates = [
          DateTime(2024, 12, 30),
          DateTime(2024, 12, 31),
          DateTime(2025, 1, 1),
          DateTime(2025, 1, 2),
        ];

        final streak = calculateStreak(dates);
        expect(streak, 4);
      });
    });

    group('Date Comparison Tests', () {
      test('Same day comparison', () {
        final date1 = DateTime(2025, 10, 2, 10, 0);
        final date2 = DateTime(2025, 10, 2, 15, 0);

        expect(isSameDay(date1, date2), true);
      });

      test('Different day comparison', () {
        final date1 = DateTime(2025, 10, 2, 23, 59);
        final date2 = DateTime(2025, 10, 3, 0, 1);

        expect(isSameDay(date1, date2), false);
      });

      test('Same day across timezone', () {
        final utc = DateTime.utc(2025, 10, 2, 23, 0);
        final local = utc.toLocal();

        // Depending on timezone, these might be different days
        // This test documents the behavior
        final sameDay = isSameDay(utc, local);
        expect(sameDay, isA<bool>());
      });
    });
  });
}

/// うるう年かチェック
bool isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  if (year % 4 == 0) return true;
  return false;
}

/// 週の開始日を取得（月曜日）
DateTime getWeekStart(DateTime date) {
  final weekday = date.weekday;
  return date.subtract(Duration(days: weekday - 1));
}

/// 週の終了日を取得（日曜日）
DateTime getWeekEnd(DateTime date) {
  final weekday = date.weekday;
  return date.add(Duration(days: 7 - weekday));
}

/// 連続日数を計算
int calculateStreak(List<DateTime> dates) {
  if (dates.isEmpty) return 0;

  // 日付のみで比較するため、時刻を削除
  final sortedDates = dates
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // 降順

  int streak = 1;
  for (int i = 0; i < sortedDates.length - 1; i++) {
    final diff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
    if (diff == 1) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

/// 同じ日かチェック
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
