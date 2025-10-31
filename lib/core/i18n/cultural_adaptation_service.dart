import 'package:flutter/material.dart';
import 'package:minq/core/i18n/regional_service.dart';

/// Service for cultural adaptations and considerations
class CulturalAdaptationService {
  
  /// Get culturally appropriate motivational messages
  static List<String> getMotivationalMessages(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return [
          '頑張って！', // Ganbatte! (Do your best!)
          '一歩一歩', // Ippou ippou (Step by step)
          '継続は力なり', // Keizoku wa chikara nari (Persistence is strength)
          '今日も一日お疲れ様', // Kyou mo ichinichi otsukaresama (Good work today too)
          '小さな積み重ねが大きな成果に', // Small accumulations lead to big results
        ];
      case 'zh':
        return [
          '加油！', // Jiayou! (Add oil/Keep going!)
          '坚持就是胜利', // Persistence is victory
          '一步一个脚印', // One step at a time
          '今天也要加油', // Keep going today too
          '积少成多', // Little by little makes a lot
        ];
      case 'ko':
        return [
          '화이팅！', // Fighting! (You can do it!)
          '꾸준히 하면 된다', // If you do it steadily, you can do it
          '오늘도 수고했어요', // You worked hard today too
          '한 걸음씩', // One step at a time
          '작은 것부터 시작', // Start with small things
        ];
      case 'ar':
        return [
          'بالتوفيق!', // Good luck!
          'خطوة بخطوة', // Step by step
          'الصبر مفتاح الفرج', // Patience is the key to relief
          'استمر في المحاولة', // Keep trying
          'النجاح يحتاج صبر', // Success needs patience
        ];
      case 'es':
        return [
          '¡Tú puedes!', // You can do it!
          'Paso a paso', // Step by step
          'La constancia es la clave', // Consistency is the key
          'Sigue adelante', // Keep going
          'Cada día cuenta', // Every day counts
        ];
      default:
        return [
          'You can do it!',
          'Keep going!',
          'One step at a time',
          'Stay consistent',
          'Every day matters',
        ];
    }
  }

  /// Get culturally appropriate celebration messages
  static List<String> getCelebrationMessages(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return [
          'おめでとうございます！', // Congratulations!
          'よくできました！', // Well done!
          'すばらしい！', // Wonderful!
          '達成おめでとう！', // Congratulations on your achievement!
          'お疲れ様でした！', // Thank you for your hard work!
        ];
      case 'zh':
        return [
          '恭喜！', // Congratulations!
          '太棒了！', // Awesome!
          '做得好！', // Well done!
          '成功了！', // Success!
          '继续保持！', // Keep it up!
        ];
      case 'ko':
        return [
          '축하합니다！', // Congratulations!
          '잘했어요！', // Well done!
          '대단해요！', // Amazing!
          '성공했네요！', // You succeeded!
          '계속 화이팅！', // Keep fighting!
        ];
      case 'ar':
        return [
          'مبروك!', // Congratulations!
          'أحسنت!', // Well done!
          'ممتاز!', // Excellent!
          'نجحت!', // You succeeded!
          'واصل التقدم!', // Keep progressing!
        ];
      case 'es':
        return [
          '¡Felicidades!', // Congratulations!
          '¡Bien hecho!', // Well done!
          '¡Excelente!', // Excellent!
          '¡Lo lograste!', // You did it!
          '¡Sigue así!', // Keep it up!
        ];
      default:
        return [
          'Congratulations!',
          'Well done!',
          'Excellent!',
          'You did it!',
          'Keep it up!',
        ];
    }
  }

  /// Get culturally appropriate time-based greetings
  static String getTimeBasedGreeting(DateTime time, Locale locale) {
    return RegionalService.getCulturalGreeting(time, locale);
  }

  /// Get culturally appropriate icons for concepts
  static IconData getCulturalIcon(String concept, Locale locale) {
    switch (concept.toLowerCase()) {
      case 'luck':
      case 'fortune':
        switch (locale.languageCode) {
          case 'ja':
            return Icons.star; // Star for luck
          case 'zh':
            return Icons.favorite; // Heart/love symbol
          case 'ar':
            return Icons.brightness_7; // Sun symbol
          default:
            return Icons.auto_awesome;
        }
      case 'money':
      case 'wealth':
        switch (locale.languageCode) {
          case 'ja':
          case 'zh':
            return Icons.monetization_on; // Coin symbol
          case 'ar':
            return Icons.diamond; // Diamond for wealth
          default:
            return Icons.attach_money;
        }
      case 'health':
        return Icons.favorite; // Universal heart symbol
      case 'family':
        return Icons.family_restroom;
      case 'education':
        return Icons.school;
      case 'work':
        return Icons.work;
      default:
        return Icons.star;
    }
  }

  /// Get culturally appropriate color schemes
  static ColorScheme getCulturalColorScheme(Locale locale, Brightness brightness) {
    final config = RegionalService.getRegionalConfig(locale);
    
    if (brightness == Brightness.dark) {
      return ColorScheme.dark(
        primary: config.culturalColors.prosperity,
        secondary: config.culturalColors.celebration,
        tertiary: config.culturalColors.lucky,
      );
    } else {
      return ColorScheme.light(
        primary: config.culturalColors.prosperity,
        secondary: config.culturalColors.celebration,
        tertiary: config.culturalColors.lucky,
      );
    }
  }

  /// Get culturally appropriate number formatting
  static String formatNumber(int number, Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        // Japanese uses 万 (man) for 10,000
        if (number >= 10000) {
          final man = number ~/ 10000;
          final remainder = number % 10000;
          if (remainder == 0) {
            return '$man万';
          } else {
            return '$man万$remainder';
          }
        }
        return number.toString();
      case 'zh':
        // Chinese also uses 万 for 10,000
        if (number >= 10000) {
          final wan = number ~/ 10000;
          final remainder = number % 10000;
          if (remainder == 0) {
            return '$wan万';
          } else {
            return '$wan万$remainder';
          }
        }
        return number.toString();
      case 'ar':
        // Arabic uses different number formatting
        return _formatArabicNumber(number);
      default:
        // Western formatting with commas
        return _formatWesternNumber(number);
    }
  }

  /// Get culturally appropriate achievement titles
  static String getAchievementTitle(String achievementType, int level, Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        switch (achievementType) {
          case 'streak':
            return '連続達成 $level日';
          case 'completion':
            return '完了マスター Lv.$level';
          case 'consistency':
            return '継続の達人 Lv.$level';
          default:
            return '実績 Lv.$level';
        }
      case 'zh':
        switch (achievementType) {
          case 'streak':
            return '连续$level天';
          case 'completion':
            return '完成大师 Lv.$level';
          case 'consistency':
            return '坚持达人 Lv.$level';
          default:
            return '成就 Lv.$level';
        }
      case 'ko':
        switch (achievementType) {
          case 'streak':
            return '연속 $level일';
          case 'completion':
            return '완료 마스터 Lv.$level';
          case 'consistency':
            return '꾸준함의 달인 Lv.$level';
          default:
            return '업적 Lv.$level';
        }
      case 'ar':
        switch (achievementType) {
          case 'streak':
            return 'سلسلة $level أيام';
          case 'completion':
            return 'خبير الإنجاز المستوى $level';
          case 'consistency':
            return 'محترف الثبات المستوى $level';
          default:
            return 'إنجاز المستوى $level';
        }
      case 'es':
        switch (achievementType) {
          case 'streak':
            return 'Racha de $level días';
          case 'completion':
            return 'Maestro de Completación Nv.$level';
          case 'consistency':
            return 'Experto en Consistencia Nv.$level';
          default:
            return 'Logro Nv.$level';
        }
      default:
        switch (achievementType) {
          case 'streak':
            return '$level Day Streak';
          case 'completion':
            return 'Completion Master Lv.$level';
          case 'consistency':
            return 'Consistency Expert Lv.$level';
          default:
            return 'Achievement Lv.$level';
        }
    }
  }

  /// Get culturally appropriate difficulty labels
  static List<String> getDifficultyLabels(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return ['簡単', '普通', '難しい', '非常に難しい'];
      case 'zh':
        return ['简单', '普通', '困难', '非常困难'];
      case 'ko':
        return ['쉬움', '보통', '어려움', '매우 어려움'];
      case 'ar':
        return ['سهل', 'متوسط', 'صعب', 'صعب جداً'];
      case 'es':
        return ['Fácil', 'Normal', 'Difícil', 'Muy Difícil'];
      default:
        return ['Easy', 'Normal', 'Hard', 'Very Hard'];
    }
  }

  /// Get culturally appropriate priority labels
  static List<String> getPriorityLabels(Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return ['低', '中', '高', '緊急'];
      case 'zh':
        return ['低', '中', '高', '紧急'];
      case 'ko':
        return ['낮음', '보통', '높음', '긴급'];
      case 'ar':
        return ['منخفض', 'متوسط', 'عالي', 'عاجل'];
      case 'es':
        return ['Baja', 'Media', 'Alta', 'Urgente'];
      default:
        return ['Low', 'Medium', 'High', 'Urgent'];
    }
  }

  static String _formatArabicNumber(int number) {
    // Arabic number formatting (right-to-left)
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final western = number.toString();
    return western.split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? arabicDigits[index] : digit;
    }).join('');
  }

  static String _formatWesternNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    
    return buffer.toString();
  }

  /// Check if content should be mirrored for RTL languages
  static bool shouldMirrorContent(Locale locale) {
    return locale.languageCode == 'ar';
  }

  /// Get appropriate text alignment for locale
  static TextAlign getTextAlignment(Locale locale) {
    return locale.languageCode == 'ar' ? TextAlign.right : TextAlign.left;
  }

  /// Get appropriate edge insets for locale (considering RTL)
  static EdgeInsets getDirectionalPadding(Locale locale, {
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    if (locale.languageCode == 'ar') {
      // RTL: swap start and end
      return EdgeInsets.only(
        left: end,
        top: top,
        right: start,
        bottom: bottom,
      );
    } else {
      // LTR: normal
      return EdgeInsets.only(
        left: start,
        top: top,
        right: end,
        bottom: bottom,
      );
    }
  }
}