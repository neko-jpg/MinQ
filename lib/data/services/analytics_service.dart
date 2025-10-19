import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics? _analytics;

  // Auth Events
  Future<void> logSignUp(String method) async {
    await _logEvent('sign_up', parameters: {'method': method});
  }

  Future<void> logLogin(String method) async {
    await _logEvent('login', parameters: {'method': method});
  }

  Future<void> logSignOut() async {
    await _logEvent('sign_out');
  }

  // Onboarding Events
  Future<void> logOnboardingStart() async {
    await _logEvent('onboarding_start');
  }

  Future<void> logOnboardingComplete() async {
    await _logEvent('onboarding_complete');
  }

  Future<void> logOnboardingSkip(int step) async {
    await _logEvent('onboarding_skip', parameters: {'step': step});
  }

  // Quest Events
  Future<void> logQuestCreate(String category, int estimatedMinutes) async {
    await _logEvent('quest_create', parameters: {
      'category': category,
      'estimated_minutes': estimatedMinutes,
    });
  }

  Future<void> logQuestEdit(int questId) async {
    await _logEvent('quest_edit', parameters: {'quest_id': questId});
  }

  Future<void> logQuestDelete(int questId) async {
    await _logEvent('quest_delete', parameters: {'quest_id': questId});
  }

  Future<void> logQuestComplete(int questId, String proofType) async {
    await _logEvent('quest_complete', parameters: {
      'quest_id': questId,
      'proof_type': proofType,
    });
  }

  // Progress Events
  Future<void> logProgressRecord(int questId) async {
    await _logEvent('progress_record', parameters: {'quest_id': questId});
  }

  Future<void> logProgressUndo(int logId) async {
    await _logEvent('progress_undo', parameters: {'log_id': logId});
  }

  Future<void> logStreakAchieved(int days) async {
    await _logEvent('streak_achieved', parameters: {'days': days});
  }

  // Share Events
  Future<void> logShareProgress(String platform) async {
    await _logEvent('share_progress', parameters: {'platform': platform});
  }

  Future<void> logShareInvite(String method) async {
    await _logEvent('share_invite', parameters: {'method': method});
  }

  // Pair Events
  Future<void> logPairRequest(String category) async {
    await _logEvent('pair_request', parameters: {'category': category});
  }

  Future<void> logPairMatched(String pairId) async {
    await _logEvent('pair_matched', parameters: {'pair_id': pairId});
  }

  Future<void> logPairMessage(String pairId) async {
    await _logEvent('pair_message', parameters: {'pair_id': pairId});
  }

  Future<void> logPairBlock(String pairId) async {
    await _logEvent('pair_block', parameters: {'pair_id': pairId});
  }

  Future<void> logPairReport(String pairId, String reason) async {
    await _logEvent('pair_report', parameters: {
      'pair_id': pairId,
      'reason': reason,
    });
  }

  // Screen Views
  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  // Settings Events
  Future<void> logNotificationEnabled(bool enabled) async {
    await _logEvent('notification_enabled', parameters: {'enabled': enabled});
  }

  Future<void> logThemeChanged(String theme) async {
    await _logEvent('theme_changed', parameters: {'theme': theme});
  }

  // Error Events
  Future<void> logError(String errorType, String message) async {
    await _logEvent('error_occurred', parameters: {
      'error_type': errorType,
      'message': message,
    });
  }

  // Generic event logging
  Future<void> logEvent(String eventName, {Map<String, Object>? parameters}) async {
    await _logEvent(eventName, parameters: parameters);
  }

  // Helper method
  Future<void> _logEvent(String name, {Map<String, Object>? parameters}) async {
    if (_analytics == null) {
      debugPrint('Analytics not available: $name');
      return;
    }

    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
      debugPrint('Analytics: $name ${parameters ?? ""}');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // User Properties
  Future<void> setUserId(String userId) async {
    await _analytics?.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics?.setUserProperty(name: name, value: value);
  }
}
