import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Service for handling regional and cultural considerations
class RegionalService {
  static final Map<String, RegionalConfig> _regionalConfigs = {
    'ja': const RegionalConfig(
      locale: Locale('ja'),
      currency: 'JPY',
      currencySymbol: '¥',
      dateFormat: 'yyyy/MM/dd',
      timeFormat: 'HH:mm',
      firstDayOfWeek: DateTime.monday,
      culturalColors: CulturalColors(
        lucky: Color(0xFFFF0000), // Red is lucky in Japan
        unlucky: Color(0xFF000000), // Black can be unlucky
        celebration: Color(0xFFFF69B4), // Pink for cherry blossoms
        prosperity: Color(0xFFFFD700), // Gold
      ),
      culturalNumbers: CulturalNumbers(
        lucky: [7, 8],
        unlucky: [4, 9], // 4 sounds like death, 9 sounds like suffering
      ),
      holidays: [
        Holiday('New Year\'s Day', 'January 1'),
        Holiday('Coming of Age Day', 'Second Monday of January'),
        Holiday('National Foundation Day', 'February 11'),
        Holiday('Emperor\'s Birthday', 'February 23'),
        Holiday('Vernal Equinox Day', 'March 20'),
        Holiday('Showa Day', 'April 29'),
        Holiday('Constitution Memorial Day', 'May 3'),
        Holiday('Greenery Day', 'May 4'),
        Holiday('Children\'s Day', 'May 5'),
        Holiday('Marine Day', 'Third Monday of July'),
        Holiday('Mountain Day', 'August 11'),
        Holiday('Respect for the Aged Day', 'Third Monday of September'),
        Holiday('Autumnal Equinox Day', 'September 22'),
        Holiday('Sports Day', 'Second Monday of October'),
        Holiday('Culture Day', 'November 3'),
        Holiday('Labor Thanksgiving Day', 'November 23'),
      ],
    ),
    'en': const RegionalConfig(
      locale: Locale('en'),
      currency: 'USD',
      currencySymbol: '\$',
      dateFormat: 'MM/dd/yyyy',
      timeFormat: 'h:mm a',
      firstDayOfWeek: DateTime.sunday,
      culturalColors: CulturalColors(
        lucky: Color(0xFF00FF00), // Green for luck and money
        unlucky: Color(0xFF000000), // Black
        celebration: Color(0xFF0000FF), // Blue
        prosperity: Color(0xFFFFD700), // Gold
      ),
      culturalNumbers: CulturalNumbers(
        lucky: [7, 13], // 7 is lucky, 13 can be lucky or unlucky
        unlucky: [13], // Friday the 13th
      ),
      holidays: [
        Holiday('New Year\'s Day', 'January 1'),
        Holiday('Martin Luther King Jr. Day', 'Third Monday of January'),
        Holiday('Presidents\' Day', 'Third Monday of February'),
        Holiday('Memorial Day', 'Last Monday of May'),
        Holiday('Independence Day', 'July 4'),
        Holiday('Labor Day', 'First Monday of September'),
        Holiday('Columbus Day', 'Second Monday of October'),
        Holiday('Veterans Day', 'November 11'),
        Holiday('Thanksgiving', 'Fourth Thursday of November'),
        Holiday('Christmas Day', 'December 25'),
      ],
    ),
    'zh': const RegionalConfig(
      locale: Locale('zh'),
      currency: 'CNY',
      currencySymbol: '¥',
      dateFormat: 'yyyy年MM月dd日',
      timeFormat: 'HH:mm',
      firstDayOfWeek: DateTime.monday,
      culturalColors: CulturalColors(
        lucky: Color(0xFFFF0000), // Red is very lucky
        unlucky: Color(0xFFFFFFFF), // White can be unlucky (death)
        celebration: Color(0xFFFFD700), // Gold for prosperity
        prosperity: Color(0xFFFF0000), // Red for prosperity
      ),
      culturalNumbers: CulturalNumbers(
        lucky: [6, 8, 9], // 6 (smooth), 8 (prosperity), 9 (long-lasting)
        unlucky: [4], // Sounds like death
      ),
      holidays: [
        Holiday('New Year\'s Day', 'January 1'),
        Holiday('Spring Festival', 'February 10'), // Chinese New Year (varies)
        Holiday('Tomb Sweeping Day', 'April 4'),
        Holiday('Labor Day', 'May 1'),
        Holiday('Dragon Boat Festival', 'June 10'), // Varies
        Holiday('Mid-Autumn Festival', 'September 17'), // Varies
        Holiday('National Day', 'October 1'),
      ],
    ),
    'ko': const RegionalConfig(
      locale: Locale('ko'),
      currency: 'KRW',
      currencySymbol: '₩',
      dateFormat: 'yyyy년 MM월 dd일',
      timeFormat: 'HH:mm',
      firstDayOfWeek: DateTime.sunday,
      culturalColors: CulturalColors(
        lucky: Color(0xFFFF0000), // Red for luck
        unlucky: Color(0xFFFFFFFF), // White for death/mourning
        celebration: Color(0xFFFFD700), // Gold
        prosperity: Color(0xFF00FF00), // Green
      ),
      culturalNumbers: CulturalNumbers(
        lucky: [7, 8],
        unlucky: [4], // Death
      ),
      holidays: [
        Holiday('New Year\'s Day', 'January 1'),
        Holiday('Lunar New Year', 'February 10'), // Varies
        Holiday('Independence Movement Day', 'March 1'),
        Holiday('Children\'s Day', 'May 5'),
        Holiday('Buddha\'s Birthday', 'May 15'), // Varies
        Holiday('Memorial Day', 'June 6'),
        Holiday('Liberation Day', 'August 15'),
        Holiday('Chuseok', 'September 17'), // Varies
        Holiday('National Foundation Day', 'October 3'),
        Holiday('Hangeul Day', 'October 9'),
        Holiday('Christmas Day', 'December 25'),
      ],
    ),
    'es': const RegionalConfig(
      locale: Locale('es'),
      currency: 'EUR',
      currencySymbol: '€',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: 'HH:mm',
      firstDayOfWeek: DateTime.monday,
      culturalColors: CulturalColors(
        lucky: Color(0xFFFF0000), // Red
        unlucky: Color(0xFF000000), // Black
        celebration: Color(0xFFFFD700), // Gold
        prosperity: Color(0xFF00FF00), // Green
      ),
      culturalNumbers: CulturalNumbers(
        lucky: [7],
        unlucky: [13],
      ),
      holidays: [
        Holiday('New Year\'s Day', 'January 1'),
        Holiday('Epiphany', 'January 6'),
        Holiday('Good Friday', 'March 29'), // Varies
        Holiday('Easter Monday', 'April 1'), // Varies
        Holiday('Labor Day', 'May 1'),
        Holiday('Assumption of Mary', 'August 15'),
        Holiday('National Day', 'October 12'),
        Holiday('All Saints\' Day', 'November 1'),
        Holiday('Constitution Day', 'December 6'),
        Holiday('Immaculate Conception', 'December 8'),
        Holiday('Christmas Day', 'December 25'),
      ],
    ),
    'ar': const RegionalConfig(
      locale: Locale('ar'),
      currency: 'SAR',
      currencySymbol: 'ر.س',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: 'HH:mm',
      firstDayOfWeek: DateTime.saturday, // Week starts on Saturday in many Arab countries
      culturalColors: CulturalColors(
        lucky: Color(0xFF00FF00), // Green is sacred in Islam
        unlucky: Color(0xFF000000), // Black
        celebration: Color(0xFFFFD700), // Gold
        prosperity: Color(0xFF00FF00), // Green
      ),
      culturalNumbers: CulturalNumbers(
        lucky: [7, 3], // 7 is mentioned in Quran, 3 is also significant
        unlucky: [],
      ),
      holidays: [
        Holiday('New Year\'s Day', 'January 1'),
        Holiday('Eid al-Fitr', 'April 10'), // Varies by lunar calendar
        Holiday('Eid al-Adha', 'June 16'), // Varies by lunar calendar
        Holiday('Islamic New Year', 'July 7'), // Varies by lunar calendar
        Holiday('Prophet\'s Birthday', 'September 15'), // Varies by lunar calendar
        Holiday('National Day', 'September 23'), // Saudi National Day
      ],
    ),
  };

