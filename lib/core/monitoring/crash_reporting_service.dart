import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:minq/core/network/network_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Comprehensive crash reporting and error monitoring service
class CrashReportingService {
  static final CrashReportingService _instance = CrashReportingService._internal();
  factory CrashReportingService() => _instance;
  CrashReportingService._internal();

  final LocalStorageService _storage = LocalStorageService();
  final NetworkService _network = NetworkService();
  
  bool _isInitialized = false;
  final List<CrashReport> _pendingReports = [];
  Timer? _uploadTimer;

  /// Initialize crash reporting system
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Set up platform error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // Set up zone error handling for async errors
    runZonedGuarded(() {
      // App initialization continues here
    }, (error, stack) {
      _handleAsyncError(error, stack);
    });

    // Start periodic upload of pending reports
    _startPeriodicUpload();

    _isInitialized = true;
    debugPrint('CrashReportingService initialized');
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    final report = CrashReport(
      id: _generateReportId(),
      timestamp: DateTime.now(),
      type: CrashType.flutter,
      error: details.exception.toString(),
      stackTrace: details.stack?.toString(),
      context: {
        'library': details.library,
        'context': details.context?.toString(),
        'information_collector': details.informationCollector?.toString(),
      },
      severity: _determineSeverity(details.exception),
    );

    _processCrashReport(report);

    // Still show error in debug mode
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Handle platform-specific errors
  bool _handlePlatformError(Object error, StackTrace stack) {
    final report = CrashReport(
      id: _generateReportId(),
      timestamp: DateTime.now(),
      type: CrashType.platform,
      error: error.toString(),
      stackTrace: stack.toString(),
      context: {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
      },
      severity: CrashSeverity.high,
    );

    _processCrashReport(report);
    return true;
  }

  /// Handle async errors from zones
  void _handleAsyncError(Object error, StackTrace stack) {
    final report = CrashReport(
      id: _generateReportId(),
      timestamp: DateTime.now(),
      type: CrashType.async,
      error: error.toString(),
      stackTrace: stack.toString(),
      context: {
        'zone': Zone.current.toString(),
      },
      severity: _determineSeverityFromError(error),
    );

    _processCrashReport(report);
  }

  /// Process and store crash report
  Future<void> _processCrashReport(CrashReport report) async {
    try {
      // Enrich report with device and app info
      final enrichedReport = await _enrichCrashReport(report);
      
      // Store locally
      await _storage.storeCrashReport(enrichedReport);
      
      // Add to pending uploads
      _pendingReports.add(enrichedReport);
      
      // Try immediate upload if network available
      if (await _network.isConnected()) {
        await _uploadPendingReports();
      }

      debugPrint('Crash report processed: ${report.id}');
    } catch (e) {
      debugPrint('Failed to process crash report: $e');
    }
  }

  /// Enrich crash report with device and app information
  Future<CrashReport> _enrichCrashReport(CrashReport report) async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    final enrichedContext = Map<String, dynamic>.from(report.context);
    
    // Add app information
    enrichedContext.addAll({
      'app_version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
      'package_name': packageInfo.packageName,
      'app_name': packageInfo.appName,
    });

