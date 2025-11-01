import 'package:intl/intl.dart';
import 'package:minq/l10n/app_localizations.dart';

extension LocalizationFormatters on AppLocalizations {
  /// Formats a DateTime into a localized string, e.g., "2023年10月28日" or "October 28, 2023".
  String formatDate(DateTime date) {
    // The locale property of AppLocalizations tells us the current language.
    final format = DateFormat.yMMMMd(localeName);
    return format.format(date);
  }

  /// Formats a number with grouping separators, e.g., "1,234,567".
  String formatNumber(num number) {
    final format = NumberFormat.decimalPattern(localeName);
    return format.format(number);
  }
}
