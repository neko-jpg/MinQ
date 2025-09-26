import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/services/local_preferences_service.dart';

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
        state = null;
        return;
      }
      final parts = saved.split('_');
      if (parts.isEmpty || parts.first.isEmpty) {
        state = null;
        return;
      }
      state = Locale(parts.first, parts.length > 1 ? parts[1] : null);
    }();
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await _preferences.setPreferredLocale(locale?.toLanguageTag());
  }
}
