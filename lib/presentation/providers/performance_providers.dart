import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/performance/battery_optimization_service.dart';
import 'package:minq/core/performance/image_optimization_service.dart';
import 'package:minq/core/performance/lazy_loading_service.dart';
import 'package:minq/core/performance/memory_management_service.dart';
import 'package:minq/core/performance/network_optimization_service.dart';
import 'package:minq/core/performance/performance_monitoring_service.dart';
import 'package:minq/core/performance/performance_settings_service.dart';
import 'package:minq/core/performance/startup_optimization_service.dart';

// Service providers
final performanceMonitoringServiceProvider =
    Provider<PerformanceMonitoringService>((ref) {
      return PerformanceMonitoringService();
    });

final memoryManagementServiceProvider = Provider<MemoryManagementService>((
  ref,
) {
  return MemoryManagementService();
});

final batteryOptimizationServiceProvider = Provider<BatteryOptimizationService>(
  (ref) {
    return BatteryOptimizationService();
  },
);

final imageOptimizationServiceProvider = Provider<ImageOptimizationService>((
  ref,
) {
  return ImageOptimizationService();
});

final startupOptimizationServiceProvider = Provider<StartupOptimizationService>(
  (ref) {
    return StartupOptimizationService();
  },
);

final networkOptimizationServiceProvider = Provider<NetworkOptimizationService>(
  (ref) {
    return NetworkOptimizationService();
  },
);

final lazyLoadingServiceProvider = Provider<LazyLoadingService>((ref) {
  return LazyLoadingService();
});

final performanceSettingsServiceProvider = Provider<PerformanceSettingsService>(
  (ref) {
    return PerformanceSettingsService();
  },
);

// Performance metrics providers
final currentPerformanceMetricsProvider = FutureProvider<PerformanceSnapshot>((
  ref,
) async {
  final service = ref.read(performanceMonitoringServiceProvider);
  return service.getCurrentMetrics();
});

final performanceStatisticsProvider = FutureProvider<PerformanceStatistics>((
  ref,
) async {
  final service = ref.read(performanceMonitoringServiceProvider);
  return service.getPerformanceStatistics();
});

final performanceHistoryProvider =
    FutureProvider.family<List<PerformanceMetric>, Duration?>((
      ref,
      timeRange,
    ) async {
      final service = ref.read(performanceMonitoringServiceProvider);
      return service.getPerformanceHistory(timeRange: timeRange);
    });

// Memory providers
final currentMemoryUsageProvider = FutureProvider<MemoryInfo>((ref) async {
  final service = ref.read(memoryManagementServiceProvider);
  return service.getCurrentMemoryUsage();
});

final memoryStatisticsProvider = FutureProvider<MemoryStatistics>((ref) async {
  final service = ref.read(memoryManagementServiceProvider);
  return service.getMemoryStatistics();
});

final memoryHistoryProvider = FutureProvider<List<MemorySnapshot>>((ref) async {
  final service = ref.read(memoryManagementServiceProvider);
  return service.getMemoryHistory();
});

// Battery providers
final currentBatteryInfoProvider = FutureProvider<BatteryInfo>((ref) async {
  final service = ref.read(batteryOptimizationServiceProvider);
  return service.getCurrentBatteryInfo();
});

final batteryUsageStatsProvider = FutureProvider<BatteryUsageStats>((
  ref,
) async {
  final service = ref.read(batteryOptimizationServiceProvider);
  return service.getBatteryUsageStats();
});

// Performance optimization state providers
final performanceOptimizationStateProvider = StateNotifierProvider<
  PerformanceOptimizationNotifier,
  PerformanceOptimizationState
>((ref) {
  return PerformanceOptimizationNotifier(
    ref.read(performanceMonitoringServiceProvider),
    ref.read(memoryManagementServiceProvider),
    ref.read(batteryOptimizationServiceProvider),
  );
});

// Performance optimization state
class PerformanceOptimizationState {
  final bool isMonitoring;
  final bool isMemoryOptimizationEnabled;
  final bool isBatteryOptimizationEnabled;
  final bool isImageOptimizationEnabled;
  final PerformanceMode performanceMode;
  final List<String> activeOptimizations;

  const PerformanceOptimizationState({
    this.isMonitoring = false,
    this.isMemoryOptimizationEnabled = true,
    this.isBatteryOptimizationEnabled = true,
    this.isImageOptimizationEnabled = true,
    this.performanceMode = PerformanceMode.balanced,
    this.activeOptimizations = const [],
  });

