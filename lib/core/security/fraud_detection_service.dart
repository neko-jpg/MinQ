import 'package:minq/core/logging/app_logger.dart';

/// 不正利用検出サービス
/// 短時間での大量クエスト完了などの異常な行動を検出
class FraudDetectionService {
  final AppLogger _logger;

  FraudDetectionService(this._logger);

  // 検出閾値
  static const int _maxQuestsPerHour = 20;
  static const int _maxQuestsPerDay = 100;
  static const Duration _suspiciousCompletionWindow = Duration(minutes: 5);
  static const int _suspiciousCompletionCount = 10;

  /// クエスト完了の不正検出
  Future<FraudDetectionResult> detectQuestCompletionFraud({
    required String userId,
    required List<DateTime> recentCompletions,
  }) async {
    try {
      final now = DateTime.now();

      // 1時間以内の完了数をチェック
      final lastHourCompletions =
          recentCompletions
              .where((time) => now.difference(time) < const Duration(hours: 1))
              .length;

      if (lastHourCompletions > _maxQuestsPerHour) {
        _logger.warning(
          'Suspicious activity detected: $lastHourCompletions quests in 1 hour',
          metadata: {'userId': userId},
        );
        return FraudDetectionResult.suspicious(
          reason:
              '1時間に$lastHourCompletions個のクエストを完了しました（上限: $_maxQuestsPerHour）',
          severity: FraudSeverity.medium,
          action: FraudAction.warning,
        );
      }

      // 1日以内の完了数をチェック
      final lastDayCompletions =
          recentCompletions
              .where((time) => now.difference(time) < const Duration(days: 1))
              .length;

      if (lastDayCompletions > _maxQuestsPerDay) {
        _logger.warning(
          'Suspicious activity detected: $lastDayCompletions quests in 1 day',
          metadata: {'userId': userId},
        );
        return FraudDetectionResult.suspicious(
          reason: '1日に$lastDayCompletions個のクエストを完了しました（上限: $_maxQuestsPerDay）',
          severity: FraudSeverity.high,
          action: FraudAction.temporaryBlock,
        );
      }

      // 短時間での連続完了をチェック
      final suspiciousPattern = _detectSuspiciousPattern(recentCompletions);
      if (suspiciousPattern != null) {
        _logger.warning(
          'Suspicious pattern detected',
          metadata: {'userId': userId, 'pattern': suspiciousPattern},
        );
        return FraudDetectionResult.suspicious(
          reason: '短時間に連続してクエストを完了しています',
          severity: FraudSeverity.medium,
          action: FraudAction.warning,
        );
      }

      return FraudDetectionResult.clean();
    } catch (e, stack) {
      _logger.error('Fraud detection failed', error: e, stackTrace: stack);
      return FraudDetectionResult.clean(); // エラー時は通常動作を許可
    }
  }

  /// 疑わしいパターンを検出
  String? _detectSuspiciousPattern(List<DateTime> completions) {
    if (completions.length < _suspiciousCompletionCount) {
      return null;
    }

    // 最新のN件の完了時刻をチェック
    final recentCompletions =
        completions.take(_suspiciousCompletionCount).toList()
          ..sort((a, b) => b.compareTo(a)); // 新しい順

    if (recentCompletions.isEmpty) return null;

    final timeSpan = recentCompletions.first.difference(recentCompletions.last);

    if (timeSpan < _suspiciousCompletionWindow) {
      return '${_suspiciousCompletionWindow.inMinutes}分以内に$_suspiciousCompletionCount個完了';
    }

    return null;
  }

  /// アカウント作成の不正検出
  Future<FraudDetectionResult> detectAccountCreationFraud({
    required String email,
    required String? deviceId,
  }) async {
    try {
      // 使い捨てメールアドレスのチェック
      if (_isDisposableEmail(email)) {
        _logger.warning('Disposable email detected: $email');
        return FraudDetectionResult.suspicious(
          reason: '使い捨てメールアドレスが検出されました',
          severity: FraudSeverity.low,
          action: FraudAction.warning,
        );
      }

      // TODO: デバイスIDベースの重複アカウントチェック
      // TODO: IPアドレスベースのレート制限

      return FraudDetectionResult.clean();
    } catch (e, stack) {
      _logger.error(
        'Account fraud detection failed',
        error: e,
        stackTrace: stack,
      );
      return FraudDetectionResult.clean();
    }
  }

  /// 使い捨てメールアドレスかチェック
  bool _isDisposableEmail(String email) {
    final disposableDomains = [
      'tempmail.com',
      '10minutemail.com',
      'guerrillamail.com',
      'mailinator.com',
      'throwaway.email',
    ];

    final domain = email.split('@').last.toLowerCase();
    return disposableDomains.contains(domain);
  }

  /// ペア機能の不正検出
  Future<FraudDetectionResult> detectPairFraud({
    required String userId,
    required int pairChangeCount,
    required Duration timeWindow,
  }) async {
    try {
      // 短期間での頻繁なペア変更をチェック
      const maxPairChanges = 5;
      const checkWindow = Duration(days: 1);

      if (timeWindow < checkWindow && pairChangeCount > maxPairChanges) {
        _logger.warning(
          'Suspicious pair activity: $pairChangeCount changes in ${timeWindow.inHours} hours',
          metadata: {'userId': userId},
        );
        return FraudDetectionResult.suspicious(
          reason: '短期間に頻繁にペアを変更しています',
          severity: FraudSeverity.medium,
          action: FraudAction.cooldown,
        );
      }

      return FraudDetectionResult.clean();
    } catch (e, stack) {
      _logger.error('Pair fraud detection failed', error: e, stackTrace: stack);
      return FraudDetectionResult.clean();
    }
  }
}

/// 不正検出結果
class FraudDetectionResult {
  final bool isSuspicious;
  final String? reason;
  final FraudSeverity? severity;
  final FraudAction? action;

  const FraudDetectionResult._({
    required this.isSuspicious,
    this.reason,
    this.severity,
    this.action,
  });

  factory FraudDetectionResult.clean() {
    return const FraudDetectionResult._(isSuspicious: false);
  }

  factory FraudDetectionResult.suspicious({
    required String reason,
    required FraudSeverity severity,
    required FraudAction action,
  }) {
    return FraudDetectionResult._(
      isSuspicious: true,
      reason: reason,
      severity: severity,
      action: action,
    );
  }
}

/// 不正の深刻度
enum FraudSeverity {
  low, // 軽微（警告のみ）
  medium, // 中程度（一時的な制限）
  high, // 深刻（アカウント停止検討）
}

/// 不正検出時のアクション
enum FraudAction {
  warning, // 警告表示
  cooldown, // クールダウン期間設定
  temporaryBlock, // 一時的なブロック
  permanentBlock, // 永久ブロック
}

/// 不正検出の統計
class FraudDetectionStats {
  int totalChecks = 0;
  int suspiciousActivities = 0;
  int warnings = 0;
  int blocks = 0;

  Map<String, dynamic> toJson() {
    return {
      'totalChecks': totalChecks,
      'suspiciousActivities': suspiciousActivities,
      'warnings': warnings,
      'blocks': blocks,
      'suspiciousRate':
          totalChecks > 0 ? suspiciousActivities / totalChecks : 0,
    };
  }
}
