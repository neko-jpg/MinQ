/// コンテンツモデレーションサービス
class ContentModerationService {
  final NGWordFilter _ngWordFilter;
  final SpamDetector _spamDetector;
  final RateLimiter _rateLimiter;

  ContentModerationService({
    required NGWordFilter ngWordFilter,
    required SpamDetector spamDetector,
    required RateLimiter rateLimiter,
  })  : _ngWordFilter = ngWordFilter,
        _spamDetector = spamDetector,
        _rateLimiter = rateLimiter;

  /// テキストをモデレート
  Future<ModerationResult> moderateText(String text, String userId) async {
    // レート制限チェック
    if (!await _rateLimiter.checkLimit(userId)) {
      return ModerationResult.rateLimited();
    }

    // NGワードチェック
    final ngWordResult = _ngWordFilter.check(text);
    if (!ngWordResult.isClean) {
      return ModerationResult.rejected(
        reason: ModerationReason.inappropriateContent,
        details: 'NGワードが含まれています: ${ngWordResult.detectedWords.join(", ")}',
      );
    }

    // スパムチェック
    final spamResult = await _spamDetector.check(text, userId);
    if (spamResult.isSpam) {
      return ModerationResult.rejected(
        reason: ModerationReason.spam,
        details: 'スパムの可能性があります',
      );
    }

    return ModerationResult.approved();
  }

  /// 画像をモデレート
  Future<ModerationResult> moderateImage(String imageUrl, String userId) async {
    // レート制限チェック
    if (!await _rateLimiter.checkLimit(userId)) {
      return ModerationResult.rateLimited();
    }

    // TODO: 画像解析API（Cloud Vision API等）を使用
    // 現時点では承認
    return ModerationResult.approved();
  }

  /// ユーザー名をモデレート
  Future<ModerationResult> moderateUsername(String username) async {
    // NGワードチェック
    final ngWordResult = _ngWordFilter.check(username);
    if (!ngWordResult.isClean) {
      return ModerationResult.rejected(
        reason: ModerationReason.inappropriateContent,
        details: 'NGワードが含まれています',
      );
    }

    // 長さチェック
    if (username.length < 2 || username.length > 20) {
      return ModerationResult.rejected(
        reason: ModerationReason.invalidFormat,
        details: 'ユーザー名は2〜20文字である必要があります',
      );
    }

    // 特殊文字チェック
    if (!RegExp(r'^[a-zA-Z0-9_\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]+$')
        .hasMatch(username)) {
      return ModerationResult.rejected(
        reason: ModerationReason.invalidFormat,
        details: '使用できない文字が含まれています',
      );
    }

    return ModerationResult.approved();
  }
}

/// NGワードフィルター
class NGWordFilter {
  final List<String> _ngWords;
  final List<RegExp> _ngPatterns;

  NGWordFilter({
    required List<String> ngWords,
    List<RegExp>? ngPatterns,
  })  : _ngWords = ngWords,
        _ngPatterns = ngPatterns ?? [];

  /// テキストをチェック
  NGWordCheckResult check(String text) {
    final detectedWords = <String>[];
    final normalizedText = text.toLowerCase();

    // 完全一致チェック
    for (final word in _ngWords) {
      if (normalizedText.contains(word.toLowerCase())) {
        detectedWords.add(word);
      }
    }

    // パターンマッチチェック
    for (final pattern in _ngPatterns) {
      if (pattern.hasMatch(normalizedText)) {
        detectedWords.add(pattern.pattern);
      }
    }

    return NGWordCheckResult(
      isClean: detectedWords.isEmpty,
      detectedWords: detectedWords,
    );
  }

  /// NGワードを追加
  void addNGWord(String word) {
    if (!_ngWords.contains(word)) {
      _ngWords.add(word);
    }
  }

  /// NGワードを削除
  void removeNGWord(String word) {
    _ngWords.remove(word);
  }

  /// NGワードリストを更新
  void updateNGWords(List<String> newWords) {
    _ngWords.clear();
    _ngWords.addAll(newWords);
  }
}

/// NGワードチェック結果
class NGWordCheckResult {
  final bool isClean;
  final List<String> detectedWords;

  const NGWordCheckResult({
    required this.isClean,
    required this.detectedWords,
  });
}

/// スパム検出器
class SpamDetector {
  final Map<String, List<DateTime>> _userMessageHistory = {};
  final Duration _timeWindow = const Duration(minutes: 1);
  final int _maxMessagesPerWindow = 5;

  /// テキストがスパムかチェック
  Future<SpamCheckResult> check(String text, String userId) async {
    // 同じメッセージの連投チェック
    if (_isDuplicateMessage(text, userId)) {
      return const SpamCheckResult(
        isSpam: true,
        reason: 'Duplicate message',
        confidence: 1.0,
      );
    }

    // 短時間での大量投稿チェック
    if (_isRapidPosting(userId)) {
      return const SpamCheckResult(
        isSpam: true,
        reason: 'Rapid posting',
        confidence: 0.9,
      );
    }

    // URLスパムチェック
    if (_containsSuspiciousUrls(text)) {
      return const SpamCheckResult(
        isSpam: true,
        reason: 'Suspicious URLs',
        confidence: 0.8,
      );
    }

    // メッセージ履歴を記録
    _recordMessage(userId);

    return const SpamCheckResult(
      isSpam: false,
      reason: '',
      confidence: 0.0,
    );
  }

