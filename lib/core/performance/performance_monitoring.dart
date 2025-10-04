
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
  static Future<void> recordMetric(String traceName, String metricName, int value) async {
    final trace = _traces[traceName];
    if (trace != null) {
      await _service.recordMetric(trace, metricName, value);
    }
  }

  /// 属性を設定
  static Future<void> setAttribute(String traceName, String name, String value) async {
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

/// HTTPメソッド
enum HttpMethod {
  Connect,
  Delete,
  Get,
  Head,
  Options,
  Patch,
  Post,
  Put,
  Trace,
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

class Trace {
  void setMetric(String name, int value) {}
  void putAttribute(String name, String value) {}
  Future<void> start() async {}
  Future<void> stop() async {}
}

class HttpMetric {
  int? httpResponseCode;
  int? requestPayloadSize;
  int? responsePayloadSize;
  String? responseContentType;
  
  Future<void> start() async {}
  Future<void> stop() async {}
}

class FirebasePerformance {
  static final instance = FirebasePerformance._();
  FirebasePerformance._();
  
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {}
  Trace newTrace(String name) => Trace();
  HttpMetric newHttpMetric(String url, HttpMethod method) => HttpMetric();
}
