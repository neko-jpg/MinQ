import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for optimizing app startup time
class StartupOptimizationService {
  static const String _preloadDataKey = 'preload_data_enabled';
  static const String _lazyLoadingKey = 'lazy_loading_enabled';
  static const String _startupTimeKey = 'last_startup_time';
  static const String _coldStartCountKey = 'cold_start_count';

  DateTime? _appStartTime;
  DateTime? _firstFrameTime;
  bool _isInitialized = false;

  final List<StartupTask> _preloadTasks = [];
  final List<StartupTask> _deferredTasks = [];
  final Map<String, dynamic> _preloadedData = {};

  static final StartupOptimizationService _instance =
      StartupOptimizationService._internal();
  factory StartupOptimizationService() => _instance;
  StartupOptimizationService._internal() {
    _appStartTime = DateTime.now();
  }

  /// Initialize startup optimization
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Record startup metrics
      await _recordStartupMetrics();

      // Load optimization settings
      await _loadOptimizationSettings();

      // Execute preload tasks
      await _executePreloadTasks();

      // Schedule deferred tasks
      _scheduleDeferredTasks();

      _isInitialized = true;
      debugPrint('Startup optimization initialized');
    } catch (e) {
      debugPrint('Error initializing startup optimization: $e');
    }
  }

  /// Register preload task (executed during app startup)
  void registerPreloadTask(StartupTask task) {
    _preloadTasks.add(task);
  }

  /// Register deferred task (executed after app is ready)
  void registerDeferredTask(StartupTask task) {
    _deferredTasks.add(task);
  }

  /// Get preloaded data
  T? getPreloadedData<T>(String key) {
    return _preloadedData[key] as T?;
  }

  /// Set preloaded data
  void setPreloadedData(String key, dynamic data) {
    _preloadedData[key] = data;
  }

  /// Mark first frame rendered
  void markFirstFrameRendered() {
    _firstFrameTime = DateTime.now();
    _recordFirstFrameTime();
  }

  /// Get startup metrics
  StartupMetrics getStartupMetrics() {
    final now = DateTime.now();
    final startupTime =
        _appStartTime != null ? now.difference(_appStartTime!) : Duration.zero;

    final timeToFirstFrame =
        _firstFrameTime != null && _appStartTime != null
            ? _firstFrameTime!.difference(_appStartTime!)
            : Duration.zero;

    return StartupMetrics(
      appStartTime: _appStartTime ?? now,
      firstFrameTime: _firstFrameTime,
      startupDuration: startupTime,
      timeToFirstFrame: timeToFirstFrame,
      preloadTasksCount: _preloadTasks.length,
      deferredTasksCount: _deferredTasks.length,
      preloadedDataSize: _preloadedData.length,
    );
  }

  /// Optimize startup for next launch
  Future<void> optimizeForNextStartup() async {
    try {
      // Preload critical data
      await _preloadCriticalData();

      // Optimize image cache
      await _optimizeImageCache();

      // Prepare database connections
      await _prepareDatabaseConnections();

      // Cache frequently accessed data
      await _cacheFrequentData();

      debugPrint('Startup optimization prepared for next launch');
    } catch (e) {
      debugPrint('Error optimizing for next startup: $e');
    }
  }

  /// Enable or disable preload data
  Future<void> setPreloadDataEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preloadDataKey, enabled);
  }

  /// Enable or disable lazy loading
  Future<void> setLazyLoadingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lazyLoadingKey, enabled);
  }

  /// Get startup optimization settings
  Future<StartupOptimizationSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return StartupOptimizationSettings(
      preloadDataEnabled: prefs.getBool(_preloadDataKey) ?? true,
      lazyLoadingEnabled: prefs.getBool(_lazyLoadingKey) ?? true,
      coldStartCount: prefs.getInt(_coldStartCountKey) ?? 0,
      lastStartupTime: prefs.getInt(_startupTimeKey),
    );
  }

  /// Get startup recommendations
  Future<List<String>> getStartupRecommendations() async {
    final recommendations = <String>[];
    final metrics = getStartupMetrics();
    final settings = await getSettings();

    // Analyze startup time
    if (metrics.startupDuration.inMilliseconds > 3000) {
      recommendations.add(
        'Startup time is slow (${metrics.startupDuration.inMilliseconds}ms). Consider enabling preload optimization.',
      );
    }

    // Analyze time to first frame
    if (metrics.timeToFirstFrame.inMilliseconds > 1000) {
      recommendations.add(
        'Time to first frame is slow (${metrics.timeToFirstFrame.inMilliseconds}ms). Consider reducing initial UI complexity.',
      );
    }

    // Check preload settings
    if (!settings.preloadDataEnabled) {
      recommendations.add(
        'Enable data preloading to improve startup performance.',
      );
    }

    if (!settings.lazyLoadingEnabled) {
      recommendations.add('Enable lazy loading to reduce initial load time.');
    }

    // Check cold start frequency
    if (settings.coldStartCount > 10) {
      recommendations.add(
        'Frequent cold starts detected. Consider implementing background refresh.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Startup performance is optimized.');
    }

    return recommendations;
  }

  // Private methods

  Future<void> _recordStartupMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Increment cold start count
      final coldStartCount = prefs.getInt(_coldStartCountKey) ?? 0;
      await prefs.setInt(_coldStartCountKey, coldStartCount + 1);

      // Record startup time
      if (_appStartTime != null) {
        await prefs.setInt(
          _startupTimeKey,
          _appStartTime!.millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      debugPrint('Error recording startup metrics: $e');
    }
  }

  Future<void> _loadOptimizationSettings() async {
    // Load settings from SharedPreferences
    // This is handled by getSettings() method
  }

  Future<void> _executePreloadTasks() async {
    final settings = await getSettings();
    if (!settings.preloadDataEnabled) return;

    for (final task in _preloadTasks) {
      try {
        await task.execute();
        debugPrint('Preload task completed: ${task.name}');
      } catch (e) {
        debugPrint('Preload task failed: ${task.name} - $e');
      }
    }
  }

  void _scheduleDeferredTasks() {
    // Execute deferred tasks after a delay
    Timer(const Duration(seconds: 2), () async {
      for (final task in _deferredTasks) {
        try {
          await task.execute();
          debugPrint('Deferred task completed: ${task.name}');
        } catch (e) {
          debugPrint('Deferred task failed: ${task.name} - $e');
        }
      }
    });
  }

  void _recordFirstFrameTime() {
    if (_firstFrameTime != null && _appStartTime != null) {
      final timeToFirstFrame = _firstFrameTime!.difference(_appStartTime!);
      debugPrint('Time to first frame: ${timeToFirstFrame.inMilliseconds}ms');
    }
  }

  Future<void> _preloadCriticalData() async {
    // Preload user preferences
    await SharedPreferences.getInstance();

    // Preload theme data
    setPreloadedData('theme_mode', 'system');

    // Preload user settings
    setPreloadedData('user_settings', {
      'notifications_enabled': true,
      'dark_mode': false,
    });
  }

  Future<void> _optimizeImageCache() async {
    // This would integrate with ImageOptimizationService
    // Pre-warm image cache with critical images
  }

  Future<void> _prepareDatabaseConnections() async {
    // Pre-initialize database connections
    // This would integrate with your database service
  }

  Future<void> _cacheFrequentData() async {
    // Cache frequently accessed data
    // This would integrate with your data services
  }
}

