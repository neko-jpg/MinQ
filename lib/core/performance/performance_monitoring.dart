import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// パフォーマンスモニタリングサービス
class PerformanceMonitoringService {
  final FirebasePerformance _performance;

  PerformanceMonitoringService({FirebasePerformance? performance})
    : _performance = performance ?? FirebasePerformance.instance;

  /// 初期化
  Future<void> initialize() async {
    await _performance.setPerformanceCollectionEnabled(true);
  }

  /// カスタムトレースを開始
  Future<Trace> startTrace(String name) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    return trace;
  }

  /// トレースを停止
  Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }

  /// メトリクスを記録
  Future<void> recordMetric(Trace trace, String metricName, int value) async {
    trace.setMetric(metricName, value);
  }

  /// 属性を設定
  Future<void> setAttribute(Trace trace, String name, String value) async {
    trace.putAttribute(name, value);
  }

  /// HTTPメトリクスを記録
  Future<HttpMetric> startHttpMetric(String url, HttpMethod method) async {
    final metric = _performance.newHttpMetric(url, method);
    await metric.start();
    return metric;
  }

  /// HTTPメトリクスを停止
  Future<void> stopHttpMetric(
    HttpMetric metric, {
    int? httpResponseCode,
    int? requestPayloadSize,
    int? responsePayloadSize,
    String? responseContentType,
  }) async {
    if (httpResponseCode != null) {
      metric.httpResponseCode = httpResponseCode;
    }
    if (requestPayloadSize != null) {
      metric.requestPayloadSize = requestPayloadSize;
    }
    if (responsePayloadSize != null) {
      metric.responsePayloadSize = responsePayloadSize;
    }
    if (responseContentType != null) {
      metric.responseContentType = responseContentType;
    }
    await metric.stop();
  }
}

/// パフォーマンストレーサー
class PerformanceTracer {
  static final _service = PerformanceMonitoringService();
  static final Map<String, Trace> _traces = {};

  /// トレースを開始
  static Future<void> start(String name) async {
    final trace = await _service.startTrace(name);
    _traces[name] = trace;
  }

  /// トレースを停止
  static Future<void> stop(String name) async {
    final trace = _traces[name];
    if (trace != null) {
      await _service.stopTrace(trace);
      _traces.remove(name);
    }
  }

  /// メトリクスを記録
  static Future<void> recordMetric(
    String traceName,
    String metricName,
    int value,
  ) async {
    final trace = _traces[traceName];
    if (trace != null) {
      await _service.recordMetric(trace, metricName, value);
    }
  }

  /// 属性を設定
  static Future<void> setAttribute(
    String traceName,
    String name,
    String value,
  ) async {
    final trace = _traces[traceName];
    if (trace != null) {
      await _service.setAttribute(trace, name, value);
    }
  }
}

/// パフォーマンストレース名
class TraceNames {
  static const String appStart = 'app_start';
  static const String firstRender = 'first_render';
  static const String questLoad = 'quest_load';
  static const String questCreate = 'quest_create';
  static const String questComplete = 'quest_complete';
  static const String statsLoad = 'stats_load';
  static const String imageLoad = 'image_load';
  static const String dataSync = 'data_sync';
}

/// パフォーマンスメトリクス
class PerformanceMetrics {
  static const String frameCount = 'frame_count';
  static const String droppedFrames = 'dropped_frames';
  static const String loadTime = 'load_time';
  static const String renderTime = 'render_time';
  static const String networkTime = 'network_time';
  static const String cacheHits = 'cache_hits';
  static const String cacheMisses = 'cache_misses';
}

/// パフォーマンスウォッチャー
class PerformanceWatcher {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();
  Trace? _trace;

  PerformanceWatcher(this.name);

  /// 計測開始
  Future<void> start() async {
    _stopwatch.start();
    _trace = await PerformanceMonitoringService().startTrace(name);
  }

  /// 計測停止
  Future<void> stop() async {
    _stopwatch.stop();
    if (_trace != null) {
      await PerformanceMonitoringService().stopTrace(_trace!);
    }
  }

  /// 経過時間を取得
  Duration get elapsed => _stopwatch.elapsed;

  /// 経過時間（ミリ秒）を取得
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;
}

