import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// アプリ内レビューサービス
class InAppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;
  static const String _lastReviewRequestKey = 'last_review_request';
  static const String _reviewRequestCountKey = 'review_request_count';
  static const String _hasReviewedKey = 'has_reviewed';

  /// レビューが利用可能かどうか
  Future<bool> isAvailable() async {
    return await _inAppReview.isAvailable();
  }

  /// レビューダイアログを表示
  Future<void> requestReview() async {
    try {
      if (await isAvailable()) {
        await _inAppReview.requestReview();
        await _recordReviewRequest();
      }
    } catch (e) {
      debugPrint('❌ Failed to request review: $e');
    }
  }

  /// ストアページを開く
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '1234567890', // TODO: 実際のApp Store IDに置き換え
      );
    } catch (e) {
      debugPrint('❌ Failed to open store listing: $e');
    }
  }

  /// レビューリクエストを記録
  Future<void> _recordReviewRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastReviewRequestKey,
      DateTime.now().toIso8601String(),
    );

    final count = prefs.getInt(_reviewRequestCountKey) ?? 0;
    await prefs.setInt(_reviewRequestCountKey, count + 1);
  }

  /// レビュー済みとしてマーク
  Future<void> markAsReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasReviewedKey, true);
  }

  /// レビュー済みかどうか
  Future<bool> hasReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasReviewedKey) ?? false;
  }

  /// 最後のレビューリクエスト日時
  Future<DateTime?> getLastReviewRequestDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastReviewRequestKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  /// レビューリクエスト回数
  Future<int> getReviewRequestCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reviewRequestCountKey) ?? 0;
  }

  /// レビューをリクエストすべきかどうか
  Future<bool> shouldRequestReview() async {
    // 既にレビュー済み
    if (await hasReviewed()) {
      return false;
    }

    // レビューリクエスト回数が3回以上
    final requestCount = await getReviewRequestCount();
    if (requestCount >= 3) {
      return false;
    }

    // 最後のリクエストから30日以上経過しているか
    final lastRequest = await getLastReviewRequestDate();
    if (lastRequest != null) {
      final daysSinceLastRequest =
          DateTime.now().difference(lastRequest).inDays;
      if (daysSinceLastRequest < 30) {
        return false;
      }
    }

    return true;
  }
}

/// レビュートリガー条件
class ReviewTriggerConditions {
  final int minQuestsCompleted;
  final int minDaysUsed;
  final int minStreak;
  final double minAchievementRate;

  const ReviewTriggerConditions({
    this.minQuestsCompleted = 10,
    this.minDaysUsed = 7,
    this.minStreak = 3,
    this.minAchievementRate = 0.7,
  });

  /// デフォルト条件
  static const defaultConditions = ReviewTriggerConditions();

  /// 緩い条件
  static const relaxedConditions = ReviewTriggerConditions(
    minQuestsCompleted: 5,
    minDaysUsed: 3,
    minStreak: 2,
    minAchievementRate: 0.5,
  );

  /// 厳しい条件
  static const strictConditions = ReviewTriggerConditions(
    minQuestsCompleted: 20,
    minDaysUsed: 14,
    minStreak: 7,
    minAchievementRate: 0.8,
  );
}

/// レビュートリガーマネージャー
class ReviewTriggerManager {
  final InAppReviewService _reviewService;
  final ReviewTriggerConditions _conditions;

  ReviewTriggerManager({
    required InAppReviewService reviewService,
    ReviewTriggerConditions conditions =
        ReviewTriggerConditions.defaultConditions,
  }) : _reviewService = reviewService,
       _conditions = conditions;

  /// 条件をチェックしてレビューをリクエスト
  Future<bool> checkAndRequestReview({
    required int questsCompleted,
    required int daysUsed,
    required int currentStreak,
    required double achievementRate,
  }) async {
    // レビューをリクエストすべきでない場合
    if (!await _reviewService.shouldRequestReview()) {
      return false;
    }

    // 条件をチェック
    if (!_meetsConditions(
      questsCompleted: questsCompleted,
      daysUsed: daysUsed,
      currentStreak: currentStreak,
      achievementRate: achievementRate,
    )) {
      return false;
    }

    // レビューをリクエスト
    await _reviewService.requestReview();
    return true;
  }

  /// 条件を満たしているかチェック
  bool _meetsConditions({
    required int questsCompleted,
    required int daysUsed,
    required int currentStreak,
    required double achievementRate,
  }) {
    return questsCompleted >= _conditions.minQuestsCompleted &&
        daysUsed >= _conditions.minDaysUsed &&
        currentStreak >= _conditions.minStreak &&
        achievementRate >= _conditions.minAchievementRate;
  }

