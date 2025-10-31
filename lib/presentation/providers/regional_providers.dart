import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/i18n/cultural_adaptation_service.dart';
import 'package:minq/core/i18n/regional_service.dart';
import 'package:minq/core/i18n/timezone_service.dart';
import 'package:minq/data/providers.dart';
import 'package:timezone/timezone.dart' as tz;

/// Provider for regional configuration based on current locale
final regionalConfigProvider = Provider<RegionalConfig>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return RegionalService.getRegionalConfig(locale);
});

/// Provider for timezone based on current locale
final timezoneProvider = Provider<tz.Location>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return TimezoneService.getTimezoneForLocale(locale);
});

/// Provider for current time in user's timezone
final currentTimeProvider = Provider<tz.TZDateTime>((ref) {
  final timezone = ref.watch(timezoneProvider);
  return TimezoneService.nowInTimezone(timezone);
});

/// Provider for cultural colors based on current locale
final culturalColorsProvider = Provider<CulturalColors>((ref) {
  final config = ref.watch(regionalConfigProvider);
  return config.culturalColors;
});

/// Provider for cultural numbers based on current locale
final culturalNumbersProvider = Provider<CulturalNumbers>((ref) {
  final config = ref.watch(regionalConfigProvider);
  return config.culturalNumbers;
});

/// Provider for text direction based on current locale
final textDirectionProvider = Provider<TextDirection>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
});

/// Provider for checking if current locale is RTL
final isRTLProvider = Provider<bool>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return locale.languageCode == 'ar';
});

/// Provider for formatted currency
final currencyFormatterProvider = Provider.family<String, double>((ref, amount) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return RegionalService.formatCurrency(amount, locale);
});

/// Provider for formatted date
final dateFormatterProvider = Provider.family<String, DateTime>((ref, date) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return RegionalService.formatDate(date, locale);
});

/// Provider for formatted time
final timeFormatterProvider = Provider.family<String, DateTime>((ref, time) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return RegionalService.formatTime(time, locale);
});

/// Provider for formatted number
final numberFormatterProvider = Provider.family<String, int>((ref, number) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.formatNumber(number, locale);
});

/// Provider for time-based greeting
final greetingProvider = Provider<String>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  final currentTime = ref.watch(currentTimeProvider);
  return CulturalAdaptationService.getTimeBasedGreeting(currentTime, locale);
});

/// Provider for motivational messages
final motivationalMessagesProvider = Provider<List<String>>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.getMotivationalMessages(locale);
});

/// Provider for celebration messages
final celebrationMessagesProvider = Provider<List<String>>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.getCelebrationMessages(locale);
});

/// Provider for difficulty labels
final difficultyLabelsProvider = Provider<List<String>>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.getDifficultyLabels(locale);
});

/// Provider for priority labels
final priorityLabelsProvider = Provider<List<String>>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.getPriorityLabels(locale);
});

/// Provider for checking if a date is a holiday
final isHolidayProvider = Provider.family<bool, DateTime>((ref, date) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return RegionalService.isHoliday(date, locale);
});

/// Provider for holidays in current year
final holidaysProvider = Provider<List<Holiday>>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  final currentYear = DateTime.now().year;
  return RegionalService.getHolidays(currentYear, locale);
});

/// Provider for upcoming holidays (next 3)
final upcomingHolidaysProvider = Provider<List<Holiday>>((ref) {
  final holidays = ref.watch(holidaysProvider);
  final now = DateTime.now();
  
  return holidays
      .where((holiday) => holiday.getDateForYear(now.year).isAfter(now))
      .take(3)
      .toList();
});

/// Provider for cultural icon based on concept
final culturalIconProvider = Provider.family<IconData, String>((ref, concept) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.getCulturalIcon(concept, locale);
});

/// Provider for cultural color based on concept
final culturalColorProvider = Provider.family<Color, String>((ref, concept) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return RegionalService.getCulturalColor(concept, locale);
});

/// Provider for achievement title formatting
final achievementTitleProvider = Provider.family<String, AchievementParams>((ref, params) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.getAchievementTitle(
    params.type,
    params.level,
    locale,
  );
});

/// Provider for checking if a number is lucky
final isLuckyNumberProvider = Provider.family<bool, int>((ref, number) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return RegionalService.isLuckyNumber(number, locale);
});

/// Provider for checking if a number is unlucky
final isUnluckyNumberProvider = Provider.family<bool, int>((ref, number) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return RegionalService.isUnluckyNumber(number, locale);
});

/// Provider for directional padding based on locale
final directionalPaddingProvider = Provider.family<EdgeInsets, PaddingParams>((ref, params) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.getDirectionalPadding(
    locale,
    start: params.start,
    top: params.top,
    end: params.end,
    bottom: params.bottom,
  );
});

/// Provider for text alignment based on locale
final textAlignmentProvider = Provider<TextAlign>((ref) {
  final locale = ref.watch(appLocaleControllerProvider) ?? const Locale('ja');
  return CulturalAdaptationService.getTextAlignment(locale);
});

/// Helper classes for provider parameters
class AchievementParams {
  const AchievementParams({
    required this.type,
    required this.level,
  });

  final String type;
  final int level;
}

class PaddingParams {
  const PaddingParams({
    this.start = 0,
    this.top = 0,
    this.end = 0,
    this.bottom = 0,
  });

  final double start;
  final double top;
  final double end;
  final double bottom;
}