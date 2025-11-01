import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing performance-related settings
class PerformanceSettingsService {
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _particleEffectsEnabledKey = 'particle_effects_enabled';
  static const String _heavyAnimationsEnabledKey = 'heavy_animations_enabled';
  static const String _imageOptimizationEnabledKey =
      'image_optimization_enabled';
  static const String _lazyLoadingEnabledKey = 'lazy_loading_enabled';
  static const String _performanceModeKey = 'performance_mode';
  static const String _frameRateLimitKey = 'frame_rate_limit';
  static const String _memoryOptimizationKey = 'memory_optimization_enabled';
  static const String _batteryOptimizationKey = 'battery_optimization_enabled';
  static const String _networkOptimizationKey = 'network_optimization_enabled';

  PerformanceSettings? _cachedSettings;
  final StreamController<PerformanceSettings> _settingsController =
      StreamController.broadcast();

  static final PerformanceSettingsService _instance =
      PerformanceSettingsService._internal();
  factory PerformanceSettingsService() => _instance;
  PerformanceSettingsService._internal();

  /// Get settings stream
  Stream<PerformanceSettings> get settingsStream => _settingsController.stream;

  /// Get current performance settings
  Future<PerformanceSettings> getSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    final prefs = await SharedPreferences.getInstance();

    _cachedSettings = PerformanceSettings(
      animationsEnabled: prefs.getBool(_animationsEnabledKey) ?? true,
      particleEffectsEnabled: prefs.getBool(_particleEffectsEnabledKey) ?? true,
      heavyAnimationsEnabled: prefs.getBool(_heavyAnimationsEnabledKey) ?? true,
      imageOptimizationEnabled:
          prefs.getBool(_imageOptimizationEnabledKey) ?? true,
      lazyLoadingEnabled: prefs.getBool(_lazyLoadingEnabledKey) ?? true,
      performanceMode:
          PerformanceMode.values[prefs.getInt(_performanceModeKey) ??
              1], // Default to balanced
      frameRateLimit: prefs.getInt(_frameRateLimitKey) ?? 60,
      memoryOptimizationEnabled: prefs.getBool(_memoryOptimizationKey) ?? true,
      batteryOptimizationEnabled:
          prefs.getBool(_batteryOptimizationKey) ?? true,
      networkOptimizationEnabled:
          prefs.getBool(_networkOptimizationKey) ?? true,
    );