/// 統合パフォーマンスマネージャー
class IntegratedPerformanceManager {
  static final IntegratedPerformanceManager _instance =
      IntegratedPerformanceManager._internal();
  factory IntegratedPerformanceManager() => _instance;
  IntegratedPerformanceManager._internal();

  final PerformanceMonitoringService _firebasePerformance =
      PerformanceMonitoringService();
  final FrameRateMonitor _frameRateMonitor = FrameRateMonitor();
  final MemoryMonitor _memoryMonitor = MemoryMonitor();
  final NetworkPerformanceMonitor _networkMonitor = NetworkPerformanceMonitor();

  bool _isInitialized = false;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _firebasePerformance.initialize();
    _frameRateMonitor.start();
    _memoryMonitor.start();
    _networkMonitor.start();

    _isInitialized = true;

    if (kDebugMode) {
      print('Integrated Performance Manager initialized');
    }
  }

  /// パフォーマンスレポートを生成
  PerformanceReport generateReport() {
    return PerformanceReport(
      frameRate: _frameRateMonitor.getAverageFrameRate(),
      droppedFrames: _frameRateMonitor.getDroppedFrameCount(),
      memoryUsage: _memoryMonitor.getCurrentMemoryUsage(),
      peakMemoryUsage: _memoryMonitor.getPeakMemoryUsage(),
      networkLatency: _networkMonitor.getAverageLatency(),
      networkErrors: _networkMonitor.getErrorCount(),
      timestamp: DateTime.now(),
    );
  }

  /// 停止
  void stop() {
    _frameRateMonitor.stop();
    _memoryMonitor.stop();
    _networkMonitor.stop();
    _isInitialized = false;
  }
}

/// フレームレート監視
class FrameRateMonitor {
  final List<Duration> _frameTimes = [];
  int _droppedFrames = 0;
  Timer? _monitorTimer;

  void start() {
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);

    _monitorTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _analyzeFrameRate(),
    );
  }

  void _onFrame(Duration timestamp) {
    _frameTimes.add(timestamp);

    // 最新100フレームのみ保持
    if (_frameTimes.length > 100) {
      _frameTimes.removeAt(0);
    }
  }

  void _analyzeFrameRate() {
    if (_frameTimes.length < 2) return;

    int droppedInPeriod = 0;
    for (int i = 1; i < _frameTimes.length; i++) {
      final frameDuration = _frameTimes[i] - _frameTimes[i - 1];

      // 16.67ms（60fps）を大幅に超える場合はドロップフレーム
      if (frameDuration.inMicroseconds > 33340) {
        // 30fps以下
        droppedInPeriod++;
      }
    }

    _droppedFrames += droppedInPeriod;

    if (kDebugMode && droppedInPeriod > 0) {
      print('Dropped frames detected: $droppedInPeriod');
    }
  }

  double getAverageFrameRate() {
    if (_frameTimes.length < 2) return 60.0;

    final totalDuration = _frameTimes.last - _frameTimes.first;
    final frameCount = _frameTimes.length - 1;

    if (totalDuration.inMicroseconds == 0) return 60.0;

    return (frameCount * 1000000) / totalDuration.inMicroseconds;
  }

  int getDroppedFrameCount() => _droppedFrames;

  void stop() {
    // SchedulerBinding.instance.removePersistentFrameCallback(_onFrame);
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }
}

/// メモリ監視
class MemoryMonitor {
  int _currentMemoryUsage = 0;
  int _peakMemoryUsage = 0;
  Timer? _monitorTimer;

  void start() {
    _monitorTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkMemoryUsage(),
    );
  }

  void _checkMemoryUsage() {
    // プラットフォーム固有のメモリ使用量取得（簡略化）
    final usage = _getCurrentMemoryUsage();
    _currentMemoryUsage = usage;

    if (usage > _peakMemoryUsage) {
      _peakMemoryUsage = usage;
    }

    // メモリ使用量が高い場合の警告
    if (usage > 200 * 1024 * 1024) {
      // 200MB以上
      if (kDebugMode) {
        print('High memory usage detected: ${usage ~/ (1024 * 1024)}MB');
      }
    }
  }

  int _getCurrentMemoryUsage() {
    // 実際の実装では ProcessInfo.processInfo.physicalMemory などを使用
    return 50 * 1024 * 1024; // 仮の値: 50MB
  }

  int getCurrentMemoryUsage() => _currentMemoryUsage;
  int getPeakMemoryUsage() => _peakMemoryUsage;

  void stop() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }
}

