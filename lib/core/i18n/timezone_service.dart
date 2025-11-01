import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling timezone operations and conversions
class TimezoneService {
  static bool _initialized = false;

  /// Initialize timezone data
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    _initialized = true;
  }

  /// Get the device's current timezone
  static tz.Location getCurrentTimezone() {
    if (!_initialized) {
      throw StateError(
        'TimezoneService not initialized. Call initialize() first.',
      );
    }

    // Try to get system timezone
    try {
      final timezoneName = _getSystemTimezoneName();
      return tz.getLocation(timezoneName);
    } catch (e) {
      // Fallback to UTC if system timezone detection fails
      return tz.UTC;
    }
  }

  /// Get timezone for a specific locale/region
  static tz.Location getTimezoneForLocale(Locale locale) {
    if (!_initialized) {
      throw StateError(
        'TimezoneService not initialized. Call initialize() first.',
      );
    }

    final timezoneMap = {
      'ja': 'Asia/Tokyo',
      'zh': 'Asia/Shanghai',
      'ko': 'Asia/Seoul',
      'ar': 'Asia/Riyadh',
      'es': 'Europe/Madrid',
      'en': 'America/New_York', // Default to Eastern Time for English
    };

    final timezoneName = timezoneMap[locale.languageCode] ?? 'UTC';

    try {
      return tz.getLocation(timezoneName);
    } catch (e) {
      return tz.UTC;
    }
  }

  /// Convert DateTime to specific timezone
  static tz.TZDateTime convertToTimezone(
    DateTime dateTime,
    tz.Location timezone,
  ) {
    if (!_initialized) {
      throw StateError(
        'TimezoneService not initialized. Call initialize() first.',
      );
    }

    if (dateTime is tz.TZDateTime) {
      return tz.TZDateTime.from(dateTime, timezone);
    } else {
      return tz.TZDateTime.from(dateTime, timezone);
    }
  }

  /// Get current time in specific timezone
  static tz.TZDateTime nowInTimezone(tz.Location timezone) {
    if (!_initialized) {
      throw StateError(
        'TimezoneService not initialized. Call initialize() first.',
      );
    }

    return tz.TZDateTime.now(timezone);
  }

  /// Get current time in locale's timezone
  static tz.TZDateTime nowInLocaleTimezone(Locale locale) {
    final timezone = getTimezoneForLocale(locale);
    return nowInTimezone(timezone);
  }

  /// Format time with timezone information
  static String formatWithTimezone(
    tz.TZDateTime dateTime, {
    bool showTimezone = true,
  }) {
    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (!showTimezone) {
      return timeStr;
    }

    final offsetHours = dateTime.timeZoneOffset.inHours;
    final offsetMinutes = dateTime.timeZoneOffset.inMinutes.remainder(60);
    final offsetStr =
        '${offsetHours >= 0 ? '+' : ''}${offsetHours.toString().padLeft(2, '0')}:${offsetMinutes.abs().toString().padLeft(2, '0')}';

    return '$timeStr (UTC$offsetStr)';
  }

  /// Check if daylight saving time is active
  static bool isDaylightSavingTime(tz.TZDateTime dateTime) {
    if (!_initialized) {
      throw StateError(
        'TimezoneService not initialized. Call initialize() first.',
      );
    }

    // Create a date in winter (January) and summer (July) to compare offsets
    final winterDate = tz.TZDateTime(dateTime.location, dateTime.year, 1, 1);
    final summerDate = tz.TZDateTime(dateTime.location, dateTime.year, 7, 1);

    // If current offset is different from winter offset, DST might be active
    return dateTime.timeZoneOffset != winterDate.timeZoneOffset;
  }

  /// Get timezone abbreviation (e.g., JST, EST, PST)
  static String getTimezoneAbbreviation(tz.Location location) {
    final now = tz.TZDateTime.now(location);
    return now.timeZoneName;
  }

  /// Get all available timezones
  static List<String> getAllTimezones() {
    if (!_initialized) {
      throw StateError(
        'TimezoneService not initialized. Call initialize() first.',
      );
    }

    return tz.timeZoneDatabase.locations.keys.toList()..sort();
  }

  /// Get common timezones for user selection
  static List<TimezoneInfo> getCommonTimezones() {
    return [
      const TimezoneInfo('UTC', 'Coordinated Universal Time', 'UTC'),
      const TimezoneInfo('America/New_York', 'Eastern Time', 'EST/EDT'),
      const TimezoneInfo('America/Chicago', 'Central Time', 'CST/CDT'),
      const TimezoneInfo('America/Denver', 'Mountain Time', 'MST/MDT'),
      const TimezoneInfo('America/Los_Angeles', 'Pacific Time', 'PST/PDT'),
      const TimezoneInfo('Europe/London', 'Greenwich Mean Time', 'GMT/BST'),
      const TimezoneInfo('Europe/Paris', 'Central European Time', 'CET/CEST'),
      const TimezoneInfo('Europe/Madrid', 'Central European Time', 'CET/CEST'),
      const TimezoneInfo('Asia/Tokyo', 'Japan Standard Time', 'JST'),
      const TimezoneInfo('Asia/Shanghai', 'China Standard Time', 'CST'),
      const TimezoneInfo('Asia/Seoul', 'Korea Standard Time', 'KST'),
      const TimezoneInfo('Asia/Riyadh', 'Arabia Standard Time', 'AST'),
      const TimezoneInfo('Asia/Dubai', 'Gulf Standard Time', 'GST'),
      const TimezoneInfo(
        'Australia/Sydney',
        'Australian Eastern Time',
        'AEST/AEDT',
      ),
    ];
  }

  /// Calculate time difference between two timezones
  static Duration getTimeDifference(tz.Location from, tz.Location to) {
    final now = DateTime.now();
    final fromTime = tz.TZDateTime.from(now, from);
    final toTime = tz.TZDateTime.from(now, to);

    return toTime.timeZoneOffset - fromTime.timeZoneOffset;
  }

  /// Schedule notification considering timezone
  static DateTime scheduleInTimezone(
    DateTime localTime,
    tz.Location targetTimezone,
  ) {
    final targetTime = tz.TZDateTime.from(localTime, targetTimezone);
    return targetTime.toLocal();
  }

  /// Get system timezone name (platform-specific)
  static String _getSystemTimezoneName() {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // On mobile platforms, try to get timezone from system
        final now = DateTime.now();
        final offset = now.timeZoneOffset;

        // Map common offsets to timezone names
        final offsetHours = offset.inHours;
        switch (offsetHours) {
          case 9:
            return 'Asia/Tokyo';
          case 8:
            return 'Asia/Shanghai';
          case -5:
            return 'America/New_York';
          case -8:
            return 'America/Los_Angeles';
          case 0:
            return 'UTC';
          case 1:
            return 'Europe/Paris';
          case 3:
            return 'Asia/Riyadh';
          default:
            return 'UTC';
        }
      } else {
        // On desktop platforms, try to get from environment
        final timezone = Platform.environment['TZ'];
        if (timezone != null && timezone.isNotEmpty) {
          return timezone;
        }
      }
    } catch (e) {
      // Ignore errors and fall back to UTC
    }

    return 'UTC';
  }

  /// Convert business hours to user's timezone
  static List<TimeRange> convertBusinessHours(
    List<TimeRange> businessHours,
    tz.Location businessTimezone,
    tz.Location userTimezone,
  ) {
    return businessHours.map((range) {
      final startInBusiness = tz.TZDateTime(
        businessTimezone,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        range.start.hour,
        range.start.minute,
      );

      final endInBusiness = tz.TZDateTime(
        businessTimezone,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        range.end.hour,
        range.end.minute,
      );

      final startInUser = tz.TZDateTime.from(startInBusiness, userTimezone);
      final endInUser = tz.TZDateTime.from(endInBusiness, userTimezone);

      return TimeRange(
        TimeOfDay(hour: startInUser.hour, minute: startInUser.minute),
        TimeOfDay(hour: endInUser.hour, minute: endInUser.minute),
      );
    }).toList();
  }
}

class TimezoneInfo {
  const TimezoneInfo(this.id, this.displayName, this.abbreviation);

  final String id;
  final String displayName;
  final String abbreviation;

  @override
  String toString() => '$displayName ($abbreviation)';
}

class TimeRange {
  const TimeRange(this.start, this.end);

  final TimeOfDay start;
  final TimeOfDay end;

  bool contains(TimeOfDay time) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final timeMinutes = time.hour * 60 + time.minute;

    if (startMinutes <= endMinutes) {
      // Same day range
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Overnight range
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
}