    return _cachedSettings!;
  }

  /// Update performance settings
  Future<void> updateSettings(PerformanceSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setBool(_animationsEnabledKey, settings.animationsEnabled),
      prefs.setBool(
        _particleEffectsEnabledKey,
        settings.particleEffectsEnabled,
      ),
      prefs.setBool(
        _heavyAnimationsEnabledKey,
        settings.heavyAnimationsEnabled,
      ),
      prefs.setBool(
        _imageOptimizationEnabledKey,
        settings.imageOptimizationEnabled,
      ),
      prefs.setBool(_lazyLoadingEnabledKey, settings.lazyLoadingEnabled),
      prefs.setInt(_performanceModeKey, settings.performanceMode.index),
      prefs.setInt(_frameRateLimitKey, settings.frameRateLimit),
      prefs.setBool(_memoryOptimizationKey, settings.memoryOptimizationEnabled),
      prefs.setBool(
        _batteryOptimizationKey,
        settings.batteryOptimizationEnabled,
      ),
      prefs.setBool(
        _networkOptimizationKey,
        settings.networkOptimizationEnabled,
      ),
    ]);

    _cachedSettings = settings;
    _settingsController.add(settings);

    debugPrint('Performance settings updated');
  }

  /// Set animations enabled/disabled
  Future<void> setAnimationsEnabled(bool enabled) async {
    final currentSettings = await getSettings();
    await updateSettings(currentSettings.copyWith(animationsEnabled: enabled));
  }

  /// Set particle effects enabled/disabled
  Future<void> setParticleEffectsEnabled(bool enabled) async {
    final currentSettings = await getSettings();
    await updateSettings(
      currentSettings.copyWith(particleEffectsEnabled: enabled),
    );
  }

  /// Set heavy animations enabled/disabled
  Future<void> setHeavyAnimationsEnabled(bool enabled) async {
    final currentSettings = await getSettings();
    await updateSettings(
      currentSettings.copyWith(heavyAnimationsEnabled: enabled),
    );
  }

  /// Set performance mode
  Future<void> setPerformanceMode(PerformanceMode mode) async {
    final currentSettings = await getSettings();
    await updateSettings(currentSettings.copyWith(performanceMode: mode));
  }

  /// Apply performance mode preset
  Future<void> applyPerformanceModePreset(PerformanceMode mode) async {
    PerformanceSettings settings;

    switch (mode) {
      case PerformanceMode.performance:
        settings = PerformanceSettings.performancePreset();
        break;
      case PerformanceMode.balanced:
        settings = PerformanceSettings.balancedPreset();
        break;
      case PerformanceMode.battery:
        settings = PerformanceSettings.batteryPreset();
        break;
    }

    await updateSettings(settings);
  }

  /// Get performance recommendations based on device capabilities
  Future<List<PerformanceRecommendation>> getRecommendations() async {
    final recommendations = <PerformanceRecommendation>[];
    final settings = await getSettings();

    // Check device performance characteristics
    final deviceInfo = await _getDevicePerformanceInfo();

    // Memory recommendations
    if (deviceInfo.availableMemory < 2048) {
      // Less than 2GB RAM
      recommendations.add(
        PerformanceRecommendation(
          type: RecommendationType.memory,
          title: 'Enable Memory Optimization',
          description:
              'Your device has limited memory. Enable memory optimization for better performance.',
          action:
              () => updateSettings(
                settings.copyWith(memoryOptimizationEnabled: true),
              ),
          priority: RecommendationPriority.high,
        ),
      );
    }

    // Animation recommendations
    if (deviceInfo.cpuCores < 4) {
      // Older/slower CPU
      recommendations.add(
        PerformanceRecommendation(
          type: RecommendationType.animation,
          title: 'Disable Heavy Animations',
          description:
              'Disable heavy animations to improve performance on your device.',
          action:
              () => updateSettings(
                settings.copyWith(heavyAnimationsEnabled: false),
              ),
          priority: RecommendationPriority.medium,
        ),
      );
    }

    // Battery recommendations
    if (deviceInfo.batteryLevel < 0.2) {
      // Low battery
      recommendations.add(
        PerformanceRecommendation(
          type: RecommendationType.battery,
          title: 'Enable Battery Optimization',
          description:
              'Your battery is low. Enable battery optimization to extend usage time.',
          action:
              () => updateSettings(
                settings.copyWith(batteryOptimizationEnabled: true),
              ),
          priority: RecommendationPriority.high,
        ),
      );
    }

    // Network recommendations
    if (deviceInfo.isOnSlowNetwork) {
      recommendations.add(
        PerformanceRecommendation(
          type: RecommendationType.network,
          title: 'Enable Network Optimization',
          description:
              'Slow network detected. Enable network optimization for better experience.',
          action:
              () => updateSettings(
                settings.copyWith(networkOptimizationEnabled: true),
              ),
          priority: RecommendationPriority.medium,
        ),
      );
    }

    // Frame rate recommendations
    if (deviceInfo.maxRefreshRate < 60) {
      recommendations.add(
        PerformanceRecommendation(
          type: RecommendationType.display,
          title: 'Limit Frame Rate',
          description: 'Limit frame rate to match your display capabilities.',
          action:
              () => updateSettings(
                settings.copyWith(frameRateLimit: deviceInfo.maxRefreshRate),
              ),
          priority: RecommendationPriority.low,
        ),
      );
    }

    return recommendations;
  }

  /// Auto-optimize settings based on device performance
  Future<void> autoOptimize() async {
    final deviceInfo = await _getDevicePerformanceInfo();
    PerformanceSettings optimizedSettings;

    if (deviceInfo.performanceScore < 30) {
      // Low-end device
      optimizedSettings = PerformanceSettings.batteryPreset();
    } else if (deviceInfo.performanceScore < 70) {
      // Mid-range device
      optimizedSettings = PerformanceSettings.balancedPreset();
    } else {
      // High-end device
      optimizedSettings = PerformanceSettings.performancePreset();
    }

    await updateSettings(optimizedSettings);
    debugPrint(
      'Auto-optimized settings for device performance score: ${deviceInfo.performanceScore}',
    );
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    await updateSettings(PerformanceSettings.defaultSettings());
  }

  // Private methods

  Future<DevicePerformanceInfo> _getDevicePerformanceInfo() async {
    // This would integrate with device_info_plus and other packages
    // For now, return mock data
    return const DevicePerformanceInfo(
      availableMemory: 4096, // 4GB
      cpuCores: 8,
      batteryLevel: 0.75,
      isOnSlowNetwork: false,
      maxRefreshRate: 60,
      performanceScore: 75,
    );
  }

  void dispose() {
    _settingsController.close();
  }
}

// Data classes

class PerformanceSettings {
  final bool animationsEnabled;
  final bool particleEffectsEnabled;
  final bool heavyAnimationsEnabled;
  final bool imageOptimizationEnabled;
  final bool lazyLoadingEnabled;
  final PerformanceMode performanceMode;
  final int frameRateLimit;
  final bool memoryOptimizationEnabled;
  final bool batteryOptimizationEnabled;
  final bool networkOptimizationEnabled;

