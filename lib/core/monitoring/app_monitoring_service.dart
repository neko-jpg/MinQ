import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:minq/core/analytics/analytics_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Comprehensive app monitoring service for tracking app health and performance
class AppMonitoringService {
  static final AppMonitoringService _instance = AppMonitoringService._internal();
  factory AppMonitoringService() => _instance;
  AppMonitoringService._internal();

  final AnalyticsService _analytics = AnalyticsService();
  final LocalStorageService _storage = LocalStorageService();
  
  Timer? _healthCheckTimer;
  Timer? _memoryMonitorTimer;
  DateTime? _appStartTime;
  int _frameDropCount = 0;
  int _totalFrames = 0;
  
  // App health metrics
  final Map<String, dynamic> _healthMetrics = {};
  final List<AppHealthEvent> _healthEvents = [];
  
  /// Initialize monitoring system
  Future<void> initialize() async {
    _appStartTime = DateTime.now();
    
    // Start periodic health checks
    _startHealthMonitoring();
    
    // Monitor memory usage
    _startMemoryMonitoring();
    
    // Track app lifecycle
    _trackAppLifecycle();
    
    // Monitor frame performance
    _monitorFramePerformance();
    
    debugPrint('AppMonitoringService initialized');
  }

  /// Start periodic health monitoring
  void _startHealthMonitoring() {
    _healthCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performHealthCheck(),
    );
  }

  /// Start memory usage monitoring
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkMemoryUsage(),
    );
  }

  /// Perform comprehensive health check
  Future<void> _performHealthCheck() async {
    try {
      final healthData = await _collectHealthData();
      _healthMetrics.addAll(healthData);
      
      // Check for critical issues
      await _checkCriticalIssues(healthData);
      
      // Store health snapshot
      await _storeHealthSnapshot(healthData);
      
      // Send to analytics if needed
      if (_shouldReportHealth(healthData)) {
        await _analytics.trackEvent('app_health_check', healthData);
      }
    } catch (e) {
      debugPrint('Health check failed: $e');
      await recordError('health_check_failed', e);
    }
  }

  /// Collect comprehensive health data
  Future<Map<String, dynamic>> _collectHealthData() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    final data = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'app_version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
      'uptime_minutes': _getUptimeMinutes(),
      'memory_usage_mb': await _getCurrentMemoryUsage(),
      'frame_drop_rate': _getFrameDropRate(),
      'storage_usage_mb': await _getStorageUsage(),
      'network_status': await _getNetworkStatus(),
      'battery_level': await _getBatteryLevel(),
      'device_temperature': await _getDeviceTemperature(),
    };

    // Add platform-specific data
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      data.addAll({
        'android_version': androidInfo.version.release,
        'device_model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'available_memory_mb': androidInfo.systemFeatures.length,
      });
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      data.addAll({
        'ios_version': iosInfo.systemVersion,
        'device_model': iosInfo.model,
        'device_name': iosInfo.name,
      });
    }

    return data;
  }

  /// Check for critical performance or health issues
  Future<void> _checkCriticalIssues(Map<String, dynamic> healthData) async {
    final issues = <String>[];

    // Memory usage check
    final memoryUsage = healthData['memory_usage_mb'] as double? ?? 0;
    if (memoryUsage > 500) {
      issues.add('high_memory_usage');
    }

    // Frame drop rate check
    final frameDropRate = healthData['frame_drop_rate'] as double? ?? 0;
    if (frameDropRate > 0.1) {
      issues.add('high_frame_drops');
    }

    // Storage usage check
    final storageUsage = healthData['storage_usage_mb'] as double? ?? 0;
    if (storageUsage > 1000) {
      issues.add('high_storage_usage');
    }

    // Battery drain check
    final batteryLevel = healthData['battery_level'] as double? ?? 100;
    if (batteryLevel < 20) {
      issues.add('low_battery');
    }

    if (issues.isNotEmpty) {
      final event = AppHealthEvent(
        timestamp: DateTime.now(),
        type: AppHealthEventType.warning,
        issues: issues,
        metrics: Map<String, dynamic>.from(healthData),
      );
      
      _healthEvents.add(event);
      await _analytics.trackEvent('app_health_warning', {
        'issues': issues,
        'metrics': healthData,
      });
    }
  }

  /// Monitor frame rendering performance
  void _monitorFramePerformance() {
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      _totalFrames++;
      
      // Check if frame took too long (>16.67ms for 60fps)
      final frameDuration = timeStamp.inMicroseconds / 1000;
      if (frameDuration > 16.67) {
        _frameDropCount++;
      }
    });
  }

  /// Track app lifecycle events
  void _trackAppLifecycle() {
    WidgetsBinding.instance.didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  /// Record application error with context
  Future<void> recordError(String errorType, dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    final errorData = {
      'error_type': errorType,
      'error_message': error.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'app_version': await _getAppVersion(),
      'uptime_minutes': _getUptimeMinutes(),
      'context': context ?? {},
    };

    if (stackTrace != null) {
      errorData['stack_trace'] = stackTrace.toString();
    }

    // Store locally for offline analysis
    await _storage.storeErrorLog(errorData);

    // Send to analytics
    await _analytics.trackEvent('app_error', errorData);

    debugPrint('Error recorded: $errorType - $error');
  }

  /// Record performance metric
  Future<void> recordPerformanceMetric(String metricName, double value, {
    Map<String, dynamic>? context,
  }) async {
    final metricData = {
      'metric_name': metricName,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
      'context': context ?? {},
    };

    await _analytics.trackEvent('performance_metric', metricData);
  }

  /// Record user action for behavior analysis
  Future<void> recordUserAction(String action, {
    Map<String, dynamic>? properties,
  }) async {
    final actionData = {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'properties': properties ?? {},
    };

    await _analytics.trackEvent('user_action', actionData);
  }

  /// Get current app health status
  AppHealthStatus getHealthStatus() {
    final memoryUsage = _healthMetrics['memory_usage_mb'] as double? ?? 0;
    final frameDropRate = _getFrameDropRate();
    final uptime = _getUptimeMinutes();

    if (memoryUsage > 500 || frameDropRate > 0.15) {
      return AppHealthStatus.critical;
    } else if (memoryUsage > 300 || frameDropRate > 0.1 || uptime > 480) {
      return AppHealthStatus.warning;
    } else {
      return AppHealthStatus.healthy;
    }
  }

  /// Get health metrics summary
  Map<String, dynamic> getHealthMetrics() {
    return Map<String, dynamic>.from(_healthMetrics);
  }

  /// Get recent health events
  List<AppHealthEvent> getRecentHealthEvents({int limit = 50}) {
    return _healthEvents.take(limit).toList();
  }

  // Helper methods
  double _getUptimeMinutes() {
    if (_appStartTime == null) return 0;
    return DateTime.now().difference(_appStartTime!).inMinutes.toDouble();
  }

  double _getFrameDropRate() {
    if (_totalFrames == 0) return 0;
    return _frameDropCount / _totalFrames;
  }

  Future<double> _getCurrentMemoryUsage() async {
    // Platform-specific memory usage implementation
    try {
      if (Platform.isAndroid) {
        // Use platform channel to get Android memory info
        const platform = MethodChannel('minq/system_info');
        final result = await platform.invokeMethod('getMemoryUsage');
        return (result as num).toDouble();
      }
      return 0; // Fallback
    } catch (e) {
      return 0;
    }
  }

  Future<double> _getStorageUsage() async {
    try {
      final directory = Directory.systemTemp;
      int totalSize = 0;
      
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize / (1024 * 1024); // Convert to MB
    } catch (e) {
      return 0;
    }
  }

  Future<String> _getNetworkStatus() async {
    // Implementation would use connectivity_plus
    return 'connected';
  }

  Future<double> _getBatteryLevel() async {
    try {
      const platform = MethodChannel('minq/battery');
      final result = await platform.invokeMethod('getBatteryLevel');
      return (result as num).toDouble();
    } catch (e) {
      return 100;
    }
  }

  Future<double> _getDeviceTemperature() async {
    // Platform-specific temperature monitoring
    return 25.0; // Placeholder
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> _storeHealthSnapshot(Map<String, dynamic> healthData) async {
    await _storage.storeHealthSnapshot(healthData);
  }

  bool _shouldReportHealth(Map<String, dynamic> healthData) {
    // Report health data every 30 minutes or if critical issues detected
    final lastReport = _healthMetrics['last_report_time'] as DateTime?;
    if (lastReport == null || 
        DateTime.now().difference(lastReport).inMinutes > 30) {
      _healthMetrics['last_report_time'] = DateTime.now();
      return true;
    }
    return false;
  }

  Future<void> _checkMemoryUsage() async {
    final memoryUsage = await _getCurrentMemoryUsage();
    _healthMetrics['memory_usage_mb'] = memoryUsage;
    
    if (memoryUsage > 400) {
      await recordError('high_memory_usage', 'Memory usage: ${memoryUsage}MB');
    }
  }

  /// Cleanup resources
  void dispose() {
    _healthCheckTimer?.cancel();
    _memoryMonitorTimer?.cancel();
  }
}

/// App health status levels
enum AppHealthStatus {
  healthy,
  warning,
  critical,
}

/// App health event for tracking issues
class AppHealthEvent {
  final DateTime timestamp;
  final AppHealthEventType type;
  final List<String> issues;
  final Map<String, dynamic> metrics;

  AppHealthEvent({
    required this.timestamp,
    required this.type,
    required this.issues,
    required this.metrics,
  });
}

enum AppHealthEventType {
  info,
  warning,
  error,
  critical,
}