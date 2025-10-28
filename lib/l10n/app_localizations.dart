import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ja'),
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
  /// **'クエストを探す'**
  String get findAQuest;

  /// No description provided for @swapRecommendation.
  ///
  /// In en, this message translates to:
  /// **'別のおすすめに入れ替える'**
  String get swapRecommendation;

  /// No description provided for @snoozeUntilTomorrow.
  ///
  /// In en, this message translates to:
  /// **'明日までスヌーズする'**
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
  /// **'データ同期を設定する'**
  String get settingsDataSync;

  /// No description provided for @settingsDataSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync data across devices'**
  String get settingsDataSyncSubtitle;

  /// No description provided for @settingsManageBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'ブロック中のユーザーを管理する'**
  String get settingsManageBlockedUsers;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'データをエクスポートする'**
  String get settingsExportData;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'アカウントとデータを削除する'**
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
  /// **'ソーシャル共有デモを試す'**
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

  /// No description provided for @pairMatchingTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Matching Timed Out'**
  String get pairMatchingTimeoutTitle;

  /// No description provided for @pairMatchingTimeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find a buddy for you in time. Please try again or check back later.'**
  String get pairMatchingTimeoutMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @messageSentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get messageSentFailed;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatInputHint;

  /// No description provided for @notificationPermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications?'**
  String get notificationPermissionDialogTitle;

  /// No description provided for @notificationPermissionDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Get reminders for your quests and updates from your buddy. You can change this anytime in settings.'**
  String get notificationPermissionDialogMessage;

  /// No description provided for @notificationPermissionDialogBenefitsHeading.
  ///
  /// In en, this message translates to:
  /// **'What you get by enabling notifications'**
  String get notificationPermissionDialogBenefitsHeading;

  /// No description provided for @notificationPermissionDialogBenefitReminders.
  ///
  /// In en, this message translates to:
  /// **'Receive quest reminders at the times you choose.'**
  String get notificationPermissionDialogBenefitReminders;

  /// No description provided for @notificationPermissionDialogBenefitPair.
  ///
  /// In en, this message translates to:
  /// **'Never miss encouragement or updates from your pair.'**
  String get notificationPermissionDialogBenefitPair;

  /// No description provided for @notificationPermissionDialogBenefitGoal.
  ///
  /// In en, this message translates to:
  /// **'Stay on track by logging goals right away.'**
  String get notificationPermissionDialogBenefitGoal;

  /// No description provided for @notificationPermissionDialogFooter.
  ///
  /// In en, this message translates to:
  /// **'You can adjust notification settings anytime.'**
  String get notificationPermissionDialogFooter;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share progress. Please try again.'**
  String get shareFailed;

  /// No description provided for @accountDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion'**
  String get accountDeletionTitle;

  /// No description provided for @accountDeletionWarning.
  ///
  /// In en, this message translates to:
  /// **'This is a permanent action. After a 7-day grace period, all your data, including quests, progress, and pairs, will be permanently erased. You can cancel this process by logging in again within 7 days.'**
  String get accountDeletionWarning;

  /// No description provided for @accountDeletionConfirmationCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand the consequences and wish to permanently delete my account.'**
  String get accountDeletionConfirmationCheckbox;

  /// No description provided for @accountDeletionConfirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Final confirmation'**
  String get accountDeletionConfirmDialogTitle;

  /// No description provided for @accountDeletionConfirmDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will:\n• Permanently remove quests and progress logs\n• Erase pair chat history\n• Require sign-in within 7 days to restore\n\nAre you absolutely sure you want to continue?'**
  String get accountDeletionConfirmDialogDescription;

  /// No description provided for @accountDeletionConfirmDialogPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type the following to confirm'**
  String get accountDeletionConfirmDialogPrompt;

  /// No description provided for @accountDeletionConfirmPhrase.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get accountDeletionConfirmPhrase;

  /// No description provided for @accountDeletionConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete'**
  String get accountDeletionConfirmButton;

  /// No description provided for @deleteMyAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccountButton;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'ユーザーをブロックする'**
  String get blockUser;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'ユーザーを報告する'**
  String get reportUser;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User has been blocked.'**
  String get userBlocked;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report has been submitted.'**
  String get reportSubmitted;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'ブロックする'**
  String get block;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @blockConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Blocking this user will prevent them from contacting you. This can be undone in settings.'**
  String get blockConfirmation;

  /// No description provided for @reportConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Please provide a brief reason for the report. This helps us take appropriate action.'**
  String get reportConfirmation;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in.'**
  String get notSignedIn;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get errorGeneric;

  /// No description provided for @pairTitle.
  ///
  /// In en, this message translates to:
  /// **'ペア'**
  String get pairTitle;

  /// No description provided for @pairAnonymousPartner.
  ///
  /// In en, this message translates to:
  /// **'匿名のパートナー'**
  String get pairAnonymousPartner;

  /// ペアのカテゴリ名を含む説明文
  ///
  /// In en, this message translates to:
  /// **'{questName}のクエストでペアリング中'**
  String pairPairedQuest(Object questName);

  /// No description provided for @pairHighFiveAction.
  ///
  /// In en, this message translates to:
  /// **'ハイタッチを送る'**
  String get pairHighFiveAction;

  /// No description provided for @pairHighFiveSent.
  ///
  /// In en, this message translates to:
  /// **'ハイタッチを送信済み'**
  String get pairHighFiveSent;

  /// No description provided for @pairQuickMessagePrompt.
  ///
  /// In en, this message translates to:
  /// **'ひとことメッセージを送る'**
  String get pairQuickMessagePrompt;

  /// No description provided for @pairQuickMessageGreat.
  ///
  /// In en, this message translates to:
  /// **'すばらしいよ！'**
  String get pairQuickMessageGreat;

  /// No description provided for @pairQuickMessageKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'その調子でいこう！'**
  String get pairQuickMessageKeepGoing;

  /// No description provided for @pairQuickMessageFinishStrong.
  ///
  /// In en, this message translates to:
  /// **'最後までやり切ろう！'**
  String get pairQuickMessageFinishStrong;

  /// No description provided for @pairQuickMessageCompletedGoal.
  ///
  /// In en, this message translates to:
  /// **'目標を達成したよ！'**
  String get pairQuickMessageCompletedGoal;

  /// 現在の連続日数を示すテキスト
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {連続0日} other {連続{count}日}}'**
  String streakDayCount(num count);

  /// No description provided for @celebrationNewLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'連続記録を更新しました！'**
  String get celebrationNewLongestStreak;

  /// 連続日数の祝福メッセージ
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {まだ記録がありません。今日から始めましょう！} other {{count}日連続を達成！}}'**
  String celebrationStreakMessage(num count);

  /// No description provided for @celebrationLongestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'自己ベストを更新しました！'**
  String get celebrationLongestSubtitle;

  /// No description provided for @celebrationKeepGoingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'とても順調です。この調子で続けましょう。'**
  String get celebrationKeepGoingSubtitle;

  /// No description provided for @celebrationRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'ごほうび'**
  String get celebrationRewardTitle;

  /// No description provided for @celebrationRewardName.
  ///
  /// In en, this message translates to:
  /// **'1分間の呼吸エクササイズ'**
  String get celebrationRewardName;

  /// No description provided for @celebrationRewardDescription.
  ///
  /// In en, this message translates to:
  /// **'深呼吸で心を整えましょう'**
  String get celebrationRewardDescription;

  /// No description provided for @celebrationDone.
  ///
  /// In en, this message translates to:
  /// **'完了する'**
  String get celebrationDone;

  /// No description provided for @pairPartnerHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'パートナーと一緒に成長しよう！'**
  String get pairPartnerHeroTitle;

  /// No description provided for @pairPartnerHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'アカウンタビリティパートナーがいると達成率が95%向上します。匿名で安心して続けましょう。'**
  String get pairPartnerHeroDescription;

  /// No description provided for @pairInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'招待コードをお持ちですか？'**
  String get pairInviteTitle;

  /// No description provided for @pairInviteHint.
  ///
  /// In en, this message translates to:
  /// **'コードを入力してください'**
  String get pairInviteHint;

  /// No description provided for @pairInviteApply.
  ///
  /// In en, this message translates to:
  /// **'適用する'**
  String get pairInviteApply;

  /// No description provided for @pairDividerOr.
  ///
  /// In en, this message translates to:
  /// **'または'**
  String get pairDividerOr;

  /// No description provided for @pairRandomMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'ランダムでマッチングする'**
  String get pairRandomMatchTitle;

  /// No description provided for @pairAgeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'年齢帯'**
  String get pairAgeRangeLabel;

  /// No description provided for @pairGoalCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'目標カテゴリ'**
  String get pairGoalCategoryLabel;

  /// No description provided for @pairRandomMatchNote.
  ///
  /// In en, this message translates to:
  /// **'匿名性は守られます。年齢帯と目標カテゴリのみが共有され、すべてのやり取りはアプリ内で行われます。'**
  String get pairRandomMatchNote;

  /// No description provided for @pairAgeOption1824.
  ///
  /// In en, this message translates to:
  /// **'18-24歳'**
  String get pairAgeOption1824;

  /// No description provided for @pairAgeOption2534.
  ///
  /// In en, this message translates to:
  /// **'25-34歳'**
  String get pairAgeOption2534;

  /// No description provided for @pairAgeOption3544.
  ///
  /// In en, this message translates to:
  /// **'35-44歳'**
  String get pairAgeOption3544;

  /// No description provided for @pairAgeOption45Plus.
  ///
  /// In en, this message translates to:
  /// **'45歳以上'**
  String get pairAgeOption45Plus;

  /// No description provided for @pairGoalFitness.
  ///
  /// In en, this message translates to:
  /// **'フィットネス'**
  String get pairGoalFitness;

  /// No description provided for @pairGoalLearning.
  ///
  /// In en, this message translates to:
  /// **'学習'**
  String get pairGoalLearning;

  /// No description provided for @pairGoalWellbeing.
  ///
  /// In en, this message translates to:
  /// **'ウェルビーイング'**
  String get pairGoalWellbeing;

  /// No description provided for @pairGoalProductivity.
  ///
  /// In en, this message translates to:
  /// **'生産性'**
  String get pairGoalProductivity;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get newVersionAvailable;

  /// New version message
  ///
  /// In en, this message translates to:
  /// **'A new version ({version}) is available.\nWe recommend updating for a better experience.'**
  String newVersionMessage(Object version);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

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

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @canOpen.
  ///
  /// In en, this message translates to:
  /// **'Can Open'**
  String get canOpen;

  /// Delivery date format
  ///
  /// In en, this message translates to:
  /// **'Delivery Date: {year}/{month}/{day}'**
  String deliveryDate(int year, int month, int day);

  /// No description provided for @tapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to Open'**
  String get tapToOpen;

  /// Question counter
  ///
  /// In en, this message translates to:
  /// **'Question {current} / {total}'**
  String question(int current, int total);

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @pleaseEnterAnswer.
  ///
  /// In en, this message translates to:
  /// **'Please enter your answer'**
  String get pleaseEnterAnswer;

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

  /// No description provided for @userSatisfactionSurvey.
  ///
  /// In en, this message translates to:
  /// **'User Satisfaction Survey'**
  String get userSatisfactionSurvey;

  /// No description provided for @userSatisfactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Help us improve MinQ by sharing your feedback'**
  String get userSatisfactionDescription;

  /// No description provided for @mostLikedFeature.
  ///
  /// In en, this message translates to:
  /// **'What is your most liked feature?'**
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
  /// **'Statistics & Graphs'**
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
  /// **'Any suggestions for improvement?'**
  String get improvementSuggestions;

  /// No description provided for @serverConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server'**
  String get serverConnectionFailed;

  /// No description provided for @friendInvitation.
  ///
  /// In en, this message translates to:
  /// **'Friend Invitation'**
  String get friendInvitation;

  /// No description provided for @inviteFriendsForBonus.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and get bonus points!'**
  String get inviteFriendsForBonus;

  /// No description provided for @specialCampaign.
  ///
  /// In en, this message translates to:
  /// **'Special Campaign'**
  String get specialCampaign;

  /// No description provided for @inviteFriendsMessage.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and both of you can get\nup to 3500 points!'**
  String get inviteFriendsMessage;

  /// No description provided for @inviteNow.
  ///
  /// In en, this message translates to:
  /// **'Invite Now'**
  String get inviteNow;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get completed;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @timerCompleted.
  ///
  /// In en, this message translates to:
  /// **'Timer Completed!'**
  String get timerCompleted;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.\n\nSome features may not work properly.\nPlease check your connection and try again.'**
  String get noInternetConnection;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @offlineOperationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This operation is not available offline'**
  String get offlineOperationNotAvailable;

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

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

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

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

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

  /// No description provided for @createQuest.
  ///
  /// In en, this message translates to:
  /// **'Create Quest'**
  String get createQuest;

  /// No description provided for @viewTodaysQuests.
  ///
  /// In en, this message translates to:
  /// **'View Today\'s Quests'**
  String get viewTodaysQuests;

  /// No description provided for @findPair.
  ///
  /// In en, this message translates to:
  /// **'Find Pair'**
  String get findPair;

  /// No description provided for @allowPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow Permission'**
  String get allowPermission;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get thankYou;

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

  /// No description provided for @weeklyAchievementHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Weekly Achievement Heatmap'**
  String get weeklyAchievementHeatmap;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

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

  /// Creation date format
  ///
  /// In en, this message translates to:
  /// **'Created on {year}/{month}/{day}'**
  String createdOn(int year, int month, int day);

  /// Days counter
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysUntil(int days);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **' *Required'**
  String get required;

  /// No description provided for @usabilityRating.
  ///
  /// In en, this message translates to:
  /// **'Please rate MinQ\'s usability on a scale of 1-5'**
  String get usabilityRating;

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

  /// No description provided for @searchQuests.
  ///
  /// In en, this message translates to:
  /// **'Search quests...'**
  String get searchQuests;

  /// No description provided for @filterByTags.
  ///
  /// In en, this message translates to:
  /// **'Filter by tags'**
  String get filterByTags;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

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
  /// **'5 min'**
  String get duration5min;

  /// No description provided for @duration10min.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get duration10min;

  /// No description provided for @duration15min.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get duration15min;

  /// No description provided for @duration30min.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
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

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @workSession.
  ///
  /// In en, this message translates to:
  /// **'Work Session'**
  String get workSession;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakTime;

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

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @aiImprovementSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI Improvement Suggestion'**
  String get aiImprovementSuggestion;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @newsAndChangelog.
  ///
  /// In en, this message translates to:
  /// **'News & Changelog'**
  String get newsAndChangelog;

  /// No description provided for @communityBoard.
  ///
  /// In en, this message translates to:
  /// **'Community Board'**
  String get communityBoard;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// Failed to load posts message
  ///
  /// In en, this message translates to:
  /// **'Failed to load posts: {error}'**
  String failedToLoadPosts(String error);

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get deleteHabit;

  /// Delete habit confirmation message
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This action cannot be undone.'**
  String deleteHabitConfirm(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

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

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @habitName.
  ///
  /// In en, this message translates to:
  /// **'Habit Name'**
  String get habitName;

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'Target Value'**
  String get targetValue;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @loadingReminders.
  ///
  /// In en, this message translates to:
  /// **'Loading reminders...'**
  String get loadingReminders;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add Time'**
  String get addTime;

  /// No description provided for @notSignedInCannotRecord.
  ///
  /// In en, this message translates to:
  /// **'Cannot record because you are not signed in.'**
  String get notSignedInCannotRecord;

  /// No description provided for @photoCancelled.
  ///
  /// In en, this message translates to:
  /// **'Photo capture was cancelled.'**
  String get photoCancelled;

  /// No description provided for @bgmPlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to play BGM.'**
  String get bgmPlaybackFailed;

  /// No description provided for @bgmIdentificationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'BGM identification is currently unavailable'**
  String get bgmIdentificationUnavailable;

  /// No description provided for @couldNotIdentifySong.
  ///
  /// In en, this message translates to:
  /// **'Could not identify the song'**
  String get couldNotIdentifySong;

  /// No description provided for @bgmIdentificationFailed.
  ///
  /// In en, this message translates to:
  /// **'BGM identification failed'**
  String get bgmIdentificationFailed;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @confirmPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the photo'**
  String get confirmPhoto;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @useThisPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use This Photo'**
  String get useThisPhoto;

  /// No description provided for @showOfflineQueue.
  ///
  /// In en, this message translates to:
  /// **'Show Offline Queue'**
  String get showOfflineQueue;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @selfReportInstead.
  ///
  /// In en, this message translates to:
  /// **'Self-report instead'**
  String get selfReportInstead;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @viewQuests.
  ///
  /// In en, this message translates to:
  /// **'View Quests'**
  String get viewQuests;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @csvFormat.
  ///
  /// In en, this message translates to:
  /// **'CSV Format'**
  String get csvFormat;

  /// No description provided for @imageFormat.
  ///
  /// In en, this message translates to:
  /// **'Image Format'**
  String get imageFormat;

  /// No description provided for @exportFeatureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Export feature is currently unavailable'**
  String get exportFeatureUnavailable;

  /// No description provided for @statsDataExported.
  ///
  /// In en, this message translates to:
  /// **'Statistics data exported'**
  String get statsDataExported;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @imageExportInPreparation.
  ///
  /// In en, this message translates to:
  /// **'Image export feature is in preparation'**
  String get imageExportInPreparation;

  /// No description provided for @backToQuestList.
  ///
  /// In en, this message translates to:
  /// **'Back to Quest List'**
  String get backToQuestList;

  /// No description provided for @questNotFound.
  ///
  /// In en, this message translates to:
  /// **'Quest not found'**
  String get questNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ja'].contains(locale.languageCode);

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
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