  const PerformanceSettings({
    required this.animationsEnabled,
    required this.particleEffectsEnabled,
    required this.heavyAnimationsEnabled,
    required this.imageOptimizationEnabled,
    required this.lazyLoadingEnabled,
    required this.performanceMode,
    required this.frameRateLimit,
    required this.memoryOptimizationEnabled,
    required this.batteryOptimizationEnabled,
    required this.networkOptimizationEnabled,
  });

  factory PerformanceSettings.defaultSettings() {
    return const PerformanceSettings(
      animationsEnabled: true,
      particleEffectsEnabled: true,
      heavyAnimationsEnabled: true,
      imageOptimizationEnabled: true,
      lazyLoadingEnabled: true,
      performanceMode: PerformanceMode.balanced,
      frameRateLimit: 60,
      memoryOptimizationEnabled: true,
      batteryOptimizationEnabled: true,
      networkOptimizationEnabled: true,
    );
  }

  factory PerformanceSettings.performancePreset() {
    return const PerformanceSettings(
      animationsEnabled: true,
      particleEffectsEnabled: true,
      heavyAnimationsEnabled: true,
      imageOptimizationEnabled: true,
      lazyLoadingEnabled: true,
      performanceMode: PerformanceMode.performance,
      frameRateLimit: 120,
      memoryOptimizationEnabled: false,
      batteryOptimizationEnabled: false,
      networkOptimizationEnabled: true,
    );
  }

  factory PerformanceSettings.balancedPreset() {
    return const PerformanceSettings(
      animationsEnabled: true,
      particleEffectsEnabled: true,
      heavyAnimationsEnabled: true,
      imageOptimizationEnabled: true,
      lazyLoadingEnabled: true,
      performanceMode: PerformanceMode.balanced,
      frameRateLimit: 60,
      memoryOptimizationEnabled: true,
      batteryOptimizationEnabled: true,
      networkOptimizationEnabled: true,
    );
  }

  factory PerformanceSettings.batteryPreset() {
    return const PerformanceSettings(
      animationsEnabled: false,
      particleEffectsEnabled: false,
      heavyAnimationsEnabled: false,
      imageOptimizationEnabled: true,
      lazyLoadingEnabled: true,
      performanceMode: PerformanceMode.battery,
      frameRateLimit: 30,
      memoryOptimizationEnabled: true,
      batteryOptimizationEnabled: true,
      networkOptimizationEnabled: true,
    );
  }

  PerformanceSettings copyWith({
    bool? animationsEnabled,
    bool? particleEffectsEnabled,
    bool? heavyAnimationsEnabled,
    bool? imageOptimizationEnabled,
    bool? lazyLoadingEnabled,
    PerformanceMode? performanceMode,
    int? frameRateLimit,
    bool? memoryOptimizationEnabled,
    bool? batteryOptimizationEnabled,
    bool? networkOptimizationEnabled,
  }) {
    return PerformanceSettings(
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      particleEffectsEnabled:
          particleEffectsEnabled ?? this.particleEffectsEnabled,
      heavyAnimationsEnabled:
          heavyAnimationsEnabled ?? this.heavyAnimationsEnabled,
      imageOptimizationEnabled:
          imageOptimizationEnabled ?? this.imageOptimizationEnabled,
      lazyLoadingEnabled: lazyLoadingEnabled ?? this.lazyLoadingEnabled,
      performanceMode: performanceMode ?? this.performanceMode,
      frameRateLimit: frameRateLimit ?? this.frameRateLimit,
      memoryOptimizationEnabled:
          memoryOptimizationEnabled ?? this.memoryOptimizationEnabled,
      batteryOptimizationEnabled:
          batteryOptimizationEnabled ?? this.batteryOptimizationEnabled,
      networkOptimizationEnabled:
          networkOptimizationEnabled ?? this.networkOptimizationEnabled,
    );
  }
}

class PerformanceRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final VoidCallback action;
  final RecommendationPriority priority;

  const PerformanceRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.action,
    required this.priority,
  });
}

class DevicePerformanceInfo {
  final int availableMemory; // MB
  final int cpuCores;
  final double batteryLevel; // 0.0 to 1.0
  final bool isOnSlowNetwork;
  final int maxRefreshRate;
  final int performanceScore; // 0-100

  const DevicePerformanceInfo({
    required this.availableMemory,
    required this.cpuCores,
    required this.batteryLevel,
    required this.isOnSlowNetwork,
    required this.maxRefreshRate,
    required this.performanceScore,
  });
}

enum PerformanceMode { performance, balanced, battery }

enum RecommendationType { memory, animation, battery, network, display }

enum RecommendationPriority { low, medium, high, critical }