    // Add device information
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      enrichedContext.addAll({
        'device_model': androidInfo.model,
        'device_manufacturer': androidInfo.manufacturer,
        'android_version': androidInfo.version.release,
        'android_sdk': androidInfo.version.sdkInt,
        'device_id': androidInfo.id,
        'hardware': androidInfo.hardware,
        'supported_abis': androidInfo.supportedAbis,
      });
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      enrichedContext.addAll({
        'device_model': iosInfo.model,
        'device_name': iosInfo.name,
        'ios_version': iosInfo.systemVersion,
        'device_id': iosInfo.identifierForVendor,
        'is_physical_device': iosInfo.isPhysicalDevice,
      });
    }

    // Add memory and performance info
    enrichedContext.addAll({
      'memory_usage': await _getMemoryUsage(),
      'available_storage': await _getAvailableStorage(),
      'battery_level': await _getBatteryLevel(),
      'network_type': await _getNetworkType(),
      'timestamp_utc': report.timestamp.toUtc().toIso8601String(),
    });

    return report.copyWith(context: enrichedContext);
  }

  /// Record custom error with context
  Future<void> recordError(
    String error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
    CrashSeverity severity = CrashSeverity.medium,
    String? userId,
  }) async {
    final report = CrashReport(
      id: _generateReportId(),
      timestamp: DateTime.now(),
      type: CrashType.custom,
      error: error,
      stackTrace: stackTrace?.toString(),
      context: context ?? {},
      severity: severity,
      userId: userId,
    );

    await _processCrashReport(report);
  }

  /// Record non-fatal error
  Future<void> recordNonFatalError(
    String error, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    await recordError(
      error,
      null,
      context: context,
      severity: CrashSeverity.low,
      userId: userId,
    );
  }

  /// Record performance issue
  Future<void> recordPerformanceIssue(
    String issue,
    double value, {
    Map<String, dynamic>? context,
  }) async {
    await recordError(
      'Performance Issue: $issue (value: $value)',
      null,
      context: {
        'performance_metric': issue,
        'value': value,
        ...?context,
      },
      severity: CrashSeverity.low,
    );
  }

  /// Start periodic upload of pending reports
  void _startPeriodicUpload() {
    _uploadTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _uploadPendingReports(),
    );
  }

  /// Upload pending crash reports
  Future<void> _uploadPendingReports() async {
    if (_pendingReports.isEmpty || !await _network.isConnected()) {
      return;
    }

    final reportsToUpload = List<CrashReport>.from(_pendingReports);
    _pendingReports.clear();

    for (final report in reportsToUpload) {
      try {
        await _uploadCrashReport(report);
        await _storage.markCrashReportUploaded(report.id);
      } catch (e) {
        // Re-add to pending if upload failed
        _pendingReports.add(report);
        debugPrint('Failed to upload crash report ${report.id}: $e');
      }
    }
  }

  /// Upload single crash report to server
  Future<void> _uploadCrashReport(CrashReport report) async {
    final reportData = {
      'id': report.id,
      'timestamp': report.timestamp.toIso8601String(),
      'type': report.type.toString(),
      'error': report.error,
      'stack_trace': report.stackTrace,
      'context': report.context,
      'severity': report.severity.toString(),
      'user_id': report.userId,
    };

    await _network.post('/api/crash-reports', reportData);
  }

  /// Get crash statistics
  Future<CrashStatistics> getCrashStatistics() async {
    final reports = await _storage.getCrashReports();
    
    final now = DateTime.now();
    final last24Hours = reports.where(
      (r) => now.difference(r.timestamp).inHours <= 24,
    ).length;
    
    final last7Days = reports.where(
      (r) => now.difference(r.timestamp).inDays <= 7,
    ).length;

    final byType = <CrashType, int>{};
    final bySeverity = <CrashSeverity, int>{};
    
    for (final report in reports) {
      byType[report.type] = (byType[report.type] ?? 0) + 1;
      bySeverity[report.severity] = (bySeverity[report.severity] ?? 0) + 1;
    }

    return CrashStatistics(
      totalCrashes: reports.length,
      crashesLast24Hours: last24Hours,
      crashesLast7Days: last7Days,
      crashesByType: byType,
      crashesBySeverity: bySeverity,
      pendingUploads: _pendingReports.length,
    );
  }

  /// Get recent crash reports
  Future<List<CrashReport>> getRecentCrashReports({int limit = 50}) async {
    return await _storage.getCrashReports(limit: limit);
  }

  // Helper methods
  String _generateReportId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[DateTime.now().millisecond % chars.length]).join();
  }

  CrashSeverity _determineSeverity(Object exception) {
    if (exception is OutOfMemoryError || exception is StackOverflowError) {
      return CrashSeverity.critical;
    } else if (exception is StateError || exception is ArgumentError) {
      return CrashSeverity.high;
    } else if (exception is FormatException || exception is TypeError) {
      return CrashSeverity.medium;
    } else {
      return CrashSeverity.low;
    }
  }

  CrashSeverity _determineSeverityFromError(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('memory') || errorString.contains('overflow')) {
      return CrashSeverity.critical;
    } else if (errorString.contains('null') || errorString.contains('state')) {
      return CrashSeverity.high;
    } else {
      return CrashSeverity.medium;
    }
  }

  Future<double> _getMemoryUsage() async {
    try {
      const platform = MethodChannel('minq/system_info');
      final result = await platform.invokeMethod('getMemoryUsage');
      return (result as num).toDouble();
    } catch (e) {
      return 0;
    }
  }

  Future<double> _getAvailableStorage() async {
    try {
      const platform = MethodChannel('minq/system_info');
      final result = await platform.invokeMethod('getAvailableStorage');
      return (result as num).toDouble();
    } catch (e) {
      return 0;
    }
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

  Future<String> _getNetworkType() async {
    try {
      return await _network.getConnectionType();
    } catch (e) {
      return 'unknown';
    }
  }

  /// Cleanup resources
  void dispose() {
    _uploadTimer?.cancel();
  }
}

/// Crash report data model
class CrashReport {
  final String id;
  final DateTime timestamp;
  final CrashType type;
  final String error;
  final String? stackTrace;
  final Map<String, dynamic> context;
  final CrashSeverity severity;
  final String? userId;

  CrashReport({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.error,
    this.stackTrace,
    required this.context,
    required this.severity,
    this.userId,
  });

  CrashReport copyWith({
    String? id,
    DateTime? timestamp,
    CrashType? type,
    String? error,
    String? stackTrace,
    Map<String, dynamic>? context,
    CrashSeverity? severity,
    String? userId,
  }) {
    return CrashReport(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      context: context ?? this.context,
      severity: severity ?? this.severity,
      userId: userId ?? this.userId,
    );
  }
}

enum CrashType {
  flutter,
  platform,
  async,
  custom,
}

enum CrashSeverity {
  low,
  medium,
  high,
  critical,
}

/// Crash statistics summary
class CrashStatistics {
  final int totalCrashes;
  final int crashesLast24Hours;
  final int crashesLast7Days;
  final Map<CrashType, int> crashesByType;
  final Map<CrashSeverity, int> crashesBySeverity;
  final int pendingUploads;

  CrashStatistics({
    required this.totalCrashes,
    required this.crashesLast24Hours,
    required this.crashesLast7Days,
    required this.crashesByType,
    required this.crashesBySeverity,
    required this.pendingUploads,
  });
}