  /// Get regional configuration for a locale
  static RegionalConfig getRegionalConfig(Locale locale) {
    return _regionalConfigs[locale.languageCode] ?? 
           _regionalConfigs['en']!;
  }

  /// Format currency according to regional settings
  static String formatCurrency(double amount, Locale locale) {
    final config = getRegionalConfig(locale);
    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: config.currencySymbol,
      name: config.currency,
    );
    return formatter.format(amount);
  }

  /// Format date according to regional settings
  static String formatDate(DateTime date, Locale locale) {
    final config = getRegionalConfig(locale);
    final formatter = DateFormat(config.dateFormat, locale.toString());
    return formatter.format(date);
  }

  /// Format time according to regional settings
  static String formatTime(DateTime time, Locale locale) {
    final config = getRegionalConfig(locale);
    final formatter = DateFormat(config.timeFormat, locale.toString());
    return formatter.format(time);
  }

  /// Check if a date is a holiday
  static bool isHoliday(DateTime date, Locale locale) {
    final config = getRegionalConfig(locale);
    return config.holidays.any((holiday) {
      final holidayDate = holiday.getDateForYear(date.year);
      return holidayDate.year == date.year &&
             holidayDate.month == date.month &&
             holidayDate.day == date.day;
    });
  }

  /// Get holidays for a specific year
  static List<Holiday> getHolidays(int year, Locale locale) {
    final config = getRegionalConfig(locale);
    return config.holidays;
  }

  /// Get culturally appropriate color for a concept
  static Color getCulturalColor(String concept, Locale locale) {
    final config = getRegionalConfig(locale);
    switch (concept.toLowerCase()) {
      case 'lucky':
        return config.culturalColors.lucky;
      case 'unlucky':
        return config.culturalColors.unlucky;
      case 'celebration':
        return config.culturalColors.celebration;
      case 'prosperity':
        return config.culturalColors.prosperity;
      default:
        return config.culturalColors.celebration;
    }
  }

  /// Check if a number is considered lucky in the culture
  static bool isLuckyNumber(int number, Locale locale) {
    final config = getRegionalConfig(locale);
    return config.culturalNumbers.lucky.contains(number);
  }

  /// Check if a number is considered unlucky in the culture
  static bool isUnluckyNumber(int number, Locale locale) {
    final config = getRegionalConfig(locale);
    return config.culturalNumbers.unlucky.contains(number);
  }

  /// Get the first day of week for the locale
  static int getFirstDayOfWeek(Locale locale) {
    final config = getRegionalConfig(locale);
    return config.firstDayOfWeek;
  }

  /// Get timezone offset for common regions
  static Duration getTimezoneOffset(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return const Duration(hours: 9); // JST
      case 'zh':
        return const Duration(hours: 8); // CST
      case 'ko':
        return const Duration(hours: 9); // KST
      case 'ar':
        return const Duration(hours: 3); // AST (Saudi Arabia)
      case 'es':
        return const Duration(hours: 1); // CET (Spain)
      default:
        return Duration.zero; // UTC
    }
  }

  /// Get appropriate greeting based on time and culture
  static String getCulturalGreeting(DateTime time, Locale locale) {
    final hour = time.hour;
    
    switch (locale.languageCode) {
      case 'ja':
        if (hour < 10) return 'おはようございます';
        if (hour < 18) return 'こんにちは';
        return 'こんばんは';
      case 'zh':
        if (hour < 9) return '早上好';
        if (hour < 12) return '上午好';
        if (hour < 18) return '下午好';
        return '晚上好';
      case 'ko':
        if (hour < 10) return '좋은 아침입니다';
        if (hour < 18) return '안녕하세요';
        return '좋은 저녁입니다';
      case 'ar':
        if (hour < 12) return 'صباح الخير';
        if (hour < 18) return 'مساء الخير';
        return 'مساء الخير';
      case 'es':
        if (hour < 12) return 'Buenos días';
        if (hour < 20) return 'Buenas tardes';
        return 'Buenas noches';
      default:
        if (hour < 12) return 'Good morning';
        if (hour < 18) return 'Good afternoon';
        return 'Good evening';
    }
  }
}