  PerformanceOptimizationState copyWith({
    bool? isMonitoring,
    bool? isMemoryOptimizationEnabled,
    bool? isBatteryOptimizationEnabled,
    bool? isImageOptimizationEnabled,
    PerformanceMode? performanceMode,
    List<String>? activeOptimizations,
  }) {
    return PerformanceOptimizationState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      isMemoryOptimizationEnabled:
          isMemoryOptimizationEnabled ?? this.isMemoryOptimizationEnabled,
      isBatteryOptimizationEnabled:
          isBatteryOptimizationEnabled ?? this.isBatteryOptimizationEnabled,
      isImageOptimizationEnabled:
          isImageOptimizationEnabled ?? this.isImageOptimizationEnabled,
      performanceMode: performanceMode ?? this.performanceMode,
      activeOptimizations: activeOptimizations ?? this.activeOptimizations,
    );
  }
}

enum PerformanceMode {
  performance, // High performance, higher battery usage
  balanced, // Balanced performance and battery
  battery, // Battery saving, reduced performance
}

// Performance optimization notifier
class PerformanceOptimizationNotifier
    extends StateNotifier<PerformanceOptimizationState> {
  final PerformanceMonitoringService _performanceService;
  final MemoryManagementService _memoryService;
  final BatteryOptimizationService _batteryService;

  PerformanceOptimizationNotifier(
    this._performanceService,
    this._memoryService,
    this._batteryService,
  ) : super(const PerformanceOptimizationState()) {
    _initialize();
  }

  void _initialize() {
    // Register callbacks for performance events
    _performanceService.registerCallback(_onPerformanceEvent);
    _memoryService.registerCallback(_onMemoryEvent);
    _batteryService.registerCallback(_onBatteryEvent);
  }

  void _onPerformanceEvent(PerformanceEventType type, dynamic data) {
    switch (type) {
      case PerformanceEventType.lowFrameRate:
        _handleLowFrameRate();
        break;
      case PerformanceEventType.highCPUUsage:
        _handleHighCPUUsage();
        break;
      case PerformanceEventType.memoryWarning:
        _handleMemoryWarning();
        break;
      default:
        break;
    }
  }

  void _onMemoryEvent(MemoryEvent event, MemoryInfo info) {
    switch (event) {
      case MemoryEvent.warning:
        _handleMemoryWarning();
        break;
      case MemoryEvent.critical:
        _handleCriticalMemory();
        break;
      default:
        break;
    }
  }

  void _onBatteryEvent(BatteryEvent event, BatteryInfo info) {
    switch (event) {
      case BatteryEvent.lowBattery:
        _handleLowBattery();
        break;
      case BatteryEvent.criticalBattery:
        _handleCriticalBattery();
        break;
      default:
        break;
    }
  }

  // Public methods

  void startMonitoring() {
    if (state.isMonitoring) return;

    _performanceService.startMonitoring();
    _memoryService.startMonitoring();

    state = state.copyWith(isMonitoring: true);
  }

  void stopMonitoring() {
    if (!state.isMonitoring) return;

    _performanceService.stopMonitoring();
    _memoryService.stopMonitoring();

    state = state.copyWith(isMonitoring: false);
  }

  void setPerformanceMode(PerformanceMode mode) {
    state = state.copyWith(performanceMode: mode);
    _applyPerformanceMode(mode);
  }

  void setMemoryOptimizationEnabled(bool enabled) {
    state = state.copyWith(isMemoryOptimizationEnabled: enabled);

    if (enabled) {
      _memoryService.startMonitoring();
    } else {
      _memoryService.stopMonitoring();
    }
  }

  void setBatteryOptimizationEnabled(bool enabled) {
    state = state.copyWith(isBatteryOptimizationEnabled: enabled);
    _batteryService.setOptimizationEnabled(enabled);
  }

  void setImageOptimizationEnabled(bool enabled) {
    state = state.copyWith(isImageOptimizationEnabled: enabled);
  }

  Future<void> optimizePerformance() async {
    final optimizations = <String>[];

    // Memory optimization
    if (state.isMemoryOptimizationEnabled) {
      await _memoryService.optimizeMemory();
      optimizations.add('Memory optimized');
    }

    // Battery optimization
    if (state.isBatteryOptimizationEnabled) {
      await _batteryService.optimizeBatteryUsage();
      optimizations.add('Battery optimized');
    }

    // Image cache optimization
    if (state.isImageOptimizationEnabled) {
      final imageService = ImageOptimizationService();
      imageService.clearMemoryCache();
      optimizations.add('Image cache cleared');
    }

    state = state.copyWith(activeOptimizations: optimizations);

    // Clear optimizations after a delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        state = state.copyWith(activeOptimizations: []);
      }
    });
  }

  Future<void> forceGarbageCollection() async {
    _memoryService.forceGarbageCollection();

    state = state.copyWith(activeOptimizations: ['Garbage collection forced']);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.copyWith(activeOptimizations: []);
      }
    });
  }

  // Private methods

  void _applyPerformanceMode(PerformanceMode mode) {
    switch (mode) {
      case PerformanceMode.performance:
        _applyPerformanceMode_Performance();
        break;
      case PerformanceMode.balanced:
        _applyPerformanceMode_Balanced();
        break;
      case PerformanceMode.battery:
        _applyPerformanceMode_Battery();
        break;
    }
  }

  void _applyPerformanceMode_Performance() {
    // High performance settings
    _batteryService.setOptimizationEnabled(false);
    // Enable high-quality animations
    // Disable aggressive memory management
  }

  void _applyPerformanceMode_Balanced() {
    // Balanced settings
    _batteryService.setOptimizationEnabled(true);
    // Moderate animation quality
    // Standard memory management
  }

  void _applyPerformanceMode_Battery() {
    // Battery saving settings
    _batteryService.setOptimizationEnabled(true);
    _batteryService.enableLowPowerMode();
    // Reduce animation quality
    // Aggressive memory management
  }

  void _handleLowFrameRate() {
    if (state.performanceMode != PerformanceMode.battery) {
      // Suggest reducing visual effects
      state = state.copyWith(
        activeOptimizations: [
          'Low frame rate detected - consider reducing visual effects',
        ],
      );
    }
  }

  void _handleHighCPUUsage() {
    // Suggest performance optimizations
    state = state.copyWith(
      activeOptimizations: [
        'High CPU usage detected - optimizing background tasks',
      ],
    );
  }

  void _handleMemoryWarning() {
    if (state.isMemoryOptimizationEnabled) {
      _memoryService.forceGarbageCollection();
      state = state.copyWith(
        activeOptimizations: ['Memory warning - clearing caches'],
      );
    }
  }

  void _handleCriticalMemory() {
    // Force aggressive memory cleanup
    _memoryService.optimizeMemory();
    final imageService = ImageOptimizationService();
    imageService.clearMemoryCache();

    state = state.copyWith(
      activeOptimizations: ['Critical memory - aggressive cleanup performed'],
    );
  }

  void _handleLowBattery() {
    if (state.isBatteryOptimizationEnabled &&
        state.performanceMode != PerformanceMode.battery) {
      setPerformanceMode(PerformanceMode.battery);
      state = state.copyWith(
        activeOptimizations: ['Low battery - switched to battery saving mode'],
      );
    }
  }

  void _handleCriticalBattery() {
    if (state.isBatteryOptimizationEnabled) {
      _batteryService.enableLowPowerMode();
      state = state.copyWith(
        activeOptimizations: ['Critical battery - low power mode enabled'],
      );
    }
  }
}

