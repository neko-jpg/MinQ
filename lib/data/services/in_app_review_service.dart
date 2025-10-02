import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:minq/data/services/local_preferences_service.dart';

class InAppReviewService {
  InAppReviewService(this._preferences, {InAppReview? reviewClient})
      : _review = reviewClient ?? InAppReview.instance;

  final LocalPreferencesService _preferences;
  final InAppReview _review;

  static const Duration _coolDown = Duration(days: 90);

  Future<void> maybeRequestReview({required int currentStreak}) async {
    if (currentStreak < 7) {
      return;
    }

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
