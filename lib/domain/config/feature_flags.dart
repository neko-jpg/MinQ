import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Represents all remotely-toggleable feature flags used in the app.
class FeatureFlags {
  const FeatureFlags({
    this.celebrationConfettiEnabled = true,
    this.celebrationRewardCardEnabled = true,
    this.homeSuggestionSnoozeEnabled = true,
    this.donationExperimentVariant = 'control',
    this.appIconVariant = 'classic',
  });

  /// Controls whether the celebration screen should render confetti animations.
  final bool celebrationConfettiEnabled;

  /// Controls whether the celebration screen should display the reward card CTA.
  final bool celebrationRewardCardEnabled;

  /// Controls whether users can snooze home recommendation slots.
  final bool homeSuggestionSnoozeEnabled;

  /// Defines the active monetisation experiment treatment.
  final String donationExperimentVariant;

  /// Selects the active app icon creative for store testing.
  final String appIconVariant;

  static const String confettiKey = 'celebration_confetti_enabled';
  static const String rewardCardKey = 'celebration_reward_card_enabled';
  static const String homeSnoozeKey = 'home_suggestion_snooze_enabled';
  static const String donationVariantKey = 'donation_experiment_variant';
  static const String appIconVariantKey = 'app_icon_variant';

  /// Returns the default flag map used to seed Remote Config.
  static Map<String, Object> defaults() => const <String, Object>{
        confettiKey: true,
        rewardCardKey: true,
        homeSnoozeKey: true,
        donationVariantKey: 'control',
        appIconVariantKey: 'classic',
      };

  /// Parses the [FirebaseRemoteConfig] instance into strongly-typed flags.
  static FeatureFlags fromRemoteConfig(FirebaseRemoteConfig remoteConfig) {
    return FeatureFlags(
      celebrationConfettiEnabled: remoteConfig.getBool(confettiKey),
      celebrationRewardCardEnabled: remoteConfig.getBool(rewardCardKey),
      homeSuggestionSnoozeEnabled: remoteConfig.getBool(homeSnoozeKey),
      donationExperimentVariant:
          remoteConfig.getString(donationVariantKey).ifEmpty('control'),
      appIconVariant:
          remoteConfig.getString(appIconVariantKey).ifEmpty('classic'),
    );
  }

  FeatureFlags copyWith({
    bool? celebrationConfettiEnabled,
    bool? celebrationRewardCardEnabled,
    bool? homeSuggestionSnoozeEnabled,
    String? donationExperimentVariant,
    String? appIconVariant,
  }) {
    return FeatureFlags(
      celebrationConfettiEnabled:
          celebrationConfettiEnabled ?? this.celebrationConfettiEnabled,
      celebrationRewardCardEnabled:
          celebrationRewardCardEnabled ?? this.celebrationRewardCardEnabled,
      homeSuggestionSnoozeEnabled:
          homeSuggestionSnoozeEnabled ?? this.homeSuggestionSnoozeEnabled,
      donationExperimentVariant:
          donationExperimentVariant ?? this.donationExperimentVariant,
      appIconVariant: appIconVariant ?? this.appIconVariant,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureFlags &&
        other.celebrationConfettiEnabled == celebrationConfettiEnabled &&
        other.celebrationRewardCardEnabled == celebrationRewardCardEnabled &&
        other.homeSuggestionSnoozeEnabled == homeSuggestionSnoozeEnabled &&
        other.donationExperimentVariant == donationExperimentVariant &&
        other.appIconVariant == appIconVariant;
  }

  @override
  int get hashCode => Object.hash(
        celebrationConfettiEnabled,
        celebrationRewardCardEnabled,
        homeSuggestionSnoozeEnabled,
        donationExperimentVariant,
        appIconVariant,
      );
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
