import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:minq/data/services/local_preferences_service.dart';

class InAppReviewService {
  InAppReviewService(this._preferences, {InAppReview? reviewClient})
      : _review = reviewClient ?? InAppReview.instance;

  final LocalPreferencesService _preferences;
  final InAppReview _review;

  static const Duration _coolDown = Duration(days: 90);
  static const int _minStreakForReview = 7;
  static const int _minQuestsCompletedForReview = 10;
  static const int _minDaysUsedForReview = 7;

  /// ストリーク達成時のレビューリクエスト
  Future<void> maybeRequestReview({required int currentStreak}) async {
    if (currentStreak < _minStreakForReview) {
      return;
    }
    await _requestReviewIfEligible();
  }

  /// クエスト完了数に基づくレビューリクエスト
  Future<void> maybeRequestReviewByQuestCount({required int completedCount}) async {
    if (completedCount < _minQuestsCompletedForReview) {
      return;
    }
    await _requestReviewIfEligible();
  }

  /// アプリ使用日数に基づくレビューリクエスト
  Future<void> maybeRequestReviewByUsageDays({required int daysUsed}) async {
    if (daysUsed < _minDaysUsedForReview) {
      return;
    }
    await _requestReviewIfEligible();
  }

  /// ストアページを直接開く（設定画面などから）
  Future<void> openStoreListing() async {
    try {
      await _review.openStoreListing(
        appStoreId: '1234567890', // TODO: 実際のApp Store IDに置き換え
      );
    } catch (error) {
      debugPrint('Failed to open store listing: $error');
    }
  }

  /// レビューリクエストの実行（条件チェック済み）
  Future<void> _requestReviewIfEligible() async {
    try {
      final isAvailable = await _review.isAvailable();
      if (!isAvailable) {
        return;
      }
    } catch (error) {
      debugPrint('In-app review availability check failed: $error');
      return;
    }

    final lastPrompt = await _preferences.lastInAppReviewPromptedAt();
    if (lastPrompt != null &&
        DateTime.now().difference(lastPrompt) < _coolDown) {
      return;
    }

    try {
      await _review.requestReview();
      await _preferences.recordInAppReviewPrompt(DateTime.now());
    } catch (error) {
      debugPrint('In-app review request failed: $error');
    }
  }
}
