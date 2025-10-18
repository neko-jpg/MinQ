import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/user/user.dart';

// Provider for the engine
final notificationPersonalizationEngineProvider = Provider<NotificationPersonalizationEngine>((ref) {
  return NotificationPersonalizationEngine();
});

class NotificationPersonalizationEngine {
  /// Generates a personalized notification message for the user.
  String generateMessage({
    required User user,
    required int currentStreak,
  }) {
    // TODO: Add more sophisticated template selection logic
    if (currentStreak > 3) {
      return "絶好調ですね、${user.displayName}さん！その調子で頑張りましょう！";
    }
    return "こんにちは、${user.displayName}さん！今日のクエストを始めませんか？";
  }

  /// Generates a re-engagement message for an inactive user.
  String generateReEngagementMessage({
    required User user,
    required int daysInactive,
  }) {
    if (daysInactive <= 2) {
      return "お久しぶりです、${user.displayName}さん。また一緒に頑張りませんか？";
    } else if (daysInactive <= 5) {
      return "小さな一歩から、また始めてみませんか？応援しています！";
    }
    return "あなたのペースで大丈夫。いつでも戻ってきてくださいね。";
  }
}