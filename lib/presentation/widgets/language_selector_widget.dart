import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/app_locale_controller.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final controller = ref.read(appLocaleControllerProvider.notifier);
    final availableLocales = controller.getAvailableLocales();

    return Card(
      margin: EdgeInsets.all(tokens.spacing.md),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: tokens.primary,
                  size: 24,
                ),
                SizedBox(width: tokens.spacing.sm),
                Text(
                  'Language / 言語',
                  style: tokens.typography.h3,
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.md),
            ...availableLocales.map((option) {
              final isSelected = currentLocale == option.locale;
              return Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.xs),
                child: InkWell(
                  onTap: () => controller.setLocale(option.locale),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                  child: Container(
                    padding: EdgeInsets.all(tokens.spacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                      border: Border.all(
                        color: isSelected ? tokens.primary : tokens.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected 
                        ? tokens.primary.withAlpha((255 * 0.1).round())
                        : null,
                    ),
                    child: Row(
                      children: [
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: tokens.primary,
                            size: 20,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            color: tokens.textSecondary,
                            size: 20,
                          ),
                        SizedBox(width: tokens.spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.nativeName,
                                style: tokens.typography.body.copyWith(
                                  fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                  color: isSelected 
                                    ? tokens.primary 
                                    : tokens.textPrimary,
                                ),
                              ),
                              if (option.displayName != option.nativeName)
                                Text(
                                  option.displayName,
                                  style: tokens.typography.caption.copyWith(
                                    color: tokens.textSecondary,
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
            SizedBox(height: tokens.spacing.md),
            Container(
              padding: EdgeInsets.all(tokens.spacing.md),
              decoration: BoxDecoration(
                color: tokens.surfaceVariant,
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: tokens.primary,
                    size: 16,
                  ),
                  SizedBox(width: tokens.spacing.sm),
                  Expanded(
                    child: Text(
                      currentLocale?.languageCode == 'ja'
                        ? '言語を変更すると、アプリ全体の表示言語が即座に切り替わります。'
                        : 'Changing the language will immediately switch the display language throughout the app.',
                      style: tokens.typography.caption.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ),
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
    final tokens = context.tokens;
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final controller = ref.read(appLocaleControllerProvider.notifier);

    return IconButton(
      onPressed: () => controller.switchToNextLocale(),
      icon: Icon(Icons.language),
      tooltip: currentLocale?.languageCode == 'ja' 
        ? '言語を切り替え' 
        : 'Switch Language',
      style: IconButton.styleFrom(
        backgroundColor: tokens.surfaceVariant,
        foregroundColor: tokens.primary,
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
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final controller = ref.read(appLocaleControllerProvider.notifier);
    final availableLocales = controller.getAvailableLocales();

    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radius.lg),
        ),
      ),
      padding: EdgeInsets.all(tokens.spacing.lg),
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
                  color: tokens.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            
            // Title
            Text(
              'Language / 言語',
              style: tokens.typography.h2,
            ),
            SizedBox(height: tokens.spacing.md),
            
            // Language options
            ...availableLocales.map((option) {
              final isSelected = currentLocale == option.locale;
              return Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                child: ListTile(
                  onTap: () {
                    controller.setLocale(option.locale);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? tokens.primary : tokens.textSecondary,
                  ),
                  title: Text(
                    option.nativeName,
                    style: tokens.typography.body.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? tokens.primary : tokens.textPrimary,
                    ),
                  ),
                  subtitle: option.displayName != option.nativeName
                    ? Text(
                        option.displayName,
                        style: tokens.typography.caption.copyWith(
                          color: tokens.textSecondary,
                        ),
                      )
                    : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                  tileColor: isSelected 
                    ? tokens.primary.withAlpha((255 * 0.1).round())
                    : null,
                ),
              );
            }),
            
            SizedBox(height: tokens.spacing.lg),
          ],
        ),
      ),
    );
  }
}