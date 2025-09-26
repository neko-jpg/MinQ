import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Represents all remotely-toggleable feature flags used in the app.
class FeatureFlags {
  const FeatureFlags({
    this.celebrationConfettiEnabled = true,
    this.celebrationRewardCardEnabled = true,
    this.homeSuggestionSnoozeEnabled = true,
  });

  /// Controls whether the celebration screen should render confetti animations.
  final bool celebrationConfettiEnabled;

  /// Controls whether the celebration screen should display the reward card CTA.
  final bool celebrationRewardCardEnabled;

  /// Controls whether users can snooze home recommendation slots.
  final bool homeSuggestionSnoozeEnabled;

  static const String confettiKey = 'celebration_confetti_enabled';
  static const String rewardCardKey = 'celebration_reward_card_enabled';
  static const String homeSnoozeKey = 'home_suggestion_snooze_enabled';

  /// Returns the default flag map used to seed Remote Config.
  static Map<String, Object> defaults() => const <String, Object>{
        confettiKey: true,
        rewardCardKey: true,
        homeSnoozeKey: true,
      };

  /// Parses the [FirebaseRemoteConfig] instance into strongly-typed flags.
  static FeatureFlags fromRemoteConfig(FirebaseRemoteConfig remoteConfig) {
    return FeatureFlags(
      celebrationConfettiEnabled: remoteConfig.getBool(confettiKey),
      celebrationRewardCardEnabled: remoteConfig.getBool(rewardCardKey),
      homeSuggestionSnoozeEnabled: remoteConfig.getBool(homeSnoozeKey),
    );
  }

  FeatureFlags copyWith({
    bool? celebrationConfettiEnabled,
    bool? celebrationRewardCardEnabled,
    bool? homeSuggestionSnoozeEnabled,
  }) {
    return FeatureFlags(
      celebrationConfettiEnabled:
          celebrationConfettiEnabled ?? this.celebrationConfettiEnabled,
      celebrationRewardCardEnabled:
          celebrationRewardCardEnabled ?? this.celebrationRewardCardEnabled,
      homeSuggestionSnoozeEnabled:
          homeSuggestionSnoozeEnabled ?? this.homeSuggestionSnoozeEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureFlags &&
        other.celebrationConfettiEnabled == celebrationConfettiEnabled &&
        other.celebrationRewardCardEnabled == celebrationRewardCardEnabled &&
        other.homeSuggestionSnoozeEnabled == homeSuggestionSnoozeEnabled;
  }

  @override
  int get hashCode => Object.hash(
        celebrationConfettiEnabled,
        celebrationRewardCardEnabled,
        homeSuggestionSnoozeEnabled,
      );
}