  /// 重複メッセージチェック
  bool _isDuplicateMessage(String text, String userId) {
    // TODO: 実装
    return false;
  }

  /// 短時間での大量投稿チェック
  bool _isRapidPosting(String userId) {
    final history = _userMessageHistory[userId] ?? [];
    final now = DateTime.now();
    final recentMessages = history.where((time) {
      return now.difference(time) < _timeWindow;
    }).toList();

    return recentMessages.length >= _maxMessagesPerWindow;
  }

  /// 疑わしいURLチェック
  bool _containsSuspiciousUrls(String text) {
    final urlPattern = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );

    final urls = urlPattern.allMatches(text);
    return urls.length > 2; // 2つ以上のURLは疑わしい
  }

  /// メッセージを記録
  void _recordMessage(String userId) {
    _userMessageHistory.putIfAbsent(userId, () => []);
    _userMessageHistory[userId]!.add(DateTime.now());

    // 古い履歴を削除
    _cleanOldHistory(userId);
  }

  /// 古い履歴を削除
  void _cleanOldHistory(String userId) {
    final history = _userMessageHistory[userId];
    if (history == null) return;

    final now = DateTime.now();
    history.removeWhere((time) {
      return now.difference(time) > const Duration(hours: 1);
    });
  }
}

/// スパムチェック結果
class SpamCheckResult {
  final bool isSpam;
  final String reason;
  final double confidence;

  const SpamCheckResult({
    required this.isSpam,
    required this.reason,
    required this.confidence,
  });
}

/// レート制限
class RateLimiter {
  final Map<String, List<DateTime>> _userActions = {};
  final Duration _timeWindow;
  final int _maxActions;

  RateLimiter({
    Duration? timeWindow,
    int? maxActions,
  })  : _timeWindow = timeWindow ?? const Duration(minutes: 1),
        _maxActions = maxActions ?? 10;

  /// 制限をチェック
  Future<bool> checkLimit(String userId) async {
    final actions = _userActions[userId] ?? [];
    final now = DateTime.now();

    // 時間窓内のアクションをカウント
    final recentActions = actions.where((time) {
      return now.difference(time) < _timeWindow;
    }).toList();

    if (recentActions.length >= _maxActions) {
      return false;
    }

    // アクションを記録
    _userActions.putIfAbsent(userId, () => []);
    _userActions[userId]!.add(now);

    // 古い履歴を削除
    _cleanOldActions(userId);

    return true;
  }

  /// 古いアクションを削除
  void _cleanOldActions(String userId) {
    final actions = _userActions[userId];
    if (actions == null) return;

    final now = DateTime.now();
    actions.removeWhere((time) {
      return now.difference(time) > const Duration(hours: 1);
    });
  }

  /// リセット
  void reset(String userId) {
    _userActions.remove(userId);
  }
}

/// モデレーション結果
class ModerationResult {
  final ModerationStatus status;
  final ModerationReason? reason;
  final String? details;

  const ModerationResult({
    required this.status,
    this.reason,
    this.details,
  });

  /// 承認
  factory ModerationResult.approved() {
    return const ModerationResult(status: ModerationStatus.approved);
  }

  /// 拒否
  factory ModerationResult.rejected({
    required ModerationReason reason,
    String? details,
  }) {
    return ModerationResult(
      status: ModerationStatus.rejected,
      reason: reason,
      details: details,
    );
  }

  /// レート制限
  factory ModerationResult.rateLimited() {
    return const ModerationResult(
      status: ModerationStatus.rateLimited,
      reason: ModerationReason.rateLimitExceeded,
      details: '送信回数が制限を超えました。しばらく待ってから再試行してください。',
    );
  }

  /// 承認されたかどうか
  bool get isApproved => status == ModerationStatus.approved;

  /// 拒否されたかどうか
  bool get isRejected => status == ModerationStatus.rejected;

  /// レート制限されたかどうか
  bool get isRateLimited => status == ModerationStatus.rateLimited;
}

/// モデレーションステータス
enum ModerationStatus {
  /// 承認
  approved,

  /// 拒否
  rejected,

  /// レート制限
  rateLimited,

  /// 保留（人間による確認が必要）
  pending,
}

/// モデレーション理由
enum ModerationReason {
  /// 不適切なコンテンツ
  inappropriateContent,

  /// スパム
  spam,

  /// レート制限超過
  rateLimitExceeded,

  /// 無効な形式
  invalidFormat,

  /// その他
  other,
}

