import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/l10n/app_localizations.dart';

class AppLocaleController extends StateNotifier<Locale?> {
  AppLocaleController(this._preferences) : super(null) {
    _load();
  }

  final LocalPreferencesService _preferences;
  Future<void>? _initialLoad;

  Future<void> _load() {
    return _initialLoad ??= () async {
      final saved = await _preferences.getPreferredLocale();
      if (saved == null) {
        // Use system locale if supported, otherwise default to Japanese
        final systemLocale = ui.PlatformDispatcher.instance.locale;
        final supportedLocale = findSupportedLocale(systemLocale);
        state = supportedLocale;
        return;
      }
      final parts = saved.split('_');
      if (parts.isEmpty || parts.first.isEmpty) {
        state = const Locale('ja');
        return;
      }
      final locale = Locale(parts.first, parts.length > 1 ? parts[1] : null);
      // Ensure the locale is supported
      state = findSupportedLocale(locale);
    }();
  }

  Locale findSupportedLocale(Locale locale) {
    // Check if exact locale is supported
    for (final supportedLocale in AppLocalizations.supportedLocales) {
      if (supportedLocale == locale) {
        return supportedLocale;
      }
    }
    
    // Check if language code is supported
    for (final supportedLocale in AppLocalizations.supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    
    // Default to Japanese
    return const Locale('ja');
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale != null) {
      // Ensure the locale is supported
      locale = findSupportedLocale(locale);
    }
    state = locale;
    await _preferences.setPreferredLocale(locale?.toLanguageTag());
  }

  /// Get available locales with their display names
  List<LocaleOption> getAvailableLocales() {
    return [
      const LocaleOption(
        locale: Locale('ja'),
        displayName: 'Japanese',
        nativeName: '日本語',
        isRTL: false,
        region: 'Japan',
        currency: 'JPY',
      ),
      const LocaleOption(
        locale: Locale('en'),
        displayName: 'English',
        nativeName: 'English',
        isRTL: false,
        region: 'United States',
        currency: 'USD',
      ),
      const LocaleOption(
        locale: Locale('zh'),
        displayName: 'Chinese (Simplified)',
        nativeName: '中文 (简体)',
        isRTL: false,
        region: 'China',
        currency: 'CNY',
      ),
      const LocaleOption(
        locale: Locale('ko'),
        displayName: 'Korean',
        nativeName: '한국어',
        isRTL: false,
        region: 'South Korea',
        currency: 'KRW',
      ),
      const LocaleOption(
        locale: Locale('es'),
        displayName: 'Spanish',
        nativeName: 'Español',
        isRTL: false,
        region: 'Spain',
        currency: 'EUR',
      ),
      const LocaleOption(
        locale: Locale('ar'),
        displayName: 'Arabic',
        nativeName: 'العربية',
        isRTL: true,
        region: 'Saudi Arabia',
        currency: 'SAR',
      ),
    ];
  }

  /// Check if the current locale is RTL
  bool get isCurrentLocaleRTL {
    if (state == null) return false;
    final option = getAvailableLocales().firstWhere(
      (option) => option.locale == state,
      orElse: () => getAvailableLocales().first,
    );
    return option.isRTL;
  }

  /// Get text direction for current locale
  TextDirection get textDirection {
    return isCurrentLocaleRTL ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Switch to the next available locale
  Future<void> switchToNextLocale() async {
    final availableLocales = getAvailableLocales();
    final currentIndex = availableLocales.indexWhere(
      (option) => option.locale == state,
    );
    
    final nextIndex = (currentIndex + 1) % availableLocales.length;
    await setLocale(availableLocales[nextIndex].locale);
  }
}

class LocaleOption {
  const LocaleOption({
    required this.locale,
    required this.displayName,
    required this.nativeName,
    required this.isRTL,
    required this.region,
    required this.currency,
  });

  final Locale locale;
  final String displayName;
  final String nativeName;
  final bool isRTL;
  final String region;
  final String currency;
}
