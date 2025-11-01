import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/settings/settings_service.dart';
import 'package:minq/core/settings/theme_customization_service.dart';

/// Provider for current theme mode
final currentThemeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getThemeMode();
});

/// Provider for current accent color
final currentAccentColorProvider = FutureProvider<Color>((ref) async {
  final service = ref.watch(themeCustomizationServiceProvider);
  return await service.getAccentColor();
});

/// Provider for notifications enabled state
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getNotificationsEnabled();
});

/// Provider for notification time
final notificationTimeProvider = FutureProvider<TimeOfDay>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getNotificationTime();
});

/// Provider for enabled notification categories
final enabledNotificationCategoriesProvider = FutureProvider<Set<String>>((
  ref,
) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getEnabledNotificationCategories();
});

/// Provider for high contrast mode
final highContrastProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getHighContrast();
});

/// Provider for large text mode
final largeTextProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getLargeText();
});

/// Provider for animations enabled
final animationsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getAnimationsEnabled();
});

/// Provider for developer mode
final developerModeProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getDeveloperMode();
});

/// Provider for debug mode
final debugModeProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return await service.getDebugMode();
});

/// State notifier for theme mode changes
class ThemeModeNotifier extends StateNotifier<AsyncValue<ThemeMode>> {
  final SettingsService _settingsService;

  ThemeModeNotifier(this._settingsService) : super(const AsyncValue.loading()) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final mode = await _settingsService.getThemeMode();
      state = AsyncValue.data(mode);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      await _settingsService.setThemeMode(mode);
      state = AsyncValue.data(mode);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final themeModeNotifierProvider =
    StateNotifierProvider<ThemeModeNotifier, AsyncValue<ThemeMode>>((ref) {
      final settingsService = ref.watch(settingsServiceProvider);
      return ThemeModeNotifier(settingsService);
    });

/// State notifier for accent color changes
class AccentColorNotifier extends StateNotifier<AsyncValue<Color>> {
  final ThemeCustomizationService _themeService;

  AccentColorNotifier(this._themeService) : super(const AsyncValue.loading()) {
    _loadAccentColor();
  }

  Future<void> _loadAccentColor() async {
    try {
      final color = await _themeService.getAccentColor();
      state = AsyncValue.data(color);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setAccentColor(Color color) async {
    try {
      await _themeService.setAccentColor(color);
      state = AsyncValue.data(color);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final accentColorNotifierProvider =
    StateNotifierProvider<AccentColorNotifier, AsyncValue<Color>>((ref) {
      final themeService = ref.watch(themeCustomizationServiceProvider);
      return AccentColorNotifier(themeService);
    });

/// State notifier for notifications enabled
class NotificationsEnabledNotifier extends StateNotifier<AsyncValue<bool>> {
  final SettingsService _settingsService;

  NotificationsEnabledNotifier(this._settingsService)
    : super(const AsyncValue.loading()) {
    _loadNotificationsEnabled();
  }

  Future<void> _loadNotificationsEnabled() async {
    try {
      final enabled = await _settingsService.getNotificationsEnabled();
      state = AsyncValue.data(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _settingsService.setNotificationsEnabled(enabled);
      state = AsyncValue.data(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final notificationsEnabledNotifierProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, AsyncValue<bool>>((
      ref,
    ) {
      final settingsService = ref.watch(settingsServiceProvider);
      return NotificationsEnabledNotifier(settingsService);
    });

/// State notifier for notification time
class NotificationTimeNotifier extends StateNotifier<AsyncValue<TimeOfDay>> {
  final SettingsService _settingsService;

  NotificationTimeNotifier(this._settingsService)
    : super(const AsyncValue.loading()) {
    _loadNotificationTime();
  }

  Future<void> _loadNotificationTime() async {
    try {
      final time = await _settingsService.getNotificationTime();
      state = AsyncValue.data(time);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    try {
      await _settingsService.setNotificationTime(time);
      state = AsyncValue.data(time);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final notificationTimeNotifierProvider =
    StateNotifierProvider<NotificationTimeNotifier, AsyncValue<TimeOfDay>>((
      ref,
    ) {
      final settingsService = ref.watch(settingsServiceProvider);
      return NotificationTimeNotifier(settingsService);
    });

/// State notifier for accessibility settings
class AccessibilitySettingsNotifier
    extends StateNotifier<AsyncValue<AccessibilitySettings>> {
  final SettingsService _settingsService;

  AccessibilitySettingsNotifier(this._settingsService)
    : super(const AsyncValue.loading()) {
    _loadAccessibilitySettings();
  }

  Future<void> _loadAccessibilitySettings() async {
    try {
      final highContrast = await _settingsService.getHighContrast();
      final largeText = await _settingsService.getLargeText();
      final animationsEnabled = await _settingsService.getAnimationsEnabled();

      final settings = AccessibilitySettings(
        highContrast: highContrast,
        largeText: largeText,
        animationsEnabled: animationsEnabled,
      );

      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setHighContrast(bool enabled) async {
    try {
      await _settingsService.setHighContrast(enabled);
      final current = state.value!;
      state = AsyncValue.data(current.copyWith(highContrast: enabled));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setLargeText(bool enabled) async {
    try {
      await _settingsService.setLargeText(enabled);
      final current = state.value!;
      state = AsyncValue.data(current.copyWith(largeText: enabled));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    try {
      await _settingsService.setAnimationsEnabled(enabled);
      final current = state.value!;
      state = AsyncValue.data(current.copyWith(animationsEnabled: enabled));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final accessibilitySettingsNotifierProvider = StateNotifierProvider<
  AccessibilitySettingsNotifier,
  AsyncValue<AccessibilitySettings>
>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return AccessibilitySettingsNotifier(settingsService);
});

/// Data class for accessibility settings
class AccessibilitySettings {
  final bool highContrast;
  final bool largeText;
  final bool animationsEnabled;

  const AccessibilitySettings({
    required this.highContrast,
    required this.largeText,
    required this.animationsEnabled,
  });

  AccessibilitySettings copyWith({
    bool? highContrast,
    bool? largeText,
    bool? animationsEnabled,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }
}
