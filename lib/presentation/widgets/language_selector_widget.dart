import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/i18n/cultural_adaptation_service.dart';
import 'package:minq/core/i18n/regional_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({super.key});

  Widget _buildRegionalInfo(Locale locale) {
    final config = RegionalService.getRegionalConfig(locale);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MinqTokens.spacing(1),
        vertical: MinqTokens.spacing(0.5),
      ),
      decoration: BoxDecoration(
        color: MinqTokens.textSecondary.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config.currencySymbol,
        style: MinqTokens.bodySmall.copyWith(
          color: MinqTokens.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getLanguageChangeInfo(BuildContext context, Locale? currentLocale) {
    final l10n = AppLocalizations.of(context);

    switch (currentLocale?.languageCode) {
      case 'ja':
        return '言語を変更すると、アプリ全体の表示言語、日付形式、通貨表示が即座に切り替わります。';
      case 'zh':
        return '更改语言将立即切换整个应用的显示语言、日期格式和货币显示。';
      case 'ko':
        return '언어를 변경하면 앱 전체의 표시 언어, 날짜 형식, 통화 표시가 즉시 전환됩니다.';
      case 'ar':
        return 'تغيير اللغة سيؤدي إلى تبديل لغة العرض وتنسيق التاريخ وعرض العملة في التطبيق بأكمله فوراً.';
      case 'es':
        return 'Cambiar el idioma actualizará inmediatamente el idioma de visualización, formato de fecha y moneda en toda la aplicación.';
      default:
        return 'Changing the language will immediately update the display language, date format, and currency throughout the app.';
    }
  }

  Widget _buildRegionalPreview(Locale locale) {
    final config = RegionalService.getRegionalConfig(locale);
    final now = DateTime.now();
    const sampleAmount = 1234.56;

    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(3)),
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: MinqTokens.cornerSmall(),
        border: Border.all(
          color: MinqTokens.textSecondary.withAlpha((255 * 0.2).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview:',
            style: MinqTokens.bodySmall.copyWith(
              color: MinqTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: MinqTokens.spacing(1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date:',
                style: MinqTokens.bodySmall.copyWith(
                  color: MinqTokens.textSecondary,
                ),
              ),
              Text(
                RegionalService.formatDate(now, locale),
                style: MinqTokens.bodySmall.copyWith(
                  color: MinqTokens.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: MinqTokens.spacing(0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Currency:',
                style: MinqTokens.bodySmall.copyWith(
                  color: MinqTokens.textSecondary,
                ),
              ),
              Text(
                RegionalService.formatCurrency(sampleAmount, locale),
                style: MinqTokens.bodySmall.copyWith(
                  color: MinqTokens.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: MinqTokens.spacing(0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Greeting:',
                style: MinqTokens.bodySmall.copyWith(
                  color: MinqTokens.textSecondary,
                ),
              ),
              Text(
                CulturalAdaptationService.getTimeBasedGreeting(now, locale),
                style: MinqTokens.bodySmall.copyWith(
                  color: MinqTokens.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final controller = ref.read(appLocaleControllerProvider.notifier);
    final availableLocales = controller.getAvailableLocales();

    return Card(
      margin: EdgeInsets.all(MinqTokens.spacing(4)),
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: MinqTokens.brandPrimary, size: 24),
                SizedBox(width: MinqTokens.spacing(2)),
                Text(
                  AppLocalizations.of(context).languageSettings ??
                      'Language Settings',
                  style: MinqTokens.titleMedium,
                ),
              ],
            ),
            SizedBox(height: MinqTokens.spacing(4)),
            ...availableLocales.map((option) {
              final isSelected = currentLocale == option.locale;
              return Padding(
                padding: EdgeInsets.only(bottom: MinqTokens.spacing(1)),
                child: InkWell(
                  onTap: () => controller.setLocale(option.locale),
                  borderRadius: MinqTokens.cornerMedium(),
                  child: Container(
                    padding: EdgeInsets.all(MinqTokens.spacing(4)),
                    decoration: BoxDecoration(
                      borderRadius: MinqTokens.cornerMedium(),
                      border: Border.all(
                        color:
                            isSelected
                                ? MinqTokens.brandPrimary
                                : MinqTokens
                                    .textSecondary, // Substituted outline
                        width: isSelected ? 2 : 1,
                      ),
                      color:
                          isSelected
                              ? MinqTokens.brandPrimary.withAlpha(
                                (255 * 0.1).round(),
                              )
                              : null,
                    ),
                    child: Row(
                      children: [
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: MinqTokens.brandPrimary,
                            size: 20,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            color: MinqTokens.textSecondary,
                            size: 20,
                          ),
                        SizedBox(width: MinqTokens.spacing(2)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    option.nativeName,
                                    style: MinqTokens.bodyMedium.copyWith(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? MinqTokens.brandPrimary
                                              : MinqTokens.textPrimary,
                                    ),
                                  ),
                                  if (option.isRTL) ...[
                                    SizedBox(width: MinqTokens.spacing(1)),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: MinqTokens.spacing(1),
                                        vertical: MinqTokens.spacing(0.5),
                                      ),
                                      decoration: BoxDecoration(
                                        color: MinqTokens.brandPrimary
                                            .withAlpha((255 * 0.2).round()),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'RTL',
                                        style: MinqTokens.bodySmall.copyWith(
                                          color: MinqTokens.brandPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                  // Show regional info
                                  SizedBox(width: MinqTokens.spacing(1)),
                                  _buildRegionalInfo(option.locale),
                                ],
                              ),
                              if (option.displayName != option.nativeName)
                                Text(
                                  option.displayName,
                                  style: MinqTokens.bodySmall.copyWith(
                                    color: MinqTokens.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: MinqTokens.spacing(4)),
            Container(
              padding: EdgeInsets.all(MinqTokens.spacing(4)),
              decoration: BoxDecoration(
                color: MinqTokens.background, // Substituted surfaceVariant
                borderRadius: MinqTokens.cornerMedium(),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: MinqTokens.brandPrimary,
                        size: 16,
                      ),
                      SizedBox(width: MinqTokens.spacing(2)),
                      Expanded(
                        child: Text(
                          _getLanguageChangeInfo(context, currentLocale),
                          style: MinqTokens.bodySmall.copyWith(
                            color: MinqTokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (currentLocale != null) ...[
                    SizedBox(height: MinqTokens.spacing(2)),
                    _buildRegionalPreview(currentLocale),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick language toggle button for easy switching
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final controller = ref.read(appLocaleControllerProvider.notifier);

    return IconButton(
      onPressed: () => controller.switchToNextLocale(),
      icon: const Icon(Icons.language),
      tooltip:
          currentLocale?.languageCode == 'ja' ? '言語を切り替え' : 'Switch Language',
      style: IconButton.styleFrom(
        backgroundColor: MinqTokens.background, // Substituted surfaceVariant
        foregroundColor: MinqTokens.brandPrimary,
      ),
    );
  }
}

/// Language selector for bottom sheet or dialog
class LanguageSelectorBottomSheet extends ConsumerWidget {
  const LanguageSelectorBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final controller = ref.read(appLocaleControllerProvider.notifier);
    final availableLocales = controller.getAvailableLocales();

    return Container(
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16), // Hardcoded value for lg radius
        ),
      ),
      padding: EdgeInsets.all(MinqTokens.spacing(6)), // lg spacing
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MinqTokens.textSecondary, // Substituted outline
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: MinqTokens.spacing(6)),

            // Title
            Text('Language / 言語', style: MinqTokens.titleLarge),
            SizedBox(height: MinqTokens.spacing(4)),

            // Language options
            ...availableLocales.map((option) {
              final isSelected = currentLocale == option.locale;
              return Padding(
                padding: EdgeInsets.only(bottom: MinqTokens.spacing(2)),
                child: ListTile(
                  onTap: () {
                    controller.setLocale(option.locale);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color:
                        isSelected
                            ? MinqTokens.brandPrimary
                            : MinqTokens.textSecondary,
                  ),
                  title: Text(
                    option.nativeName,
                    style: MinqTokens.bodyMedium.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected
                              ? MinqTokens.brandPrimary
                              : MinqTokens.textPrimary,
                    ),
                  ),
                  subtitle:
                      option.displayName != option.nativeName
                          ? Text(
                            option.displayName,
                            style: MinqTokens.bodySmall.copyWith(
                              color: MinqTokens.textSecondary,
                            ),
                          )
                          : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: MinqTokens.cornerMedium(),
                  ),
                  tileColor:
                      isSelected
                          ? MinqTokens.brandPrimary.withAlpha(
                            (255 * 0.1).round(),
                          )
                          : null,
                ),
              );
            }),

            SizedBox(height: MinqTokens.spacing(6)),
          ],
        ),
      ),
    );
  }
}
