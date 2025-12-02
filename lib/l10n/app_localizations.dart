import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  /// **'再試行する'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'キャンセルする'**
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
  /// **'報告する'**
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

  /// No description provided for @homeDataLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get homeDataLoadError;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection'**
  String get checkConnection;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @welcomeHome.
  ///
  /// In en, this message translates to:
  /// **'Welcome home'**
  String get welcomeHome;

  /// No description provided for @welcomeHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build good habits together'**
  String get welcomeHomeSubtitle;

  /// No description provided for @todaysFocus.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Focus'**
  String get todaysFocus;

  /// No description provided for @aiLearningHabits.
  ///
  /// In en, this message translates to:
  /// **'Learning your habits...'**
  String get aiLearningHabits;

  /// No description provided for @createMiniQuestPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create a mini quest to start'**
  String get createMiniQuestPrompt;

  /// No description provided for @createMiniQuest.
  ///
  /// In en, this message translates to:
  /// **'Create Mini Quest'**
  String get createMiniQuest;

  /// No description provided for @noMiniQuestsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Mini Quests'**
  String get noMiniQuestsTitle;

  /// No description provided for @noMiniQuestsMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any quests yet'**
  String get noMiniQuestsMessage;

  /// No description provided for @yourMiniQuests.
  ///
  /// In en, this message translates to:
  /// **'Your Mini Quests'**
  String get yourMiniQuests;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @weeklyStreak.
  ///
  /// In en, this message translates to:
  /// **'Weekly Streak'**
  String get weeklyStreak;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
