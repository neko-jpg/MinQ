import 'package:flutter/material.dart';

/// Widget that provides RTL (Right-to-Left) support and cultural adaptations
class RTLSupportWidget extends StatelessWidget {
  final Widget child;

  const RTLSupportWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = _isRTLLanguage(locale.languageCode);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }

  /// Check if the language code is RTL
  static bool _isRTLLanguage(String languageCode) {
    const rtlLanguages = {
      'ar', // Arabic
      'he', // Hebrew
      'fa', // Persian/Farsi
      'ur', // Urdu
      'ku', // Kurdish
      'dv', // Dhivehi
      'ps', // Pashto
      'sd', // Sindhi
    };
    return rtlLanguages.contains(languageCode);
  }

  /// Get text direction for the current locale
  static TextDirection getTextDirection(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return _isRTLLanguage(locale.languageCode) 
      ? TextDirection.rtl 
      : TextDirection.ltr;
  }

  /// Check if current locale is RTL
  static bool isRTL(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return _isRTLLanguage(locale.languageCode);
  }
}

/// Extension to provide RTL-aware padding and margins
extension RTLAwareEdgeInsets on EdgeInsets {
  /// Create RTL-aware horizontal padding
  static EdgeInsets horizontalRTL(BuildContext context, double value) {
    return RTLSupportWidget.isRTL(context)
      ? EdgeInsets.only(right: value)
      : EdgeInsets.only(left: value);
  }

  /// Create RTL-aware start padding (left in LTR, right in RTL)
  static EdgeInsets startRTL(BuildContext context, double value) {
    return RTLSupportWidget.isRTL(context)
      ? EdgeInsets.only(right: value)
      : EdgeInsets.only(left: value);
  }

  /// Create RTL-aware end padding (right in LTR, left in RTL)
  static EdgeInsets endRTL(BuildContext context, double value) {
    return RTLSupportWidget.isRTL(context)
      ? EdgeInsets.only(left: value)
      : EdgeInsets.only(right: value);
  }
}

/// Extension to provide RTL-aware alignment
extension RTLAwareAlignment on Alignment {
  /// Get start alignment (left in LTR, right in RTL)
  static Alignment start(BuildContext context) {
    return RTLSupportWidget.isRTL(context)
      ? Alignment.centerRight
      : Alignment.centerLeft;
  }

  /// Get end alignment (right in LTR, left in RTL)
  static Alignment end(BuildContext context) {
    return RTLSupportWidget.isRTL(context)
      ? Alignment.centerLeft
      : Alignment.centerRight;
  }
}

/// Extension to provide RTL-aware cross axis alignment
extension RTLAwareCrossAxisAlignment on CrossAxisAlignment {
  /// Get start cross axis alignment
  static CrossAxisAlignment start(BuildContext context) {
    return RTLSupportWidget.isRTL(context)
      ? CrossAxisAlignment.end
      : CrossAxisAlignment.start;
  }

  /// Get end cross axis alignment
  static CrossAxisAlignment end(BuildContext context) {
    return RTLSupportWidget.isRTL(context)
      ? CrossAxisAlignment.start
      : CrossAxisAlignment.end;
  }
}

/// Extension to provide RTL-aware main axis alignment
extension RTLAwareMainAxisAlignment on MainAxisAlignment {
  /// Get start main axis alignment
  static MainAxisAlignment start(BuildContext context) {
    return RTLSupportWidget.isRTL(context)
      ? MainAxisAlignment.end
      : MainAxisAlignment.start;
  }

  /// Get end main axis alignment
  static MainAxisAlignment end(BuildContext context) {
    return RTLSupportWidget.isRTL(context)
      ? MainAxisAlignment.start
      : MainAxisAlignment.end;
  }
}

/// Cultural adaptations for different locales
class CulturalAdaptations {
  /// Get culturally appropriate date format
  static String getDateFormat(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ar':
        return 'dd/MM/yyyy'; // Arabic prefers day/month/year
      case 'ja':
        return 'yyyy年MM月dd日'; // Japanese format
      case 'en':
      default:
        return 'MM/dd/yyyy'; // US format
    }
  }

  /// Get culturally appropriate time format
  static String getTimeFormat(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ar':
      case 'ja':
        return 'HH:mm'; // 24-hour format
      case 'en':
      default:
        return 'h:mm a'; // 12-hour format with AM/PM
    }
  }

  /// Get culturally appropriate number format
  static String formatNumber(BuildContext context, num number) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'ar':
        // Arabic uses Arabic-Indic numerals in some contexts
        return number.toString();
      case 'ja':
        // Japanese may use different separators
        return number.toString();
      case 'en':
      default:
        // English uses comma separators for thousands
        return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    }
  }

  /// Get reading direction for the current locale
  static TextDirection getReadingDirection(BuildContext context) {
    return RTLSupportWidget.getTextDirection(context);
  }

  /// Get appropriate icon for the locale (e.g., back arrow)
  static IconData getBackIcon(BuildContext context) {
    return RTLSupportWidget.isRTL(context)
      ? Icons.arrow_forward_ios
      : Icons.arrow_back_ios;
  }

  /// Get appropriate icon for forward navigation
  static IconData getForwardIcon(BuildContext context) {
    return RTLSupportWidget.isRTL(context)
      ? Icons.arrow_back_ios
      : Icons.arrow_forward_ios;
  }
}

/// Widget that automatically adapts layout for RTL
class RTLAwareRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const RTLAwareRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLSupportWidget.isRTL(context);
    
    return Row(
      mainAxisAlignment: _adaptMainAxisAlignment(mainAxisAlignment, isRTL),
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: isRTL ? children.reversed.toList() : children,
    );
  }

  MainAxisAlignment _adaptMainAxisAlignment(
    MainAxisAlignment alignment,
    bool isRTL,
  ) {
    if (!isRTL) return alignment;
    
    switch (alignment) {
      case MainAxisAlignment.start:
        return MainAxisAlignment.end;
      case MainAxisAlignment.end:
        return MainAxisAlignment.start;
      case MainAxisAlignment.spaceBetween:
      case MainAxisAlignment.spaceAround:
      case MainAxisAlignment.spaceEvenly:
      case MainAxisAlignment.center:
        return alignment;
    }
  }
}

/// Widget that provides RTL-aware padding
class RTLAwarePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RTLAwarePadding({
    super.key,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLSupportWidget.isRTL(context);
    
    EdgeInsetsGeometry adaptedPadding = padding;
    if (isRTL && padding is EdgeInsets) {
      final edgeInsets = padding as EdgeInsets;
      adaptedPadding = EdgeInsets.only(
        top: edgeInsets.top,
        bottom: edgeInsets.bottom,
        left: edgeInsets.right,
        right: edgeInsets.left,
      );
    }

    return Padding(
      padding: adaptedPadding,
      child: child,
    );
  }
}