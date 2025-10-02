import 'dart:async';

/// 遅延初期化マネージャー
class LazyInitializationManager {
  final Map<String, Future<void> Function()> _initializers = {};
  final Map<String, bool> _initialized = {};
  final Map<String, Completer<void>> _completers = {};

  /// 初期化関数を登録
  void register(String key, Future<void> Function() initializer) {
    _initializers[key] = initializer;
    _initialized[key] = false;
  }

  /// 初期化を実行
  Future<void> initialize(String key) async {
    if (_initialized[key] == true) return;

    // 既に初期化中の場合は待機
    if (_completers.containsKey(key)) {
      return _completers[key]!.future;
    }

    final completer = Completer<void>();
    _completers[key] = completer;

    try {
      final initializer = _initializers[key];
      if (initializer != null) {
        await initializer();
        _initialized[key] = true;
      }
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _completers.remove(key);
    }
  }

  /// 初期化済みかチェック
  bool isInitialized(String key) {
    return _initialized[key] ?? false;
  }

  /// 全て初期化
  Future<void> initializeAll() async {
    for (final key in _initializers.keys) {
      await initialize(key);
    }
  }
}

/// 初期化優先度
enum InitializationPriority {
  critical, // アプリ起動時に必須
  high, // 最初の画面表示前に必要
  medium, // 最初の画面表示後に必要
  low, // バックグラウンドで初期化可能
}

/// 初期化タスク
class InitializationTask {
  final String key;
  final Future<void> Function() initializer;
  final InitializationPriority priority;
  final List<String> dependencies;

  const InitializationTask({
    required this.key,
    required this.initializer,
    this.priority = InitializationPriority.medium,
    this.dependencies = const [],
  });
}

/// 優先度付き初期化マネージャー
class PrioritizedInitializationManager {
  final LazyInitializationManager _lazyManager = LazyInitializationManager();
  final List<InitializationTask> _tasks = [];

  /// タスクを追加
  void addTask(InitializationTask task) {
    _tasks.add(task);
    _lazyManager.register(task.key, task.initializer);
  }

  /// 優先度順に初期化
  Future<void> initializeByPriority(InitializationPriority priority) async {
    final tasks = _tasks
        .where((task) => task.priority == priority)
        .toList();

    for (final task in tasks) {
      // 依存関係を先に初期化
      for (final dep in task.dependencies) {
        await _lazyManager.initialize(dep);
      }

      await _lazyManager.initialize(task.key);
    }
  }

  /// 段階的に初期化
  Future<void> initializeStaged() async {
    // Critical: アプリ起動時
    await initializeByPriority(InitializationPriority.critical);

    // High: 最初の画面表示前
    await initializeByPriority(InitializationPriority.high);

    // Medium: 最初の画面表示後（非同期）
    unawaited(initializeByPriority(InitializationPriority.medium));

    // Low: バックグラウンド（非同期）
    unawaited(initializeByPriority(InitializationPriority.low));
  }
}

/// 画像プリフェッチャー
class ImagePrefetcher {
  final List<String> _prefetchedImages = [];

  /// 画像をプリフェッチ
  Future<void> prefetch(BuildContext context, List<String> imageUrls) async {
    for (final url in imageUrls) {
      if (_prefetchedImages.contains(url)) continue;

      try {
        await precacheImage(NetworkImage(url), context);
        _prefetchedImages.add(url);
      } catch (e) {
        print('Failed to prefetch image: $url');
      }
    }
  }

  /// クリア
  void clear() {
    _prefetchedImages.clear();
  }
}

/// 起動時間計測
class StartupTimer {
  DateTime? _startTime;
  final Map<String, Duration> _milestones = {};

  /// 計測開始
  void start() {
    _startTime = DateTime.now();
  }

  /// マイルストーンを記録
  void recordMilestone(String name) {
    if (_startTime == null) return;
    _milestones[name] = DateTime.now().difference(_startTime!);
  }

  /// 結果を取得
  Map<String, Duration> getResults() {
    return Map.unmodifiable(_milestones);
  }

  /// 総起動時間を取得
  Duration? getTotalTime() {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!);
  }
}

void unawaited(Future<void> future) {
  // 意図的に待機しない
}

class BuildContext {}
class NetworkImage {
  NetworkImage(String url);
}
Future<void> precacheImage(NetworkImage image, BuildContext context) async {}
