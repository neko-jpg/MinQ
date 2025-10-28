import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({super.key});

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
                const Icon(
                  Icons.language,
                  color: MinqTokens.brandPrimary,
                  size: 24,
                ),
                SizedBox(width: MinqTokens.spacing(2)),
                const Text(
                  'Language / 言語',
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
                        color: isSelected ? MinqTokens.brandPrimary : MinqTokens.textSecondary, // Substituted outline
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected
                          ? MinqTokens.brandPrimary.withAlpha((255 * 0.1).round())
                          : null,
                    ),
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: MinqTokens.brandPrimary,
                            size: 20,
                          )
                        else
                          const Icon(
                            Icons.radio_button_unchecked,
                            color: MinqTokens.textSecondary,
                            size: 20,
                          ),
                        SizedBox(width: MinqTokens.spacing(2)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.nativeName,
                                style: MinqTokens.bodyMedium.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? MinqTokens.brandPrimary
                                      : MinqTokens.textPrimary,
                                ),
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
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: MinqTokens.brandPrimary,
                    size: 16,
                  ),
                  SizedBox(width: MinqTokens.spacing(2)),
                  Expanded(
                    child: Text(
                      currentLocale?.languageCode == 'ja'
                          ? '言語を変更すると、アプリ全体の表示言語が即座に切り替わります。'
                          : 'Changing the language will immediately switch the display language throughout the app.',
                      style: MinqTokens.bodySmall.copyWith(
                        color: MinqTokens.textSecondary,
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
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final controller = ref.read(appLocaleControllerProvider.notifier);

    return IconButton(
      onPressed: () => controller.switchToNextLocale(),
      icon: const Icon(Icons.language),
      tooltip: currentLocale?.languageCode == 'ja'
          ? '言語を切り替え'
          : 'Switch Language',
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
      decoration: const BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: BorderRadius.vertical(
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
            const Text(
              'Language / 言語',
              style: MinqTokens.titleLarge,
            ),
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
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? MinqTokens.brandPrimary : MinqTokens.textSecondary,
                  ),
                  title: Text(
                    option.nativeName,
                    style: MinqTokens.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? MinqTokens.brandPrimary : MinqTokens.textPrimary,
                    ),
                  ),
                  subtitle: option.displayName != option.nativeName
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
                  tileColor: isSelected
                      ? MinqTokens.brandPrimary.withAlpha((255 * 0.1).round())
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