class RegionalConfig {
  const RegionalConfig({
    required this.locale,
    required this.currency,
    required this.currencySymbol,
    required this.dateFormat,
    required this.timeFormat,
    required this.firstDayOfWeek,
    required this.culturalColors,
    required this.culturalNumbers,
    required this.holidays,
  });

  final Locale locale;
  final String currency;
  final String currencySymbol;
  final String dateFormat;
  final String timeFormat;
  final int firstDayOfWeek;
  final CulturalColors culturalColors;
  final CulturalNumbers culturalNumbers;
  final List<Holiday> holidays;
}

class CulturalColors {
  const CulturalColors({
    required this.lucky,
    required this.unlucky,
    required this.celebration,
    required this.prosperity,
  });

  final Color lucky;
  final Color unlucky;
  final Color celebration;
  final Color prosperity;
}

class CulturalNumbers {
  const CulturalNumbers({
    required this.lucky,
    required this.unlucky,
  });

  final List<int> lucky;
  final List<int> unlucky;
}

class Holiday {
  const Holiday(this.name, this.dateDescription);

  final String name;
  final String dateDescription;
  
  DateTime getDateForYear(int year) {
    // Simplified implementation for common date patterns
    switch (dateDescription) {
      // Fixed dates
      case 'January 1':
        return DateTime(year, 1, 1);
      case 'January 6':
        return DateTime(year, 1, 6);
      case 'February 11':
        return DateTime(year, 2, 11);
      case 'February 23':
        return DateTime(year, 2, 23);
      case 'March 1':
        return DateTime(year, 3, 1);
      case 'March 20':
        return DateTime(year, 3, 20);
      case 'March 29':
        return DateTime(year, 3, 29);
      case 'April 1':
        return DateTime(year, 4, 1);
      case 'April 4':
        return DateTime(year, 4, 4);
      case 'April 10':
        return DateTime(year, 4, 10);
      case 'April 29':
        return DateTime(year, 4, 29);
      case 'May 1':
        return DateTime(year, 5, 1);
      case 'May 3':
        return DateTime(year, 5, 3);
      case 'May 4':
        return DateTime(year, 5, 4);
      case 'May 5':
        return DateTime(year, 5, 5);
      case 'May 15':
        return DateTime(year, 5, 15);
      case 'June 6':
        return DateTime(year, 6, 6);
      case 'June 10':
        return DateTime(year, 6, 10);
      case 'June 16':
        return DateTime(year, 6, 16);
      case 'July 4':
        return DateTime(year, 7, 4);
      case 'July 7':
        return DateTime(year, 7, 7);
      case 'August 11':
        return DateTime(year, 8, 11);
      case 'August 15':
        return DateTime(year, 8, 15);
      case 'September 15':
        return DateTime(year, 9, 15);
      case 'September 17':
        return DateTime(year, 9, 17);
      case 'September 22':
        return DateTime(year, 9, 22);
      case 'September 23':
        return DateTime(year, 9, 23);
      case 'October 1':
        return DateTime(year, 10, 1);
      case 'October 3':
        return DateTime(year, 10, 3);
      case 'October 9':
        return DateTime(year, 10, 9);
      case 'October 12':
        return DateTime(year, 10, 12);
      case 'November 1':
        return DateTime(year, 11, 1);
      case 'November 3':
        return DateTime(year, 11, 3);
      case 'November 11':
        return DateTime(year, 11, 11);
      case 'November 23':
        return DateTime(year, 11, 23);
      case 'November 28':
        return DateTime(year, 11, 28);
      case 'December 6':
        return DateTime(year, 12, 6);
      case 'December 8':
        return DateTime(year, 12, 8);
      case 'December 25':
        return DateTime(year, 12, 25);
      // For complex dates like "Third Monday of January", return approximate dates
      case 'Second Monday of January':
        return DateTime(year, 1, 8);
      case 'Third Monday of January':
        return DateTime(year, 1, 15);
      case 'Third Monday of February':
        return DateTime(year, 2, 19);
      case 'Last Monday of May':
        return DateTime(year, 5, 27);
      case 'First Monday of September':
        return DateTime(year, 9, 2);
      case 'Second Monday of October':
        return DateTime(year, 10, 14);
      case 'Third Monday of July':
        return DateTime(year, 7, 15);
      case 'Third Monday of September':
        return DateTime(year, 9, 16);
      case 'Fourth Thursday of November':
        return DateTime(year, 11, 28);
      default:
        return DateTime(year, 1, 1);
    }
  }
}