// Performance report provider
final performanceReportProvider =
    FutureProvider.family<PerformanceReport, Duration?>((ref, timeRange) async {
      final service = ref.read(performanceMonitoringServiceProvider);
      return service.generateReport(timeRange: timeRange);
    });

// Image cache statistics provider
final imageCacheStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.read(imageOptimizationServiceProvider);
  return service.getCacheStats();
});

// Startup optimization providers
final startupMetricsProvider = FutureProvider<StartupMetrics>((ref) async {
  final service = ref.read(startupOptimizationServiceProvider);
  return service.getStartupMetrics();
});

final startupRecommendationsProvider = FutureProvider<List<String>>((
  ref,
) async {
  final service = ref.read(startupOptimizationServiceProvider);
  return service.getStartupRecommendations();
});

// Network optimization providers
final networkCacheStatsProvider = FutureProvider<NetworkCacheStats>((
  ref,
) async {
  final service = ref.read(networkOptimizationServiceProvider);
  return service.getCacheStats();
});

final networkUsageStatsProvider = FutureProvider<NetworkUsageStats>((
  ref,
) async {
  final service = ref.read(networkOptimizationServiceProvider);
  return service.getUsageStats();
});

// Lazy loading providers
final lazyLoadingStatsProvider = FutureProvider<LazyLoadingStats>((ref) async {
  final service = ref.read(lazyLoadingServiceProvider);
  return service.getStats();
});

// Performance settings providers
final performanceSettingsProvider = FutureProvider<PerformanceSettings>((
  ref,
) async {
  final service = ref.read(performanceSettingsServiceProvider);
  return service.getSettings();
});

final performanceRecommendationsProvider =
    FutureProvider<List<PerformanceRecommendation>>((ref) async {
      final service = ref.read(performanceSettingsServiceProvider);
      return service.getRecommendations();
    });
