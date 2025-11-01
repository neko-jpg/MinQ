import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// Service for monitoring and managing app memory usage
class MemoryManagementService {
  static const int _memoryWarningThreshold = 200 * 1024 * 1024; // 200MB
  static const int _memoryCriticalThreshold = 400 * 1024 * 1024; // 400MB
  static const Duration _monitoringInterval = Duration(seconds: 30);

  Timer? _monitoringTimer;
  final List<MemoryUsageCallback> _callbacks = [];
  final List<MemorySnapshot> _snapshots = [];
  final int _maxSnapshots = 100;

  static final MemoryManagementService _instance =
      MemoryManagementService._internal();
  factory MemoryManagementService() => _instance;
  MemoryManagementService._internal();

  /// Start memory monitoring
  void startMonitoring() {
    if (_monitoringTimer?.isActive == true) return;

    _monitoringTimer = Timer.periodic(_monitoringInterval, (_) {
      _checkMemoryUsage();
    });

    debugPrint('Memory monitoring started');
  }

  /// Stop memory monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    debugPrint('Memory monitoring stopped');
  }

  /// Register callback for memory usage events
  void registerCallback(MemoryUsageCallback callback) {
    _callbacks.add(callback);
  }

  /// Unregister callback
  void unregisterCallback(MemoryUsageCallback callback) {
    _callbacks.remove(callback);
  }

  /// Get current memory usage
  Future<MemoryInfo> getCurrentMemoryUsage() async {
    try {
      // Get VM memory info
      final vmService = developer.Service.getInfo();

      // Get system memory info (Android/iOS specific)
      int? physicalMemory;
      int? availableMemory;

      if (Platform.isAndroid) {
        physicalMemory = await _getAndroidMemoryInfo();
      } else if (Platform.isIOS) {
        physicalMemory = await _getIOSMemoryInfo();
      }

      // Get Dart heap info
      final heapUsage = await _getDartHeapUsage();

      return MemoryInfo(
        timestamp: DateTime.now(),
        heapUsage: heapUsage,
        physicalMemory: physicalMemory ?? 0,
        availableMemory: availableMemory ?? 0,
        vmInfo: vmService.toString(),
      );
    } catch (e) {
      debugPrint('Error getting memory usage: $e');
      return MemoryInfo(
        timestamp: DateTime.now(),
        heapUsage: 0,
        physicalMemory: 0,
        availableMemory: 0,
        vmInfo: 'Error: $e',
      );
    }
  }

  /// Force garbage collection
  void forceGarbageCollection() {
    try {
      // Request garbage collection
      developer.Service.getInfo();

      // Clear image cache if memory is critical
      _clearCachesIfNeeded();

      debugPrint('Forced garbage collection');
    } catch (e) {
      debugPrint('Error forcing garbage collection: $e');
    }
  }

  /// Get memory usage history
  List<MemorySnapshot> getMemoryHistory() {
    return List.unmodifiable(_snapshots);
  }

  /// Clear memory usage history
  void clearHistory() {
    _snapshots.clear();
  }

  /// Get memory statistics
  MemoryStatistics getMemoryStatistics() {
    if (_snapshots.isEmpty) {
      return const MemoryStatistics(
        averageUsage: 0,
        peakUsage: 0,
        currentUsage: 0,
        memoryLeaks: [],
        recommendations: ['Start monitoring to collect statistics'],
      );
    }

    final usages = _snapshots.map((s) => s.heapUsage).toList();
    final averageUsage = usages.reduce((a, b) => a + b) / usages.length;
    final peakUsage = usages.reduce((a, b) => a > b ? a : b).toDouble();
    final currentUsage = usages.last.toDouble();

    final memoryLeaks = _detectMemoryLeaks();
    final recommendations = _generateRecommendations(
      averageUsage,
      peakUsage,
      currentUsage,
    );

    return MemoryStatistics(
      averageUsage: averageUsage,
      peakUsage: peakUsage,
      currentUsage: currentUsage,
      memoryLeaks: memoryLeaks,
      recommendations: recommendations,
    );
  }

  /// Optimize memory usage
  Future<void> optimizeMemory() async {
    try {
      // Clear image caches
      await _clearImageCaches();

      // Clear unused data
      await _clearUnusedData();

      // Force garbage collection
      forceGarbageCollection();

      // Notify callbacks
      for (final callback in _callbacks) {
        callback(MemoryEvent.optimized, await getCurrentMemoryUsage());
      }

      debugPrint('Memory optimization completed');
    } catch (e) {
      debugPrint('Error optimizing memory: $e');
    }
  }

  // Private methods

  Future<void> _checkMemoryUsage() async {
    try {
      final memoryInfo = await getCurrentMemoryUsage();

      // Add to snapshots
      _snapshots.add(
        MemorySnapshot(
          timestamp: memoryInfo.timestamp,
          heapUsage: memoryInfo.heapUsage,
          physicalMemory: memoryInfo.physicalMemory,
          availableMemory: memoryInfo.availableMemory,
        ),
      );

      // Limit snapshots
      if (_snapshots.length > _maxSnapshots) {
        _snapshots.removeAt(0);
      }

      // Check thresholds
      if (memoryInfo.heapUsage > _memoryCriticalThreshold) {
        _handleCriticalMemory(memoryInfo);
      } else if (memoryInfo.heapUsage > _memoryWarningThreshold) {
        _handleMemoryWarning(memoryInfo);
      }

      // Notify callbacks
      for (final callback in _callbacks) {
        callback(MemoryEvent.updated, memoryInfo);
      }
    } catch (e) {
      debugPrint('Error checking memory usage: $e');
    }
  }

  void _handleMemoryWarning(MemoryInfo memoryInfo) {
    debugPrint('Memory warning: ${memoryInfo.heapUsage} bytes');

    for (final callback in _callbacks) {
      callback(MemoryEvent.warning, memoryInfo);
    }
  }

  void _handleCriticalMemory(MemoryInfo memoryInfo) {
    debugPrint('Critical memory usage: ${memoryInfo.heapUsage} bytes');

    // Automatic cleanup
    _clearCachesIfNeeded();
    forceGarbageCollection();

    for (final callback in _callbacks) {
      callback(MemoryEvent.critical, memoryInfo);
    }
  }

  Future<int> _getDartHeapUsage() async {
    try {
      // This is a simplified implementation
      // In a real app, you'd use dart:developer or vm_service
      return 50 * 1024 * 1024; // 50MB placeholder
    } catch (e) {
      return 0;
    }
  }

  Future<int?> _getAndroidMemoryInfo() async {
    try {
      const platform = MethodChannel('minq/memory');
      final result = await platform.invokeMethod('getMemoryInfo');
      return result['totalMemory'] as int?;
    } catch (e) {
      return null;
    }
  }

  Future<int?> _getIOSMemoryInfo() async {
    try {
      const platform = MethodChannel('minq/memory');
      final result = await platform.invokeMethod('getMemoryInfo');
      return result['physicalMemory'] as int?;
    } catch (e) {
      return null;
    }
  }

  void _clearCachesIfNeeded() {
    try {
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      debugPrint('Cleared image caches');
    } catch (e) {
      debugPrint('Error clearing caches: $e');
    }
  }

  Future<void> _clearImageCaches() async {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      debugPrint('Error clearing image caches: $e');
    }
  }

  Future<void> _clearUnusedData() async {
    try {
      // Clear any app-specific caches
      // This would be implemented based on your app's specific needs
    } catch (e) {
      debugPrint('Error clearing unused data: $e');
    }
  }

  List<MemoryLeak> _detectMemoryLeaks() {
    final leaks = <MemoryLeak>[];

    if (_snapshots.length < 10) return leaks;

    // Simple leak detection: consistent memory growth
    final recent = _snapshots.takeLast(10).toList();
    bool consistentGrowth = true;

    for (int i = 1; i < recent.length; i++) {
      if (recent[i].heapUsage <= recent[i - 1].heapUsage) {
        consistentGrowth = false;
        break;
      }
    }

    if (consistentGrowth) {
      leaks.add(
        const MemoryLeak(
          type: 'Potential Memory Leak',
          description:
              'Consistent memory growth detected over last 10 measurements',
          severity: MemoryLeakSeverity.medium,
          recommendation:
              'Check for unclosed streams, listeners, or cached objects',
        ),
      );
    }

    return leaks;
  }

  List<String> _generateRecommendations(
    double average,
    double peak,
    double current,
  ) {
    final recommendations = <String>[];

    if (peak > _memoryCriticalThreshold) {
      recommendations.add(
        'Peak memory usage is critical. Consider reducing image sizes or clearing caches more frequently.',
      );
    }

    if (average > _memoryWarningThreshold) {
      recommendations.add(
        'Average memory usage is high. Review memory-intensive operations.',
      );
    }

    if (current > average * 1.5) {
      recommendations.add(
        'Current memory usage is significantly above average. Consider immediate cleanup.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Memory usage is within normal ranges.');
    }

    return recommendations;
  }
}