/// ネットワークパフォーマンス監視
class NetworkPerformanceMonitor {
  final List<Duration> _latencies = [];
  int _errorCount = 0;
  Timer? _monitorTimer;

  void start() {
    _monitorTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _analyzeNetworkPerformance(),
    );
  }

  void recordLatency(Duration latency) {
    _latencies.add(latency);

    // 最新50件のみ保持
    if (_latencies.length > 50) {
      _latencies.removeAt(0);
    }
  }

  void recordError() {
    _errorCount++;
  }

  void _analyzeNetworkPerformance() {
    if (_latencies.isNotEmpty) {
      final avgLatency = getAverageLatency();

      if (avgLatency.inMilliseconds > 2000) {
        // 2秒以上
        if (kDebugMode) {
          print(
            'High network latency detected: ${avgLatency.inMilliseconds}ms',
          );
        }
      }
    }
  }

  Duration getAverageLatency() {
    if (_latencies.isEmpty) return Duration.zero;

    final totalMicroseconds = _latencies.fold<int>(
      0,
      (sum, latency) => sum + latency.inMicroseconds,
    );

    return Duration(microseconds: totalMicroseconds ~/ _latencies.length);
  }

  int getErrorCount() => _errorCount;

  void stop() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }
}

/// パフォーマンスレポート
class PerformanceReport {
  const PerformanceReport({
    required this.frameRate,
    required this.droppedFrames,
    required this.memoryUsage,
    required this.peakMemoryUsage,
    required this.networkLatency,
    required this.networkErrors,
    required this.timestamp,
  });

  final double frameRate;
  final int droppedFrames;
  final int memoryUsage;
  final int peakMemoryUsage;
  final Duration networkLatency;
  final int networkErrors;
  final DateTime timestamp;

  /// パフォーマンススコアを計算（0-100）
  int calculateScore() {
    int score = 100;

    // フレームレートスコア（40%）
    if (frameRate < 30) {
      score -= 40;
    } else if (frameRate < 45) {
      score -= 20;
    } else if (frameRate < 55) {
      score -= 10;
    }

    // メモリ使用量スコア（30%）
    final memoryMB = memoryUsage / (1024 * 1024);
    if (memoryMB > 300) {
      score -= 30;
    } else if (memoryMB > 200) {
      score -= 20;
    } else if (memoryMB > 150) {
      score -= 10;
    }

    // ネットワークレイテンシスコア（20%）
    if (networkLatency.inMilliseconds > 3000) {
      score -= 20;
    } else if (networkLatency.inMilliseconds > 2000) {
      score -= 15;
    } else if (networkLatency.inMilliseconds > 1000) {
      score -= 10;
    }

    // ドロップフレーム・エラースコア（10%）
    if (droppedFrames > 50 || networkErrors > 10) {
      score -= 10;
    } else if (droppedFrames > 20 || networkErrors > 5) {
      score -= 5;
    }

    return score.clamp(0, 100);
  }

  /// レポートを文字列として出力
  @override
  String toString() {
    return '''
Performance Report (${timestamp.toIso8601String()}):
- Frame Rate: ${frameRate.toStringAsFixed(1)} fps
- Dropped Frames: $droppedFrames
- Memory Usage: ${(memoryUsage / (1024 * 1024)).toStringAsFixed(1)} MB
- Peak Memory: ${(peakMemoryUsage / (1024 * 1024)).toStringAsFixed(1)} MB
- Network Latency: ${networkLatency.inMilliseconds} ms
- Network Errors: $networkErrors
- Performance Score: ${calculateScore()}/100
''';
  }
}

/// パフォーマンス最適化ウィジェット
class PerformanceOptimizedWidget extends StatefulWidget {
  const PerformanceOptimizedWidget({
    super.key,
    required this.child,
    this.enableMonitoring = true,
  });

  final Widget child;
  final bool enableMonitoring;

  @override
  State<PerformanceOptimizedWidget> createState() =>
      _PerformanceOptimizedWidgetState();
}

class _PerformanceOptimizedWidgetState
    extends State<PerformanceOptimizedWidget> {
  @override
  void initState() {
    super.initState();

    if (widget.enableMonitoring) {
      IntegratedPerformanceManager().initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: widget.child);
  }
}
