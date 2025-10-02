import 'dart:collection';

/// ユーザートークン制Rate Limiter
/// 機能乱用対策
class RateLimiter {
  final Map<String, TokenBucket> _buckets = {};

  /// アクションを実行可能かチェック
  Future<RateLimitResult> checkLimit({
    required String userId,
    required String action,
    RateLimitConfig? config,
  }) async {
    final key = '$userId:$action';
    final bucket = _buckets.putIfAbsent(
      key,
      () => TokenBucket(config ?? RateLimitConfig.defaultConfig),
    );

    return bucket.consume();
  }

  /// レート制限をリセット
  void reset(String userId, String action) {
    final key = '$userId:$action';
    _buckets.remove(key);
  }

  /// すべてのレート制限をクリア
  void clearAll() {
    _buckets.clear();
  }

  /// 統計情報を取得
  Map<String, dynamic> getStats() {
    return {
      'totalBuckets': _buckets.length,
      'buckets': _buckets.map((key, bucket) => MapEntry(key, bucket.getStats())),
    };
  }
}

/// トークンバケットアルゴリズム
class TokenBucket {
  final RateLimitConfig config;
  double _tokens;
  DateTime _lastRefill;

  TokenBucket(this.config)
      : _tokens = config.capacity.toDouble(),
        _lastRefill = DateTime.now();

  /// トークンを消費
  RateLimitResult consume({int tokens = 1}) {
    _refill();

    if (_tokens >= tokens) {
      _tokens -= tokens;
      return RateLimitResult.allowed(
        remainingTokens: _tokens.toInt(),
        resetAt: _calculateResetTime(),
      );
    }

    return RateLimitResult.limited(
      retryAfter: _calculateRetryAfter(),
      resetAt: _calculateResetTime(),
    );
  }

  /// トークンを補充
  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill);
    final tokensToAdd = (elapsed.inSeconds / config.refillInterval.inSeconds) * config.refillRate;

    _tokens = (_tokens + tokensToAdd).clamp(0, config.capacity.toDouble());
    _lastRefill = now;
  }

  /// リセット時刻を計算
  DateTime _calculateResetTime() {
    final secondsUntilFull = ((config.capacity - _tokens) / config.refillRate) * config.refillInterval.inSeconds;
    return DateTime.now().add(Duration(seconds: secondsUntilFull.toInt()));
  }

  /// リトライまでの時間を計算
  Duration _calculateRetryAfter() {
    final secondsUntilToken = (1 / config.refillRate) * config.refillInterval.inSeconds;
    return Duration(seconds: secondsUntilToken.toInt());
  }

  /// 統計情報を取得
  Map<String, dynamic> getStats() {
    return {
      'tokens': _tokens.toInt(),
      'capacity': config.capacity,
      'lastRefill': _lastRefill.toIso8601String(),
    };
  }
}

/// レート制限設定
class RateLimitConfig {
  final int capacity;        // バケット容量
  final int refillRate;      // 補充レート（トークン数）
  final Duration refillInterval; // 補充間隔

  const RateLimitConfig({
    required this.capacity,
    required this.refillRate,
    required this.refillInterval,
  });

  /// デフォルト設定（10リクエスト/分）
  static const defaultConfig = RateLimitConfig(
    capacity: 10,
    refillRate: 1,
    refillInterval: Duration(seconds: 6),
  );

  /// 厳しい制限（5リクエスト/分）
  static const strictConfig = RateLimitConfig(
    capacity: 5,
    refillRate: 1,
    refillInterval: Duration(seconds: 12),
  );

  /// 緩い制限（30リクエスト/分）
  static const lenientConfig = RateLimitConfig(
    capacity: 30,
    refillRate: 1,
    refillInterval: Duration(seconds: 2),
  );

  /// クエスト作成用（10個/時間）
  static const questCreationConfig = RateLimitConfig(
    capacity: 10,
    refillRate: 1,
    refillInterval: Duration(minutes: 6),
  );

  /// クエスト完了用（100個/日）
  static const questCompletionConfig = RateLimitConfig(
    capacity: 100,
    refillRate: 1,
    refillInterval: Duration(minutes: 14, seconds: 24),
  );

  /// ペアマッチング用（5回/時間）
  static const pairMatchingConfig = RateLimitConfig(
    capacity: 5,
    refillRate: 1,
    refillInterval: Duration(minutes: 12),
  );

  /// メッセージ送信用（20個/分）
  static const messageSendConfig = RateLimitConfig(
    capacity: 20,
    refillRate: 1,
    refillInterval: Duration(seconds: 3),
  );
}

/// レート制限結果
class RateLimitResult {
  final bool allowed;
  final int? remainingTokens;
  final Duration? retryAfter;
  final DateTime? resetAt;

  const RateLimitResult._({
    required this.allowed,
    this.remainingTokens,
    this.retryAfter,
    this.resetAt,
  });

  factory RateLimitResult.allowed({
    required int remainingTokens,
    required DateTime resetAt,
  }) {
    return RateLimitResult._(
      allowed: true,
      remainingTokens: remainingTokens,
      resetAt: resetAt,
    );
  }

  factory RateLimitResult.limited({
    required Duration retryAfter,
    required DateTime resetAt,
  }) {
    return RateLimitResult._(
      allowed: false,
      retryAfter: retryAfter,
      resetAt: resetAt,
    );
  }
}

/// アクション定義
class RateLimitActions {
  const RateLimitActions._();

  static const questCreate = 'quest_create';
  static const questComplete = 'quest_complete';
  static const questDelete = 'quest_delete';
  static const pairMatch = 'pair_match';
  static const pairMessage = 'pair_message';
  static const dataExport = 'data_export';
  static const feedbackSubmit = 'feedback_submit';
  static const reportUser = 'report_user';
}

/// レート制限エラー
class RateLimitException implements Exception {
  final String message;
  final Duration retryAfter;

  const RateLimitException({
    required this.message,
    required this.retryAfter,
  });

  @override
  String toString() {
    return 'RateLimitException: $message (retry after ${retryAfter.inSeconds}s)';
  }
}

/// レート制限ミドルウェア
class RateLimitMiddleware {
  final RateLimiter _limiter;

  RateLimitMiddleware(this._limiter);

  /// アクションを実行（レート制限付き）
  Future<T> execute<T>({
    required String userId,
    required String action,
    required Future<T> Function() callback,
    RateLimitConfig? config,
  }) async {
    final result = await _limiter.checkLimit(
      userId: userId,
      action: action,
      config: config,
    );

    if (!result.allowed) {
      throw RateLimitException(
        message: 'レート制限に達しました',
        retryAfter: result.retryAfter!,
      );
    }

    return callback();
  }
}

/// レート制限統計
class RateLimitStats {
  final Map<String, int> _actionCounts = {};
  final Map<String, int> _limitedCounts = {};

  /// アクションを記録
  void recordAction(String action, bool allowed) {
    _actionCounts[action] = (_actionCounts[action] ?? 0) + 1;
    if (!allowed) {
      _limitedCounts[action] = (_limitedCounts[action] ?? 0) + 1;
    }
  }

  /// 統計を取得
  Map<String, dynamic> getStats() {
    return {
      'totalActions': _actionCounts.values.fold(0, (a, b) => a + b),
      'totalLimited': _limitedCounts.values.fold(0, (a, b) => a + b),
      'actionCounts': Map.unmodifiable(_actionCounts),
      'limitedCounts': Map.unmodifiable(_limitedCounts),
    };
  }

  /// 統計をリセット
  void reset() {
    _actionCounts.clear();
    _limitedCounts.clear();
  }
}