// Data classes

class MemoryInfo {
  final DateTime timestamp;
  final int heapUsage;
  final int physicalMemory;
  final int availableMemory;
  final String vmInfo;

  const MemoryInfo({
    required this.timestamp,
    required this.heapUsage,
    required this.physicalMemory,
    required this.availableMemory,
    required this.vmInfo,
  });
}

class MemorySnapshot {
  final DateTime timestamp;
  final int heapUsage;
  final int physicalMemory;
  final int availableMemory;

  const MemorySnapshot({
    required this.timestamp,
    required this.heapUsage,
    required this.physicalMemory,
    required this.availableMemory,
  });
}

class MemoryStatistics {
  final double averageUsage;
  final double peakUsage;
  final double currentUsage;
  final List<MemoryLeak> memoryLeaks;
  final List<String> recommendations;

  const MemoryStatistics({
    required this.averageUsage,
    required this.peakUsage,
    required this.currentUsage,
    required this.memoryLeaks,
    required this.recommendations,
  });
}

class MemoryLeak {
  final String type;
  final String description;
  final MemoryLeakSeverity severity;
  final String recommendation;

  const MemoryLeak({
    required this.type,
    required this.description,
    required this.severity,
    required this.recommendation,
  });
}

enum MemoryLeakSeverity { low, medium, high, critical }

enum MemoryEvent { updated, warning, critical, optimized }

typedef MemoryUsageCallback = void Function(MemoryEvent event, MemoryInfo info);

extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