// Data classes

class StartupMetrics {
  final DateTime appStartTime;
  final DateTime? firstFrameTime;
  final Duration startupDuration;
  final Duration timeToFirstFrame;
  final int preloadTasksCount;
  final int deferredTasksCount;
  final int preloadedDataSize;

  const StartupMetrics({
    required this.appStartTime,
    this.firstFrameTime,
    required this.startupDuration,
    required this.timeToFirstFrame,
    required this.preloadTasksCount,
    required this.deferredTasksCount,
    required this.preloadedDataSize,
  });
}

class StartupOptimizationSettings {
  final bool preloadDataEnabled;
  final bool lazyLoadingEnabled;
  final int coldStartCount;
  final int? lastStartupTime;

  const StartupOptimizationSettings({
    required this.preloadDataEnabled,
    required this.lazyLoadingEnabled,
    required this.coldStartCount,
    this.lastStartupTime,
  });
}

abstract class StartupTask {
  String get name;
  int get priority; // Higher number = higher priority

  Future<void> execute();
}

// Example startup tasks

class PreloadUserDataTask extends StartupTask {
  @override
  String get name => 'Preload User Data';

  @override
  int get priority => 10;

  @override
  Future<void> execute() async {
    // Preload user data
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

class PreloadThemeDataTask extends StartupTask {
  @override
  String get name => 'Preload Theme Data';

  @override
  int get priority => 8;

  @override
  Future<void> execute() async {
    // Preload theme data
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

class InitializeAnalyticsTask extends StartupTask {
  @override
  String get name => 'Initialize Analytics';

  @override
  int get priority => 5;

  @override
  Future<void> execute() async {
    // Initialize analytics (deferred)
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