  /// 条件達成度を取得（0.0〜1.0）
  double getConditionProgress({
    required int questsCompleted,
    required int daysUsed,
    required int currentStreak,
    required double achievementRate,
  }) {
    final questProgress = (questsCompleted / _conditions.minQuestsCompleted)
        .clamp(0.0, 1.0);
    final daysProgress = (daysUsed / _conditions.minDaysUsed).clamp(0.0, 1.0);
    final streakProgress = (currentStreak / _conditions.minStreak).clamp(
      0.0,
      1.0,
    );
    final rateProgress = (achievementRate / _conditions.minAchievementRate)
        .clamp(0.0, 1.0);

    return (questProgress + daysProgress + streakProgress + rateProgress) / 4;
  }
}

/// レビュープロンプトUI
class ReviewPromptConfig {
  final String title;
  final String message;
  final String positiveButtonText;
  final String negativeButtonText;
  final String laterButtonText;

  const ReviewPromptConfig({
    this.title = 'アプリを楽しんでいますか？',
    this.message = 'よろしければレビューをお願いします！',
    this.positiveButtonText = 'レビューする',
    this.negativeButtonText = 'しない',
    this.laterButtonText = '後で',
  });
}

/// レビュープロンプト結果
enum ReviewPromptResult {
  /// レビューする
  review,

  /// しない
  decline,

  /// 後で
  later,

  /// キャンセル
  cancel,
}

/// レビュー統計
class ReviewStats {
  int _promptShownCount = 0;
  int _reviewRequestedCount = 0;
  int _storeOpenedCount = 0;
  int _declinedCount = 0;
  int _laterCount = 0;

  /// プロンプト表示回数
  int get promptShownCount => _promptShownCount;

  /// レビューリクエスト回数
  int get reviewRequestedCount => _reviewRequestedCount;

  /// ストアを開いた回数
  int get storeOpenedCount => _storeOpenedCount;

  /// 拒否回数
  int get declinedCount => _declinedCount;

  /// 後で回数
  int get laterCount => _laterCount;

  /// コンバージョン率
  double get conversionRate =>
      _promptShownCount > 0 ? _reviewRequestedCount / _promptShownCount : 0.0;

  /// プロンプト表示を記録
  void recordPromptShown() {
    _promptShownCount++;
  }

  /// レビューリクエストを記録
  void recordReviewRequested() {
    _reviewRequestedCount++;
  }

  /// ストアを開いたことを記録
  void recordStoreOpened() {
    _storeOpenedCount++;
  }

  /// 拒否を記録
  void recordDeclined() {
    _declinedCount++;
  }

  /// 後でを記録
  void recordLater() {
    _laterCount++;
  }

  /// 統計をリセット
  void reset() {
    _promptShownCount = 0;
    _reviewRequestedCount = 0;
    _storeOpenedCount = 0;
    _declinedCount = 0;
    _laterCount = 0;
  }

  /// 統計を取得
  Map<String, dynamic> getStats() {
    return {
      'promptShownCount': _promptShownCount,
      'reviewRequestedCount': _reviewRequestedCount,
      'storeOpenedCount': _storeOpenedCount,
      'declinedCount': _declinedCount,
      'laterCount': _laterCount,
      'conversionRate': conversionRate,
    };
  }
}

/// レビュータイミング
enum ReviewTiming {
  /// クエスト完了後
  afterQuestCompletion,

  /// 連続達成後
  afterStreak,

  /// 統計画面表示時
  onStatsView,

  /// アプリ起動時
  onAppLaunch,

  /// 設定画面から
  fromSettings,
}

/// レビュータイミング設定
class ReviewTimingConfig {
  final ReviewTiming timing;
  final Duration delay;

  const ReviewTimingConfig({required this.timing, this.delay = Duration.zero});

  /// クエスト完了後（3秒後）
  static const afterQuestCompletion = ReviewTimingConfig(
    timing: ReviewTiming.afterQuestCompletion,
    delay: Duration(seconds: 3),
  );

  /// 連続達成後（即座）
  static const afterStreak = ReviewTimingConfig(
    timing: ReviewTiming.afterStreak,
    delay: Duration.zero,
  );

  /// 統計画面表示時（5秒後）
  static const onStatsView = ReviewTimingConfig(
    timing: ReviewTiming.onStatsView,
    delay: Duration(seconds: 5),
  );

  /// アプリ起動時（10秒後）
  static const onAppLaunch = ReviewTimingConfig(
    timing: ReviewTiming.onAppLaunch,
    delay: Duration(seconds: 10),
  );
}
