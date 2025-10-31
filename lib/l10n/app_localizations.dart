import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning!'**
  String get goodMorning;

  /// No description provided for @todaysQuests.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Quests'**
  String get todaysQuests;

  /// No description provided for @todays3Recommendations.
  ///
  /// In en, this message translates to:
  /// **'Today\'s 3 recommendations'**
  String get todays3Recommendations;

  /// No description provided for @swapOrSnooze.
  ///
  /// In en, this message translates to:
  /// **'Swap or snooze can be changed with one tap.'**
  String get swapOrSnooze;

  /// No description provided for @replacedRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Replaced the recommendation.'**
  String get replacedRecommendation;

  /// No description provided for @snoozedRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Snoozed this recommendation until tomorrow.'**
  String get snoozedRecommendation;

  /// No description provided for @noQuestsToday.
  ///
  /// In en, this message translates to:
  /// **'No Quests for today yet'**
  String get noQuestsToday;

  /// No description provided for @chooseFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose from a template and start your 3-tap habit.'**
  String get chooseFromTemplate;

  /// No description provided for @findAQuest.
  ///
  /// In en, this message translates to:
  /// **'Find a Quest'**
  String get findAQuest;

  /// No description provided for @swapRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Swap to another recommendation'**
  String get swapRecommendation;

  /// No description provided for @snoozeUntilTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Snooze until tomorrow'**
  String get snoozeUntilTomorrow;

  /// No description provided for @snoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get snoozed;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @dismissHelpBanner.
  ///
  /// In en, this message translates to:
  /// **'Dismiss tips'**
  String get dismissHelpBanner;

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfile;

  /// No description provided for @snoozeTemporarilyDisabled.
  ///
  /// In en, this message translates to:
  /// **'Snooze is temporarily disabled'**
  String get snoozeTemporarilyDisabled;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders and partner updates'**
  String get settingsPushNotificationsSubtitle;

  /// No description provided for @settingsNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get settingsNotificationTime;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get settingsProfile;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Data'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsDataSync.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get settingsDataSync;

  /// No description provided for @settingsDataSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync settings'**
  String get settingsDataSyncSubtitle;

  /// No description provided for @settingsManageBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Blocked Users'**
  String get settingsManageBlockedUsers;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExportData;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About MinQ'**
  String get settingsSectionAbout;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsSectionDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer Options'**
  String get settingsSectionDeveloper;

  /// No description provided for @settingsUseDummyData.
  ///
  /// In en, this message translates to:
  /// **'Use Dummy Data'**
  String get settingsUseDummyData;

  /// No description provided for @settingsUseDummyDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dummy data instead of the database.'**
  String get settingsUseDummyDataSubtitle;

  /// No description provided for @settingsSocialSharingDemo.
  ///
  /// In en, this message translates to:
  /// **'Try Social Sharing Demo'**
  String get settingsSocialSharingDemo;

  /// No description provided for @settingsSocialSharingDemoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test social sharing and celebration features'**
  String get settingsSocialSharingDemoSubtitle;

  /// No description provided for @questsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mini-Quests'**
  String get questsTitle;

  /// No description provided for @questsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for templates...'**
  String get questsSearchHint;

  /// No description provided for @questsFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Custom'**
  String get questsFabLabel;

  /// No description provided for @questsCategoryFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get questsCategoryFeatured;

  /// No description provided for @questsCategoryMyQuests.
  ///
  /// In en, this message translates to:
  /// **'My Quests'**
  String get questsCategoryMyQuests;

  /// No description provided for @questsCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get questsCategoryAll;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Notification Analytics'**
  String get notificationAnalytics;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings'**
  String get errorLoadingSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @globalSettings.
  ///
  /// In en, this message translates to:
  /// **'Global Settings'**
  String get globalSettings;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable all notifications at once'**
  String get enableNotificationsDescription;

  /// No description provided for @categorySettings.
  ///
  /// In en, this message translates to:
  /// **'Category Settings'**
  String get categorySettings;

  /// No description provided for @categorySettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Fine-tune settings for each type of notification'**
  String get categorySettingsDescription;

  /// No description provided for @timeSettings.
  ///
  /// In en, this message translates to:
  /// **'Time Settings'**
  String get timeSettings;

  /// No description provided for @timeSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Control when you receive notifications'**
  String get timeSettingsDescription;

  /// No description provided for @smartSettings.
  ///
  /// In en, this message translates to:
  /// **'Smart Notifications'**
  String get smartSettings;

  /// No description provided for @smartSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'AI learns your behavior patterns for optimization'**
  String get smartSettingsDescription;

  /// No description provided for @analyticsSettings.
  ///
  /// In en, this message translates to:
  /// **'Analytics Settings'**
  String get analyticsSettings;

  /// No description provided for @analyticsSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notification effectiveness measurement and privacy settings'**
  String get analyticsSettingsDescription;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @resetSettingsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Reset all notification settings to defaults?'**
  String get resetSettingsConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings have been reset'**
  String get settingsReset;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Notification settings are working properly'**
  String get testNotificationBody;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get testNotificationSent;

  /// No description provided for @questNotifications.
  ///
  /// In en, this message translates to:
  /// **'Quest Notifications'**
  String get questNotifications;

  /// No description provided for @challengeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Challenge Notifications'**
  String get challengeNotifications;

  /// No description provided for @pairNotifications.
  ///
  /// In en, this message translates to:
  /// **'Pair Notifications'**
  String get pairNotifications;

  /// No description provided for @leagueNotifications.
  ///
  /// In en, this message translates to:
  /// **'League Notifications'**
  String get leagueNotifications;

  /// No description provided for @aiNotifications.
  ///
  /// In en, this message translates to:
  /// **'AI Coach Notifications'**
  String get aiNotifications;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get systemNotifications;

  /// No description provided for @achievementNotifications.
  ///
  /// In en, this message translates to:
  /// **'Achievement Notifications'**
  String get achievementNotifications;

  /// No description provided for @reminderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminder Notifications'**
  String get reminderNotifications;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @notificationFrequency.
  ///
  /// In en, this message translates to:
  /// **'Notification Frequency'**
  String get notificationFrequency;

  /// No description provided for @notificationOptions.
  ///
  /// In en, this message translates to:
  /// **'Notification Options'**
  String get notificationOptions;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundDescription.
  ///
  /// In en, this message translates to:
  /// **'Play notification sound'**
  String get soundDescription;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Vibrate the device'**
  String get vibrationDescription;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badge;

  /// No description provided for @badgeDescription.
  ///
  /// In en, this message translates to:
  /// **'Show badge on app icon'**
  String get badgeDescription;

  /// No description provided for @lockScreen.
  ///
  /// In en, this message translates to:
  /// **'Lock Screen'**
  String get lockScreen;

  /// No description provided for @lockScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Show notifications on lock screen'**
  String get lockScreenDescription;

  /// No description provided for @immediate.
  ///
  /// In en, this message translates to:
  /// **'Immediate'**
  String get immediate;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'1 Hour Later'**
  String get hourly;

  /// No description provided for @threeHours.
  ///
  /// In en, this message translates to:
  /// **'3 Hours Later'**
  String get threeHours;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Next Day'**
  String get daily;

  /// No description provided for @enableTimeBasedControl.
  ///
  /// In en, this message translates to:
  /// **'Enable Time-Based Control'**
  String get enableTimeBasedControl;

  /// No description provided for @enableTimeBasedControlDescription.
  ///
  /// In en, this message translates to:
  /// **'Control notifications during specified time periods'**
  String get enableTimeBasedControlDescription;

  /// No description provided for @sleepTime.
  ///
  /// In en, this message translates to:
  /// **'Sleep Time'**
  String get sleepTime;

  /// No description provided for @sleepTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Sleep Time Range'**
  String get sleepTimeRange;

  /// No description provided for @workTime.
  ///
  /// In en, this message translates to:
  /// **'Work Time'**
  String get workTime;

  /// No description provided for @workTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Work Time Range'**
  String get workTimeRange;

  /// No description provided for @respectSystemDnd.
  ///
  /// In en, this message translates to:
  /// **'Respect System DND Mode'**
  String get respectSystemDnd;

  /// No description provided for @respectSystemDndDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow device\'s Do Not Disturb settings'**
  String get respectSystemDndDescription;

  /// No description provided for @weekendMode.
  ///
  /// In en, this message translates to:
  /// **'Weekend Mode'**
  String get weekendMode;

  /// No description provided for @weekendModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Use different time settings for weekends'**
  String get weekendModeDescription;

  /// No description provided for @weekendSleepTime.
  ///
  /// In en, this message translates to:
  /// **'Weekend Sleep Time'**
  String get weekendSleepTime;

  /// No description provided for @weekendSleepTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Weekend Sleep Time Range'**
  String get weekendSleepTimeRange;

  /// No description provided for @weekendWorkTime.
  ///
  /// In en, this message translates to:
  /// **'Weekend Work Time'**
  String get weekendWorkTime;

  /// No description provided for @weekendWorkTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Weekend Work Time Range'**
  String get weekendWorkTimeRange;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @enableSmartNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Smart Notifications'**
  String get enableSmartNotifications;

  /// No description provided for @enableSmartNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'AI learns your behavior patterns to optimize notifications'**
  String get enableSmartNotificationsDescription;

  /// No description provided for @behaviorLearning.
  ///
  /// In en, this message translates to:
  /// **'Behavior Pattern Learning'**
  String get behaviorLearning;

  /// No description provided for @behaviorLearningDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn from your notification responses'**
  String get behaviorLearningDescription;

  /// No description provided for @adaptiveFrequency.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Frequency Adjustment'**
  String get adaptiveFrequency;

  /// No description provided for @adaptiveFrequencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust notification frequency based on engagement'**
  String get adaptiveFrequencyDescription;

  /// No description provided for @contextAware.
  ///
  /// In en, this message translates to:
  /// **'Context Awareness'**
  String get contextAware;

  /// No description provided for @contextAwareDescription.
  ///
  /// In en, this message translates to:
  /// **'Consider current situation for notification timing'**
  String get contextAwareDescription;

  /// No description provided for @engagementOptimization.
  ///
  /// In en, this message translates to:
  /// **'Engagement Optimization'**
  String get engagementOptimization;

  /// No description provided for @engagementOptimizationDescription.
  ///
  /// In en, this message translates to:
  /// **'Find the most effective notification methods'**
  String get engagementOptimizationDescription;

  /// No description provided for @confidenceThreshold.
  ///
  /// In en, this message translates to:
  /// **'Confidence Threshold'**
  String get confidenceThreshold;

  /// No description provided for @confidenceThresholdDescription.
  ///
  /// In en, this message translates to:
  /// **'Apply optimization only when AI prediction confidence is above this value'**
  String get confidenceThresholdDescription;

  /// No description provided for @learningPeriod.
  ///
  /// In en, this message translates to:
  /// **'Learning Period'**
  String get learningPeriod;

  /// No description provided for @learningPeriodDescription.
  ///
  /// In en, this message translates to:
  /// **'Use data from this period to learn patterns'**
  String get learningPeriodDescription;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @viewLearningData.
  ///
  /// In en, this message translates to:
  /// **'View Learning Data'**
  String get viewLearningData;

  /// No description provided for @resetLearning.
  ///
  /// In en, this message translates to:
  /// **'Reset Learning'**
  String get resetLearning;

  /// No description provided for @learningDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Data'**
  String get learningDataTitle;

  /// No description provided for @learningDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Your notification patterns learned by AI'**
  String get learningDataDescription;

  /// No description provided for @totalNotificationsSent.
  ///
  /// In en, this message translates to:
  /// **'Total Notifications Sent'**
  String get totalNotificationsSent;

  /// No description provided for @totalNotificationsOpened.
  ///
  /// In en, this message translates to:
  /// **'Total Notifications Opened'**
  String get totalNotificationsOpened;

  /// No description provided for @averageOpenRate.
  ///
  /// In en, this message translates to:
  /// **'Average Open Rate'**
  String get averageOpenRate;

  /// No description provided for @optimalTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'Optimal Time Slots'**
  String get optimalTimeSlots;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @resetLearningData.
  ///
  /// In en, this message translates to:
  /// **'Reset Learning Data'**
  String get resetLearningData;

  /// No description provided for @resetLearningDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Resetting learning data will make AI start learning again. Are you sure?'**
  String get resetLearningDataConfirmation;

  /// No description provided for @learningDataReset.
  ///
  /// In en, this message translates to:
  /// **'Learning data has been reset'**
  String get learningDataReset;

  /// No description provided for @enableAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Enable Analytics'**
  String get enableAnalytics;

  /// No description provided for @enableAnalyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Measure notification effectiveness for improvement'**
  String get enableAnalyticsDescription;

  /// No description provided for @trackingOptions.
  ///
  /// In en, this message translates to:
  /// **'Tracking Options'**
  String get trackingOptions;

  /// No description provided for @trackOpenRate.
  ///
  /// In en, this message translates to:
  /// **'Track Open Rate'**
  String get trackOpenRate;

  /// No description provided for @trackOpenRateDescription.
  ///
  /// In en, this message translates to:
  /// **'Measure how often notifications are opened'**
  String get trackOpenRateDescription;

  /// No description provided for @trackEngagementRate.
  ///
  /// In en, this message translates to:
  /// **'Track Engagement Rate'**
  String get trackEngagementRate;

  /// No description provided for @trackEngagementRateDescription.
  ///
  /// In en, this message translates to:
  /// **'Measure action execution rate from notifications'**
  String get trackEngagementRateDescription;

  /// No description provided for @trackConversionRate.
  ///
  /// In en, this message translates to:
  /// **'Track Conversion Rate'**
  String get trackConversionRate;

  /// No description provided for @trackConversionRateDescription.
  ///
  /// In en, this message translates to:
  /// **'Measure conversion rate from notifications to goal achievement'**
  String get trackConversionRateDescription;

  /// No description provided for @trackOptimalTiming.
  ///
  /// In en, this message translates to:
  /// **'Analyze Optimal Timing'**
  String get trackOptimalTiming;

  /// No description provided for @trackOptimalTimingDescription.
  ///
  /// In en, this message translates to:
  /// **'Analyze the most effective notification timing'**
  String get trackOptimalTimingDescription;

  /// No description provided for @dataRetentionPeriod.
  ///
  /// In en, this message translates to:
  /// **'Data Retention Period'**
  String get dataRetentionPeriod;

  /// No description provided for @dataRetentionDescription.
  ///
  /// In en, this message translates to:
  /// **'Analytics data older than this period will be automatically deleted'**
  String get dataRetentionDescription;

  /// No description provided for @analyticsPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Analytics data is stored only on your device and never sent externally'**
  String get analyticsPrivacyNote;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get deleteData;

  /// No description provided for @exportAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'Export Analytics Data'**
  String get exportAnalyticsData;

  /// No description provided for @exportAnalyticsDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Export notification analytics data as a file'**
  String get exportAnalyticsDataDescription;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @csvFormat.
  ///
  /// In en, this message translates to:
  /// **'CSV Format'**
  String get csvFormat;

  /// No description provided for @csvFormatDescription.
  ///
  /// In en, this message translates to:
  /// **'Can be opened with spreadsheet software'**
  String get csvFormatDescription;

  /// No description provided for @jsonFormat.
  ///
  /// In en, this message translates to:
  /// **'JSON Format'**
  String get jsonFormat;

  /// No description provided for @jsonFormatDescription.
  ///
  /// In en, this message translates to:
  /// **'Easy to process programmatically'**
  String get jsonFormatDescription;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data has been exported'**
  String get dataExported;

  /// No description provided for @deleteAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'Delete Analytics Data'**
  String get deleteAnalyticsData;

  /// No description provided for @deleteAnalyticsDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete all analytics data? This action cannot be undone.'**
  String get deleteAnalyticsDataConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @analyticsDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Analytics data has been deleted'**
  String get analyticsDataDeleted;

  /// No description provided for @hintFirstQuest.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create your first quest!'**
  String get hintFirstQuest;

  /// No description provided for @hintFirstQuestMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a quest and take the first step towards building habits.\nStarting with small goals is the key to success.'**
  String get hintFirstQuestMessage;

  /// No description provided for @hintFirstCompletion.
  ///
  /// In en, this message translates to:
  /// **'First completion! Continuing will increase your streak.'**
  String get hintFirstCompletion;

  /// No description provided for @hintFirstCompletionMessage.
  ///
  /// In en, this message translates to:
  /// **'Continuing will increase your streak.\nIt\'s important to keep going even a little bit every day.'**
  String get hintFirstCompletionMessage;

  /// No description provided for @hintStreak.
  ///
  /// In en, this message translates to:
  /// **'Amazing streak!'**
  String get hintStreak;

  /// No description provided for @hintStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'{streakDays} days in a row!\nKeep up your habits and aim for even greater growth.'**
  String hintStreakMessage(Object streakDays);

  /// No description provided for @hintWeeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal achieved!'**
  String get hintWeeklyGoal;

  /// No description provided for @hintWeeklyGoalMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve achieved this week\'s goal!\nYou can check detailed progress on the stats screen.'**
  String get hintWeeklyGoalMessage;

  /// No description provided for @hintPairFeatureUnlock.
  ///
  /// In en, this message translates to:
  /// **'Pair feature unlocked!'**
  String get hintPairFeatureUnlock;

  /// No description provided for @hintPairFeatureUnlockMessage.
  ///
  /// In en, this message translates to:
  /// **'You can now work on habits together with friends.\nEncourage each other to keep going.'**
  String get hintPairFeatureUnlockMessage;

  /// No description provided for @hintAdvancedStatsUnlock.
  ///
  /// In en, this message translates to:
  /// **'Advanced statistics unlocked!'**
  String get hintAdvancedStatsUnlock;

  /// No description provided for @hintAdvancedStatsUnlockMessage.
  ///
  /// In en, this message translates to:
  /// **'Detailed analysis and insights are now available.\nGain a deeper understanding of your habit patterns.'**
  String get hintAdvancedStatsUnlockMessage;

  /// No description provided for @hintAchievementsUnlock.
  ///
  /// In en, this message translates to:
  /// **'Achievements feature unlocked!'**
  String get hintAchievementsUnlock;

  /// No description provided for @hintAchievementsUnlockMessage.
  ///
  /// In en, this message translates to:
  /// **'Earn various achievements and feel your growth.\nTry challenging yourself with new goals.'**
  String get hintAchievementsUnlockMessage;

  /// No description provided for @hintUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get hintUnderstood;

  /// No description provided for @hintClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get hintClose;

  /// No description provided for @questsCategoryLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get questsCategoryLearning;

  /// No description provided for @questsCategoryExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get questsCategoryExercise;

  /// No description provided for @questsCategoryTidying.
  ///
  /// In en, this message translates to:
  /// **'Tidying'**
  String get questsCategoryTidying;

  /// No description provided for @questsCategoryRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get questsCategoryRecent;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Anonymous sign-in is not enabled for this project.'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password provided is too weak.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email.'**
  String get authErrorEmailAlreadyInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for this email.'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password provided for this user.'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorAccountExistsWithDifferentCredential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with the same email address but different sign-in credentials.'**
  String get authErrorAccountExistsWithDifferentCredential;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'The credential received is malformed or has expired.'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get authErrorUnknown;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @settingsEnhancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsEnhancedTitle;

  /// No description provided for @settingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search settings...'**
  String get settingsSearchHint;

  /// No description provided for @settingsSearchHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get settingsSearchHistoryTitle;

  /// No description provided for @settingsSearchPopularTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular searches'**
  String get settingsSearchPopularTitle;

  /// No description provided for @settingsSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settingsSearchClear;

  /// No description provided for @settingsSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get settingsSearchNoResults;

  /// No description provided for @settingsSearchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get settingsSearchNoResultsSubtitle;

  /// No description provided for @settingsShowAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Show advanced settings'**
  String get settingsShowAdvanced;

  /// No description provided for @settingsHideAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Hide advanced settings'**
  String get settingsHideAdvanced;

  /// No description provided for @settingsCategoryAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Theme'**
  String get settingsCategoryAppearance;

  /// No description provided for @settingsCategoryAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize app appearance'**
  String get settingsCategoryAppearanceSubtitle;

  /// No description provided for @settingsCategoryNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsCategoryNotifications;

  /// No description provided for @settingsCategoryNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification settings and management'**
  String get settingsCategoryNotificationsSubtitle;

  /// No description provided for @settingsCategoryPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settingsCategoryPrivacy;

  /// No description provided for @settingsCategoryPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data protection and security settings'**
  String get settingsCategoryPrivacySubtitle;

  /// No description provided for @settingsCategoryAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsCategoryAccessibility;

  /// No description provided for @settingsCategoryAccessibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility settings'**
  String get settingsCategoryAccessibilitySubtitle;

  /// No description provided for @settingsCategoryData.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settingsCategoryData;

  /// No description provided for @settingsCategoryDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data backup and management'**
  String get settingsCategoryDataSubtitle;

  /// No description provided for @settingsCategoryAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsCategoryAbout;

  /// No description provided for @settingsCategoryAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support and information'**
  String get settingsCategoryAboutSubtitle;

  /// No description provided for @settingsCategoryAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get settingsCategoryAdvanced;

  /// No description provided for @settingsCategoryAdvancedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Developer and advanced user settings'**
  String get settingsCategoryAdvancedSubtitle;

  /// No description provided for @settingsCategoryAdvancedBadge.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsCategoryAdvancedBadge;

  /// No description provided for @settingsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, Dark, or System setting'**
  String get settingsThemeModeSubtitle;

  /// No description provided for @settingsThemeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System Setting'**
  String get settingsThemeModeSystem;

  /// No description provided for @settingsThemeModeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically switch based on device settings'**
  String get settingsThemeModeSystemSubtitle;

  /// No description provided for @settingsThemeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsThemeModeLight;

  /// No description provided for @settingsThemeModeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use light theme'**
  String get settingsThemeModeLightSubtitle;

  /// No description provided for @settingsThemeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsThemeModeDark;

  /// No description provided for @settingsThemeModeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get settingsThemeModeDarkSubtitle;

  /// No description provided for @settingsAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsAccentColor;

  /// No description provided for @settingsAccentColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select app main color'**
  String get settingsAccentColorSubtitle;

  /// No description provided for @settingsThemeCustomization.
  ///
  /// In en, this message translates to:
  /// **'Theme Customization'**
  String get settingsThemeCustomization;

  /// No description provided for @settingsThemeCustomizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed theme settings'**
  String get settingsThemeCustomizationSubtitle;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get settingsNotificationsEnabledSubtitle;

  /// No description provided for @settingsNotificationTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder time'**
  String get settingsNotificationTimeSubtitle;

  /// No description provided for @settingsNotificationCategories.
  ///
  /// In en, this message translates to:
  /// **'Notification Categories'**
  String get settingsNotificationCategories;

  /// No description provided for @settingsNotificationCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Category-specific notification settings'**
  String get settingsNotificationCategoriesSubtitle;

  /// No description provided for @settingsSmartNotifications.
  ///
  /// In en, this message translates to:
  /// **'Smart Notifications'**
  String get settingsSmartNotifications;

  /// No description provided for @settingsSmartNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-optimized notification timing'**
  String get settingsSmartNotificationsSubtitle;

  /// No description provided for @settingsBiometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get settingsBiometricAuth;

  /// No description provided for @settingsBiometricAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect app with fingerprint/face recognition'**
  String get settingsBiometricAuthSubtitle;

  /// No description provided for @settingsPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get settingsPrivacySettings;

  /// No description provided for @settingsPrivacySettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data usage and privacy management'**
  String get settingsPrivacySettingsSubtitle;

  /// No description provided for @settingsHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get settingsHighContrast;

  /// No description provided for @settingsHighContrastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enhance color contrast'**
  String get settingsHighContrastSubtitle;

  /// No description provided for @settingsLargeText.
  ///
  /// In en, this message translates to:
  /// **'Large Text'**
  String get settingsLargeText;

  /// No description provided for @settingsLargeTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Increase text size'**
  String get settingsLargeTextSubtitle;

  /// No description provided for @settingsAnimationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get settingsAnimationsEnabled;

  /// No description provided for @settingsAnimationsEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable/disable animation effects'**
  String get settingsAnimationsEnabledSubtitle;

  /// No description provided for @settingsDataExport.
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get settingsDataExport;

  /// No description provided for @settingsDataExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export data to file'**
  String get settingsDataExportSubtitle;

  /// No description provided for @settingsDataImport.
  ///
  /// In en, this message translates to:
  /// **'Data Import'**
  String get settingsDataImport;

  /// No description provided for @settingsDataImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup file'**
  String get settingsDataImportSubtitle;

  /// No description provided for @settingsStorageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get settingsStorageUsage;

  /// No description provided for @settingsStorageUsageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check app data usage'**
  String get settingsStorageUsageSubtitle;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get settingsHelpCenter;

  /// No description provided for @settingsHelpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ and usage guide'**
  String get settingsHelpCenterSubtitle;

  /// No description provided for @settingsContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settingsContactSupport;

  /// No description provided for @settingsContactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bug reports and feature requests'**
  String get settingsContactSupportSubtitle;

  /// No description provided for @settingsAppVersionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get settingsAppVersionSubtitle;

  /// No description provided for @settingsDeveloperMode.
  ///
  /// In en, this message translates to:
  /// **'Developer Mode'**
  String get settingsDeveloperMode;

  /// No description provided for @settingsDeveloperModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable developer features'**
  String get settingsDeveloperModeSubtitle;

  /// No description provided for @settingsDebugMode.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode'**
  String get settingsDebugMode;

  /// No description provided for @settingsDebugModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show debug information'**
  String get settingsDebugModeSubtitle;

  /// No description provided for @settingsResetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get settingsResetSettings;

  /// No description provided for @settingsResetSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to default'**
  String get settingsResetSettingsSubtitle;

  /// No description provided for @settingsDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account and data'**
  String get settingsDeleteAccountSubtitle;

  /// No description provided for @themeCustomizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Customization'**
  String get themeCustomizationTitle;

  /// No description provided for @themeCustomizationPreviewShow.
  ///
  /// In en, this message translates to:
  /// **'Show Preview'**
  String get themeCustomizationPreviewShow;

  /// No description provided for @themeCustomizationPreviewHide.
  ///
  /// In en, this message translates to:
  /// **'Hide Preview'**
  String get themeCustomizationPreviewHide;

  /// No description provided for @themeCustomizationThemeModeSection.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeCustomizationThemeModeSection;

  /// No description provided for @themeCustomizationThemeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select app brightness'**
  String get themeCustomizationThemeModeSubtitle;

  /// No description provided for @themeCustomizationAccentColorSection.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get themeCustomizationAccentColorSection;

  /// No description provided for @themeCustomizationAccentColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select app main color'**
  String get themeCustomizationAccentColorSubtitle;

  /// No description provided for @themeCustomizationApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get themeCustomizationApply;

  /// No description provided for @themeCustomizationReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get themeCustomizationReset;

  /// No description provided for @themeCustomizationApplied.
  ///
  /// In en, this message translates to:
  /// **'Theme settings applied'**
  String get themeCustomizationApplied;

  /// No description provided for @themeCustomizationResetDone.
  ///
  /// In en, this message translates to:
  /// **'Theme settings reset'**
  String get themeCustomizationResetDone;

  /// No description provided for @colorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Selection'**
  String get colorPickerTitle;

  /// No description provided for @colorPickerPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get colorPickerPreview;

  /// No description provided for @colorPickerApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get colorPickerApply;

  /// No description provided for @timePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Selection'**
  String get timePickerTitle;

  /// No description provided for @timePickerChange.
  ///
  /// In en, this message translates to:
  /// **'Change Time'**
  String get timePickerChange;

  /// No description provided for @timePickerQuickTimes.
  ///
  /// In en, this message translates to:
  /// **'Quick Times'**
  String get timePickerQuickTimes;

  /// No description provided for @timePickerApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get timePickerApply;

  /// No description provided for @selectionDialogApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get selectionDialogApply;

  /// No description provided for @realTimePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'MinQ Preview'**
  String get realTimePreviewTitle;

  /// No description provided for @realTimePreviewButton.
  ///
  /// In en, this message translates to:
  /// **'Primary Button'**
  String get realTimePreviewButton;

  /// No description provided for @realTimePreviewQuest.
  ///
  /// In en, this message translates to:
  /// **'Sample Quest'**
  String get realTimePreviewQuest;

  /// No description provided for @realTimePreviewQuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue daily habits'**
  String get realTimePreviewQuestSubtitle;

  /// No description provided for @realTimePreviewCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get realTimePreviewCompleted;

  /// No description provided for @realTimePreviewProgress.
  ///
  /// In en, this message translates to:
  /// **'This week\'s progress'**
  String get realTimePreviewProgress;

  /// No description provided for @realTimePreviewLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode Preview'**
  String get realTimePreviewLightMode;

  /// No description provided for @realTimePreviewDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode Preview'**
  String get realTimePreviewDarkMode;

  /// No description provided for @settingsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get settingsConfirmTitle;

  /// No description provided for @settingsConfirmDangerousAction.
  ///
  /// In en, this message translates to:
  /// **'Execute {action}?\nThis action cannot be undone.'**
  String settingsConfirmDangerousAction(Object action);

  /// No description provided for @settingsConfirmExecute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get settingsConfirmExecute;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline mode - some features are limited'**
  String get offlineModeBanner;

  /// No description provided for @offlineOperationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This operation is not available offline'**
  String get offlineOperationNotAvailable;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'An internet connection is required. Please connect to Wi-Fi or mobile data and try again.'**
  String get noInternetConnection;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @readOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get readOnlyLabel;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncStatusSynced;

  /// No description provided for @syncStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncStatusFailed;

  /// No description provided for @syncStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Sync pending'**
  String get syncStatusPending;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get updateProfileSuccess;

  /// No description provided for @updateProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get updateProfileFailed;

  /// No description provided for @hintStreakAchievement.
  ///
  /// In en, this message translates to:
  /// **'Amazing streak! Keep up the great habit.'**
  String get hintStreakAchievement;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChanges;

  /// No description provided for @unsavedChangesWillBeLost.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes will be lost.'**
  String get unsavedChangesWillBeLost;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to delete?'**
  String get confirmDeleteMessage;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get errorGeneric;

  /// No description provided for @serverConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server'**
  String get serverConnectionFailed;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in.'**
  String get notSignedIn;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @rtlSupport.
  ///
  /// In en, this message translates to:
  /// **'Right-to-Left Language Support'**
  String get rtlSupport;

  /// No description provided for @textDirection.
  ///
  /// In en, this message translates to:
  /// **'Text Direction'**
  String get textDirection;

  /// No description provided for @layoutDirection.
  ///
  /// In en, this message translates to:
  /// **'Layout Direction'**
  String get layoutDirection;

  /// No description provided for @accessibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettings;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrast;

  /// No description provided for @largeText.
  ///
  /// In en, this message translates to:
  /// **'Large Text'**
  String get largeText;

  /// No description provided for @screenReader.
  ///
  /// In en, this message translates to:
  /// **'Screen Reader'**
  String get screenReader;

  /// No description provided for @voiceOver.
  ///
  /// In en, this message translates to:
  /// **'VoiceOver'**
  String get voiceOver;

  /// No description provided for @talkBack.
  ///
  /// In en, this message translates to:
  /// **'TalkBack'**
  String get talkBack;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get systemDefault;

  /// No description provided for @autoSwitchTheme.
  ///
  /// In en, this message translates to:
  /// **'Auto Switch Theme'**
  String get autoSwitchTheme;

  /// No description provided for @questReminders.
  ///
  /// In en, this message translates to:
  /// **'Quest Reminders'**
  String get questReminders;

  /// No description provided for @pairUpdates.
  ///
  /// In en, this message translates to:
  /// **'Pair Updates'**
  String get pairUpdates;

  /// No description provided for @weeklyReports.
  ///
  /// In en, this message translates to:
  /// **'Weekly Reports'**
  String get weeklyReports;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @dataSharing.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get dataSharing;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics Data'**
  String get analytics;

  /// No description provided for @crashReports.
  ///
  /// In en, this message translates to:
  /// **'Crash Reports'**
  String get crashReports;

  /// No description provided for @personalizedAds.
  ///
  /// In en, this message translates to:
  /// **'Personalized Ads'**
  String get personalizedAds;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get reportBug;

  /// No description provided for @featureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get featureRequest;

  /// No description provided for @developerOptions.
  ///
  /// In en, this message translates to:
  /// **'Developer Options'**
  String get developerOptions;

  /// No description provided for @debugMode.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode'**
  String get debugMode;

  /// No description provided for @showPerformanceOverlay.
  ///
  /// In en, this message translates to:
  /// **'Show Performance Overlay'**
  String get showPerformanceOverlay;

  /// No description provided for @enableLogging.
  ///
  /// In en, this message translates to:
  /// **'Enable Logging'**
  String get enableLogging;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No description provided for @exportLogs.
  ///
  /// In en, this message translates to:
  /// **'Export Logs'**
  String get exportLogs;

  /// Current streak day count text
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 day streak} other {{count} day streak}}'**
  String streakDayCount(num count);

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share progress. Please try again.'**
  String get shareFailed;

  /// No description provided for @executePrevention.
  ///
  /// In en, this message translates to:
  /// **'Execute Prevention'**
  String get executePrevention;

  /// No description provided for @executeNow.
  ///
  /// In en, this message translates to:
  /// **'Execute Now'**
  String get executeNow;

  /// No description provided for @showPreventionPlan.
  ///
  /// In en, this message translates to:
  /// **'Show prevention plan'**
  String get showPreventionPlan;

  /// No description provided for @navigateToHabitExecution.
  ///
  /// In en, this message translates to:
  /// **'Navigate to habit execution screen'**
  String get navigateToHabitExecution;

  /// No description provided for @editHabitScreen.
  ///
  /// In en, this message translates to:
  /// **'Navigate to habit edit screen'**
  String get editHabitScreen;

  /// No description provided for @addNewHabit.
  ///
  /// In en, this message translates to:
  /// **'Add new habit'**
  String get addNewHabit;

  /// No description provided for @executeHabitToday.
  ///
  /// In en, this message translates to:
  /// **'Execute today\'s habit'**
  String get executeHabitToday;

  /// No description provided for @createMiniHabit.
  ///
  /// In en, this message translates to:
  /// **'Create mini habit'**
  String get createMiniHabit;

  /// No description provided for @navigateToChallenges.
  ///
  /// In en, this message translates to:
  /// **'Navigate to challenges screen'**
  String get navigateToChallenges;

  /// No description provided for @detailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed Analysis'**
  String get detailedAnalysis;

  /// No description provided for @improvementSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Improvement Suggestion'**
  String get improvementSuggestion;

  /// No description provided for @aiImprovementSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI Improvement Suggestion'**
  String get aiImprovementSuggestion;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @levelDetails.
  ///
  /// In en, this message translates to:
  /// **'Level Details'**
  String get levelDetails;

  /// Level details message
  ///
  /// In en, this message translates to:
  /// **'Current Level: {level}\nProgress: {progress}%'**
  String levelDetailsMessage(int level, int progress);

  /// No description provided for @showActivity.
  ///
  /// In en, this message translates to:
  /// **'Show Activity'**
  String get showActivity;

  /// No description provided for @showActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display your activity to other users'**
  String get showActivitySubtitle;

  /// No description provided for @allowInteraction.
  ///
  /// In en, this message translates to:
  /// **'Allow Interaction'**
  String get allowInteraction;

  /// No description provided for @allowInteractionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive encouragement from other users'**
  String get allowInteractionSubtitle;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate during activities'**
  String get hapticFeedbackSubtitle;

  /// No description provided for @celebrationEffects.
  ///
  /// In en, this message translates to:
  /// **'Celebration Effects'**
  String get celebrationEffects;

  /// No description provided for @celebrationEffectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show celebration effects when completing'**
  String get celebrationEffectsSubtitle;

  /// No description provided for @friendInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend Invitation'**
  String get friendInvitationTitle;

  /// Invited friends count and success rate
  ///
  /// In en, this message translates to:
  /// **'{count} friends invited • {rate}% success rate'**
  String invitedFriends(int count, int rate);

  /// No description provided for @inviteFriendsBonus.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and get bonus points!'**
  String get inviteFriendsBonus;

  /// No description provided for @specialCampaignTitle.
  ///
  /// In en, this message translates to:
  /// **'Special Campaign'**
  String get specialCampaignTitle;

  /// No description provided for @inviteFriendsPoints.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and both of you can get\nup to 3500 points!'**
  String get inviteFriendsPoints;

  /// No description provided for @inviteNow.
  ///
  /// In en, this message translates to:
  /// **'Invite Now'**
  String get inviteNow;

  /// No description provided for @pairTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pairTitle;

  /// No description provided for @pairQuickMessageGreat.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get pairQuickMessageGreat;

  /// No description provided for @pairQuickMessageKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get pairQuickMessageKeepGoing;

  /// No description provided for @pairQuickMessageFinishStrong.
  ///
  /// In en, this message translates to:
  /// **'Finish strong!'**
  String get pairQuickMessageFinishStrong;

  /// No description provided for @pairQuickMessageCompletedGoal.
  ///
  /// In en, this message translates to:
  /// **'Completed the goal!'**
  String get pairQuickMessageCompletedGoal;

  /// No description provided for @pairAnonymousPartner.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Partner'**
  String get pairAnonymousPartner;

  /// Pair category description
  ///
  /// In en, this message translates to:
  /// **'Paired in {questName} quest'**
  String pairPairedQuest(Object questName);

  /// No description provided for @pairHighFiveAction.
  ///
  /// In en, this message translates to:
  /// **'Send High Five'**
  String get pairHighFiveAction;

  /// No description provided for @pairHighFiveSent.
  ///
  /// In en, this message translates to:
  /// **'High Five Sent'**
  String get pairHighFiveSent;

  /// No description provided for @pairQuickMessagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Send a quick message'**
  String get pairQuickMessagePrompt;

  /// No description provided for @pairPartnerHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Grow together with a partner'**
  String get pairPartnerHeroTitle;

  /// No description provided for @pairPartnerHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Having an accountability partner improves achievement rate by 95%. Continue safely and anonymously.'**
  String get pairPartnerHeroDescription;

  /// No description provided for @pairInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you have an invitation code?'**
  String get pairInviteTitle;

  /// No description provided for @pairInviteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get pairInviteHint;

  /// No description provided for @pairInviteApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get pairInviteApply;

  /// No description provided for @pairDividerOr.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get pairDividerOr;

  /// No description provided for @pairRandomMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Random matching'**
  String get pairRandomMatchTitle;

  /// No description provided for @pairAgeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get pairAgeRangeLabel;

  /// No description provided for @pairGoalCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal category'**
  String get pairGoalCategoryLabel;

  /// No description provided for @pairRandomMatchNote.
  ///
  /// In en, this message translates to:
  /// **'Anonymity is protected. Only age range and goal category are shared, and all interactions take place within the app.'**
  String get pairRandomMatchNote;

  /// No description provided for @pairAgeOption1824.
  ///
  /// In en, this message translates to:
  /// **'18-24 years'**
  String get pairAgeOption1824;

  /// No description provided for @pairAgeOption2534.
  ///
  /// In en, this message translates to:
  /// **'25-34 years'**
  String get pairAgeOption2534;

  /// No description provided for @pairAgeOption3544.
  ///
  /// In en, this message translates to:
  /// **'35-44 years'**
  String get pairAgeOption3544;

  /// No description provided for @pairAgeOption45Plus.
  ///
  /// In en, this message translates to:
  /// **'45+ years'**
  String get pairAgeOption45Plus;

  /// No description provided for @pairGoalFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get pairGoalFitness;

  /// No description provided for @pairGoalLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get pairGoalLearning;

  /// No description provided for @pairGoalWellbeing.
  ///
  /// In en, this message translates to:
  /// **'Well-being'**
  String get pairGoalWellbeing;

  /// No description provided for @pairGoalProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get pairGoalProductivity;

  /// No description provided for @voiceTest.
  ///
  /// In en, this message translates to:
  /// **'Voice Test'**
  String get voiceTest;

  /// No description provided for @voiceTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test voice coaching'**
  String get voiceTestSubtitle;

  /// No description provided for @messageTest.
  ///
  /// In en, this message translates to:
  /// **'Message Test'**
  String get messageTest;

  /// No description provided for @messageTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test coaching messages'**
  String get messageTestSubtitle;

  /// Interval in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min interval'**
  String intervalMinutes(int minutes);

  /// Short form of minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @searchQuests.
  ///
  /// In en, this message translates to:
  /// **'Search quests'**
  String get searchQuests;

  /// No description provided for @filterByTags.
  ///
  /// In en, this message translates to:
  /// **'Filter by tags'**
  String get filterByTags;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortByRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get sortByRelevance;

  /// No description provided for @sortByDateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date created'**
  String get sortByDateCreated;

  /// No description provided for @sortByDateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Date updated'**
  String get sortByDateUpdated;

  /// No description provided for @sortByAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get sortByAlphabetical;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get searchHistory;

  /// No description provided for @savedSearches.
  ///
  /// In en, this message translates to:
  /// **'Saved searches'**
  String get savedSearches;

  /// No description provided for @advancedSearch.
  ///
  /// In en, this message translates to:
  /// **'Advanced search'**
  String get advancedSearch;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Number of search results
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String searchResultsCount(int count);

  /// Matched keywords
  ///
  /// In en, this message translates to:
  /// **'Matched keywords: {keywords}'**
  String matchedKeywords(String keywords);

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error occurred'**
  String get searchError;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @exportNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Export feature not implemented'**
  String get exportNotImplemented;

  /// No description provided for @voiceSearchNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Voice search not implemented'**
  String get voiceSearchNotImplemented;

  /// No description provided for @filterOnly.
  ///
  /// In en, this message translates to:
  /// **'Filter only'**
  String get filterOnly;

  /// Results count
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @noSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'No search history'**
  String get noSearchHistory;

  /// No description provided for @noSearchHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Search history will appear here when you perform searches'**
  String get noSearchHistoryDescription;

  /// No description provided for @noSavedSearches.
  ///
  /// In en, this message translates to:
  /// **'No saved searches'**
  String get noSavedSearches;

  /// No description provided for @noSavedSearchesDescription.
  ///
  /// In en, this message translates to:
  /// **'Save frequently used search conditions for quick access'**
  String get noSavedSearchesDescription;

  /// No description provided for @saveSearch.
  ///
  /// In en, this message translates to:
  /// **'Save search'**
  String get saveSearch;

  /// Usage count
  ///
  /// In en, this message translates to:
  /// **'Used {count} times'**
  String usedCount(int count);

  /// No description provided for @clearSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear search history'**
  String get clearSearchHistory;

  /// No description provided for @clearSearchHistoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete all search history? This action cannot be undone.'**
  String get clearSearchHistoryConfirmation;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @historyEntryRemoved.
  ///
  /// In en, this message translates to:
  /// **'History entry removed'**
  String get historyEntryRemoved;

  /// No description provided for @saveSearchNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Save search feature not implemented'**
  String get saveSearchNotImplemented;

  /// No description provided for @editNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Edit feature not implemented'**
  String get editNotImplemented;

  /// No description provided for @deleteSavedSearch.
  ///
  /// In en, this message translates to:
  /// **'Delete saved search'**
  String get deleteSavedSearch;

  /// Saved search deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteSavedSearchConfirmation(String name);

  /// No description provided for @searchSaved.
  ///
  /// In en, this message translates to:
  /// **'Search saved'**
  String get searchSaved;

  /// No description provided for @popularKeywords.
  ///
  /// In en, this message translates to:
  /// **'Popular keywords'**
  String get popularKeywords;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @searchTips.
  ///
  /// In en, this message translates to:
  /// **'Search tips'**
  String get searchTips;

  /// No description provided for @searchTipKeywords.
  ///
  /// In en, this message translates to:
  /// **'Keyword search'**
  String get searchTipKeywords;

  /// No description provided for @searchTipKeywordsDescription.
  ///
  /// In en, this message translates to:
  /// **'Search by title, description, and tags'**
  String get searchTipKeywordsDescription;

  /// No description provided for @searchTipFilters.
  ///
  /// In en, this message translates to:
  /// **'Filter features'**
  String get searchTipFilters;

  /// No description provided for @searchTipFiltersDescription.
  ///
  /// In en, this message translates to:
  /// **'Filter by category, difficulty, location, etc.'**
  String get searchTipFiltersDescription;

  /// No description provided for @searchTipSave.
  ///
  /// In en, this message translates to:
  /// **'Save searches'**
  String get searchTipSave;

  /// No description provided for @searchTipSaveDescription.
  ///
  /// In en, this message translates to:
  /// **'Save frequently used search conditions for quick access'**
  String get searchTipSaveDescription;

  /// No description provided for @searchSettingsNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Search settings not implemented'**
  String get searchSettingsNotImplemented;

  /// No description provided for @searchHelp.
  ///
  /// In en, this message translates to:
  /// **'Search help'**
  String get searchHelp;

  /// No description provided for @searchHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Learn how to use the search features.'**
  String get searchHelpContent;

  /// No description provided for @searchName.
  ///
  /// In en, this message translates to:
  /// **'Search name'**
  String get searchName;

  /// No description provided for @searchNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Exercise quests'**
  String get searchNameHint;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Load error'**
  String get loadError;

  /// No description provided for @animationSettings.
  ///
  /// In en, this message translates to:
  /// **'Animation Settings'**
  String get animationSettings;

  /// No description provided for @animationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Animation Settings'**
  String get animationSettingsTitle;

  /// No description provided for @animationSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize animation behavior and accessibility options'**
  String get animationSettingsDescription;

  /// No description provided for @enableAnimations.
  ///
  /// In en, this message translates to:
  /// **'Enable Animations'**
  String get enableAnimations;

  /// No description provided for @enableAnimationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn on/off all animations in the app'**
  String get enableAnimationsDescription;

  /// No description provided for @reducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduced Motion'**
  String get reducedMotion;

  /// No description provided for @reducedMotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Minimize motion for accessibility'**
  String get reducedMotionDescription;

  /// No description provided for @feedbackSettings.
  ///
  /// In en, this message translates to:
  /// **'Feedback Settings'**
  String get feedbackSettings;

  /// No description provided for @feedbackSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure haptic and sound feedback'**
  String get feedbackSettingsDescription;

  /// No description provided for @hapticFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable vibration feedback for interactions'**
  String get hapticFeedbackDescription;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable sound effects for actions'**
  String get soundEffectsDescription;

  /// No description provided for @animationPreview.
  ///
  /// In en, this message translates to:
  /// **'Animation Preview'**
  String get animationPreview;

  /// No description provided for @animationPreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Test different animation types'**
  String get animationPreviewDescription;

  /// No description provided for @testAnimations.
  ///
  /// In en, this message translates to:
  /// **'Test Animations'**
  String get testAnimations;

  /// No description provided for @testFadeIn.
  ///
  /// In en, this message translates to:
  /// **'Fade In'**
  String get testFadeIn;

  /// No description provided for @testSlideIn.
  ///
  /// In en, this message translates to:
  /// **'Slide In'**
  String get testSlideIn;

  /// No description provided for @testScale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get testScale;

  /// No description provided for @testHaptic.
  ///
  /// In en, this message translates to:
  /// **'Haptic'**
  String get testHaptic;

  /// No description provided for @accessibilityNote.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Note'**
  String get accessibilityNote;

  /// No description provided for @accessibilityNoteDescription.
  ///
  /// In en, this message translates to:
  /// **'These settings help users with motion sensitivity or other accessibility needs. Reduced motion will disable most animations while keeping essential feedback.'**
  String get accessibilityNoteDescription;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @duration5min.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get duration5min;

  /// No description provided for @duration10min.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get duration10min;

  /// No description provided for @duration15min.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get duration15min;

  /// No description provided for @duration30min.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get duration30min;

  /// No description provided for @duration1hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get duration1hour;

  /// No description provided for @locationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get locationHome;

  /// No description provided for @locationGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get locationGym;

  /// No description provided for @locationOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get locationOffice;

  /// No description provided for @locationOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get locationOutdoor;

  /// No description provided for @locationLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get locationLibrary;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @timerCompleted.
  ///
  /// In en, this message translates to:
  /// **'Timer Completed'**
  String get timerCompleted;

  /// No description provided for @workSession.
  ///
  /// In en, this message translates to:
  /// **'Work Session'**
  String get workSession;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break Time'**
  String get breakTime;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @pleaseEnterAnswer.
  ///
  /// In en, this message translates to:
  /// **'Please enter an answer'**
  String get pleaseEnterAnswer;

  /// No description provided for @userSatisfactionSurvey.
  ///
  /// In en, this message translates to:
  /// **'User Satisfaction Survey'**
  String get userSatisfactionSurvey;

  /// No description provided for @userSatisfactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Help us improve MinQ'**
  String get userSatisfactionDescription;

  /// No description provided for @usabilityRating.
  ///
  /// In en, this message translates to:
  /// **'Usability Rating'**
  String get usabilityRating;

  /// No description provided for @mostLikedFeature.
  ///
  /// In en, this message translates to:
  /// **'Most Liked Feature'**
  String get mostLikedFeature;

  /// No description provided for @questManagement.
  ///
  /// In en, this message translates to:
  /// **'Quest Management'**
  String get questManagement;

  /// No description provided for @pairFeature.
  ///
  /// In en, this message translates to:
  /// **'Pair Feature'**
  String get pairFeature;

  /// No description provided for @statisticsGraphs.
  ///
  /// In en, this message translates to:
  /// **'Statistics Graphs'**
  String get statisticsGraphs;

  /// No description provided for @notificationFeature.
  ///
  /// In en, this message translates to:
  /// **'Notification Feature'**
  String get notificationFeature;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @wouldRecommendMinq.
  ///
  /// In en, this message translates to:
  /// **'Would you recommend MinQ to friends?'**
  String get wouldRecommendMinq;

  /// No description provided for @improvementSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Improvement Suggestions'**
  String get improvementSuggestions;

  /// No description provided for @weeklyAchievementHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Weekly Achievement Heatmap'**
  String get weeklyAchievementHeatmap;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get newVersionAvailable;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @newVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available. Please update for the best experience.'**
  String newVersionMessage(String version);

  /// No description provided for @streakTracking.
  ///
  /// In en, this message translates to:
  /// **'Streak Tracking'**
  String get streakTracking;

  /// No description provided for @weeklyStats.
  ///
  /// In en, this message translates to:
  /// **'Weekly Stats'**
  String get weeklyStats;

  /// No description provided for @advancedStats.
  ///
  /// In en, this message translates to:
  /// **'Advanced Stats'**
  String get advancedStats;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get dataExport;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @advancedCustomization.
  ///
  /// In en, this message translates to:
  /// **'Advanced Customization'**
  String get advancedCustomization;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @xpHistory.
  ///
  /// In en, this message translates to:
  /// **'XP History'**
  String get xpHistory;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login to view this feature'**
  String get pleaseLogin;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @noXPHistory.
  ///
  /// In en, this message translates to:
  /// **'No XP history available'**
  String get noXPHistory;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @overallStatistics.
  ///
  /// In en, this message translates to:
  /// **'Overall Statistics'**
  String get overallStatistics;

  /// No description provided for @totalXP.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXP;

  /// No description provided for @weeklyXP.
  ///
  /// In en, this message translates to:
  /// **'Weekly XP'**
  String get weeklyXP;

  /// No description provided for @monthlyXP.
  ///
  /// In en, this message translates to:
  /// **'Monthly XP'**
  String get monthlyXP;

  /// No description provided for @averageDaily.
  ///
  /// In en, this message translates to:
  /// **'Average Daily'**
  String get averageDaily;

  /// No description provided for @xpTrend.
  ///
  /// In en, this message translates to:
  /// **'XP Trend'**
  String get xpTrend;

  /// No description provided for @xpSources.
  ///
  /// In en, this message translates to:
  /// **'XP Sources'**
  String get xpSources;

  /// No description provided for @questComplete.
  ///
  /// In en, this message translates to:
  /// **'Quest Complete'**
  String get questComplete;

  /// No description provided for @miniQuestComplete.
  ///
  /// In en, this message translates to:
  /// **'Mini Quest Complete'**
  String get miniQuestComplete;

  /// No description provided for @streakMilestone.
  ///
  /// In en, this message translates to:
  /// **'Streak Milestone'**
  String get streakMilestone;

  /// No description provided for @challengeComplete.
  ///
  /// In en, this message translates to:
  /// **'Challenge Complete'**
  String get challengeComplete;

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// No description provided for @monthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Goal'**
  String get monthlyGoal;

  /// No description provided for @earlyCompletion.
  ///
  /// In en, this message translates to:
  /// **'Early Completion'**
  String get earlyCompletion;

  /// No description provided for @perfectCompletion.
  ///
  /// In en, this message translates to:
  /// **'Perfect Completion'**
  String get perfectCompletion;

  /// No description provided for @comebackBonus.
  ///
  /// In en, this message translates to:
  /// **'Comeback Bonus'**
  String get comebackBonus;

  /// No description provided for @weekendActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekend Activity'**
  String get weekendActivity;

  /// No description provided for @specialEvent.
  ///
  /// In en, this message translates to:
  /// **'Special Event'**
  String get specialEvent;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @maxLevelReached.
  ///
  /// In en, this message translates to:
  /// **'Max level reached!'**
  String get maxLevelReached;

  /// No description provided for @yourLevel.
  ///
  /// In en, this message translates to:
  /// **'Your Level'**
  String get yourLevel;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @unlockRewards.
  ///
  /// In en, this message translates to:
  /// **'Unlock Rewards'**
  String get unlockRewards;

  /// No description provided for @allFeaturesUnlocked.
  ///
  /// In en, this message translates to:
  /// **'All features unlocked'**
  String get allFeaturesUnlocked;

  /// No description provided for @errorLoadingLevel.
  ///
  /// In en, this message translates to:
  /// **'Error loading level'**
  String get errorLoadingLevel;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @currentXP.
  ///
  /// In en, this message translates to:
  /// **'Current XP'**
  String get currentXP;

  /// No description provided for @xpToNext.
  ///
  /// In en, this message translates to:
  /// **'XP to next level'**
  String get xpToNext;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @questCreation.
  ///
  /// In en, this message translates to:
  /// **'Quest Creation'**
  String get questCreation;

  /// No description provided for @questCompletion.
  ///
  /// In en, this message translates to:
  /// **'Quest Completion'**
  String get questCompletion;

  /// No description provided for @basicStats.
  ///
  /// In en, this message translates to:
  /// **'Basic Stats'**
  String get basicStats;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thankYou;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
