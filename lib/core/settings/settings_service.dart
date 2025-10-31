import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/storage/local_storage_service.dart';

/// Service for managing app settings and preferences
class SettingsService {
  final LocalStorageService _storage;

  SettingsService(this._storage);

  // Theme Settings
  static const String _themeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _customThemeKey = 'custom_theme';

  // Notification Settings
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _notificationCategoriesKey = 'notification_categories';

  // Accessibility Settings
  static const String _highContrastKey = 'high_contrast';
  static const String _largeTextKey = 'large_text';
  static const String _animationsEnabledKey = 'animations_enabled';

  // Advanced Settings
  static const String _developerModeKey = 'developer_mode';
  static const String _debugModeKey = 'debug_mode';

  // Theme Settings
  Future<ThemeMode> getThemeMode() async {
    final value = await _storage.getString(_themeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await _storage.setString(_themeKey, value);
  }

  Future<Color?> getAccentColor() async {
    final value = await _storage.getInt(_accentColorKey);
    return value != null ? Color(value) : null;
  }

  Future<void> setAccentColor(Color color) async {
    await _storage.setInt(_accentColorKey, color.value);
  }

  Future<Map<String, dynamic>?> getCustomTheme() async {
    final value = await _storage.getString(_customThemeKey);
    if (value != null) {
      // Parse JSON string to Map
      // For now, return null - implement JSON parsing if needed
      return null;
    }
    return null;
  }

  Future<void> setCustomTheme(Map<String, dynamic> theme) async {
    // Convert Map to JSON string
    // For now, just store a placeholder
    await _storage.setString(_customThemeKey, 'custom_theme_data');
  }

  // Notification Settings
  Future<bool> getNotificationsEnabled() async {
    return await _storage.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.setBool(_notificationsEnabledKey, enabled);
  }

  Future<TimeOfDay> getNotificationTime() async {
    final hour = await _storage.getInt('${_notificationTimeKey}_hour') ?? 9;
    final minute = await _storage.getInt('${_notificationTimeKey}_minute') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    await _storage.setInt('${_notificationTimeKey}_hour', time.hour);
    await _storage.setInt('${_notificationTimeKey}_minute', time.minute);
  }

  Future<Set<String>> getEnabledNotificationCategories() async {
    final categories = await _storage.getStringList(_notificationCategoriesKey);
    return categories?.toSet() ?? {'quests', 'achievements', 'social', 'ai'};
  }

  Future<void> setEnabledNotificationCategories(Set<String> categories) async {
    await _storage.setStringList(_notificationCategoriesKey, categories.toList());
  }

  // Accessibility Settings
  Future<bool> getHighContrast() async {
    return await _storage.getBool(_highContrastKey) ?? false;
  }

  Future<void> setHighContrast(bool enabled) async {
    await _storage.setBool(_highContrastKey, enabled);
  }

  Future<bool> getLargeText() async {
    return await _storage.getBool(_largeTextKey) ?? false;
  }

  Future<void> setLargeText(bool enabled) async {
    await _storage.setBool(_largeTextKey, enabled);
  }

  Future<bool> getAnimationsEnabled() async {
    return await _storage.getBool(_animationsEnabledKey) ?? true;
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    await _storage.setBool(_animationsEnabledKey, enabled);
  }

  // Advanced Settings
  Future<bool> getDeveloperMode() async {
    return await _storage.getBool(_developerModeKey) ?? false;
  }

  Future<void> setDeveloperMode(bool enabled) async {
    await _storage.setBool(_developerModeKey, enabled);
  }

  Future<bool> getDebugMode() async {
    return await _storage.getBool(_debugModeKey) ?? false;
  }

  Future<void> setDebugMode(bool enabled) async {
    await _storage.setBool(_debugModeKey, enabled);
  }

  // Reset all settings
  Future<void> resetAllSettings() async {
    final keys = [
      _themeKey,
      _accentColorKey,
      _customThemeKey,
      _notificationsEnabledKey,
      _notificationTimeKey,
      _notificationCategoriesKey,
      _highContrastKey,
      _largeTextKey,
      _animationsEnabledKey,
      _developerModeKey,
      _debugModeKey,
    ];

    for (final key in keys) {
      await _storage.remove(key);
    }
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return SettingsService(storage);
});