/// 通報システム
class ReportSystem {
  final Map<String, List<Report>> _reports = {};

  /// コンテンツを通報
  Future<void> reportContent({
    required String contentId,
    required String reporterId,
    required ReportReason reason,
    String? details,
  }) async {
    final report = Report(
      id: _generateReportId(),
      contentId: contentId,
      reporterId: reporterId,
      reason: reason,
      details: details,
      createdAt: DateTime.now(),
    );

    _reports.putIfAbsent(contentId, () => []);
    _reports[contentId]!.add(report);

    // 通報数が閾値を超えたら自動的にコンテンツを非表示
    if (_reports[contentId]!.length >= 3) {
      await _autoHideContent(contentId);
    }
  }

  /// ユーザーを通報
  Future<void> reportUser({
    required String userId,
    required String reporterId,
    required ReportReason reason,
    String? details,
  }) async {
    await reportContent(
      contentId: 'user:$userId',
      reporterId: reporterId,
      reason: reason,
      details: details,
    );
  }

  /// コンテンツを自動非表示
  Future<void> _autoHideContent(String contentId) async {
    // TODO: Firestoreでコンテンツを非表示にする
    print('⚠️ Content auto-hidden: $contentId');
  }

  /// 通報を取得
  List<Report> getReports(String contentId) {
    return _reports[contentId] ?? [];
  }

  /// 通報IDを生成
  String _generateReportId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// 通報
class Report {
  final String id;
  final String contentId;
  final String reporterId;
  final ReportReason reason;
  final String? details;
  final DateTime createdAt;
  final ReportStatus status;

  const Report({
    required this.id,
    required this.contentId,
    required this.reporterId,
    required this.reason,
    this.details,
    required this.createdAt,
    this.status = ReportStatus.pending,
  });
}

/// 通報理由
enum ReportReason {
  /// スパム
  spam,

  /// 嫌がらせ
  harassment,

  /// 不適切なコンテンツ
  inappropriateContent,

  /// 暴力的なコンテンツ
  violence,

  /// ヘイトスピーチ
  hateSpeech,

  /// その他
  other,
}

/// 通報ステータス
enum ReportStatus {
  /// 保留
  pending,

  /// 確認中
  reviewing,

  /// 承認（措置あり）
  approved,

  /// 却下
  rejected,
}

/// ブロック/ミュートシステム
class BlockMuteSystem {
  final Map<String, Set<String>> _blockedUsers = {};
  final Map<String, Set<String>> _mutedUsers = {};
  final Map<String, DateTime> _blockExpiry = {};

  /// ユーザーをブロック
  Future<void> blockUser({
    required String userId,
    required String targetUserId,
    Duration? duration,
  }) async {
    _blockedUsers.putIfAbsent(userId, () => {});
    _blockedUsers[userId]!.add(targetUserId);

    if (duration != null) {
      _blockExpiry['$userId:$targetUserId'] =
          DateTime.now().add(duration);
    }
  }

  /// ユーザーをミュート
  Future<void> muteUser({
    required String userId,
    required String targetUserId,
    Duration? duration,
  }) async {
    _mutedUsers.putIfAbsent(userId, () => {});
    _mutedUsers[userId]!.add(targetUserId);

    if (duration != null) {
      _blockExpiry['mute:$userId:$targetUserId'] =
          DateTime.now().add(duration);
    }
  }

  /// ブロックを解除
  Future<void> unblockUser({
    required String userId,
    required String targetUserId,
  }) async {
    _blockedUsers[userId]?.remove(targetUserId);
    _blockExpiry.remove('$userId:$targetUserId');
  }

  /// ミュートを解除
  Future<void> unmuteUser({
    required String userId,
    required String targetUserId,
  }) async {
    _mutedUsers[userId]?.remove(targetUserId);
    _blockExpiry.remove('mute:$userId:$targetUserId');
  }

  /// ブロックされているかチェック
  bool isBlocked({
    required String userId,
    required String targetUserId,
  }) {
    // 期限切れチェック
    final expiryKey = '$userId:$targetUserId';
    final expiry = _blockExpiry[expiryKey];
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      unblockUser(userId: userId, targetUserId: targetUserId);
      return false;
    }

    return _blockedUsers[userId]?.contains(targetUserId) ?? false;
  }

  /// ミュートされているかチェック
  bool isMuted({
    required String userId,
    required String targetUserId,
  }) {
    // 期限切れチェック
    final expiryKey = 'mute:$userId:$targetUserId';
    final expiry = _blockExpiry[expiryKey];
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      unmuteUser(userId: userId, targetUserId: targetUserId);
      return false;
    }

    return _mutedUsers[userId]?.contains(targetUserId) ?? false;
  }

  /// ブロックリストを取得
  Set<String> getBlockedUsers(String userId) {
    return _blockedUsers[userId] ?? {};
  }

  /// ミュートリストを取得
  Set<String> getMutedUsers(String userId) {
    return _mutedUsers[userId] ?? {};
  }
}
