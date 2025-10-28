// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get goodMorning => 'Good Morning!';

  @override
  String get todaysQuests => 'Today\'s Quests';

  @override
  String get todays3Recommendations => 'Today\'s 3 recommendations';

  @override
  String get swapOrSnooze => 'Swap or snooze can be changed with one tap.';

  @override
  String get replacedRecommendation => 'Replaced the recommendation.';

  @override
  String get snoozedRecommendation =>
      'Snoozed this recommendation until tomorrow.';

  @override
  String get noQuestsToday => 'No Quests for today yet';

  @override
  String get chooseFromTemplate =>
      'Choose from a template and start your 3-tap habit.';

  @override
  String get findAQuest => 'クエストを探す';

  @override
  String get swapRecommendation => '別のおすすめに入れ替える';

  @override
  String get snoozeUntilTomorrow => '明日までスヌーズする';

  @override
  String get snoozed => 'Snoozed';

  @override
  String get undo => 'Undo';

  @override
  String get dismissHelpBanner => 'Dismiss tips';

  @override
  String get openProfile => 'Open profile';

  @override
  String get snoozeTemporarilyDisabled => 'Snooze is temporarily disabled';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsPushNotifications => 'Push Notifications';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Reminders and partner updates';

  @override
  String get settingsNotificationTime => 'Notification Time';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsProfile => 'Profile Settings';

  @override
  String get settingsSectionPrivacy => 'Privacy and Data';

  @override
  String get settingsDataSync => 'データ同期を設定する';

  @override
  String get settingsDataSyncSubtitle => 'Sync data across devices';

  @override
  String get settingsManageBlockedUsers => 'ブロック中のユーザーを管理する';

  @override
  String get settingsExportData => 'データをエクスポートする';

  @override
  String get settingsDeleteAccount => 'アカウントとデータを削除する';

  @override
  String get settingsSectionAbout => 'About MinQ';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsSectionDeveloper => 'Developer Options';

  @override
  String get settingsUseDummyData => 'Use Dummy Data';

  @override
  String get settingsUseDummyDataSubtitle =>
      'Use dummy data instead of the database.';

  @override
  String get settingsSocialSharingDemo => 'ソーシャル共有デモを試す';

  @override
  String get settingsSocialSharingDemoSubtitle =>
      'Test social sharing and celebration features';

  @override
  String get questsTitle => 'Mini-Quests';

  @override
  String get questsSearchHint => 'Search for templates...';

  @override
  String get questsFabLabel => 'Create Custom';

  @override
  String get questsCategoryFeatured => 'Featured';

  @override
  String get questsCategoryMyQuests => 'My Quests';

  @override
  String get questsCategoryAll => 'All';

  @override
  String get questsCategoryLearning => 'Learning';

  @override
  String get questsCategoryExercise => 'Exercise';

  @override
  String get questsCategoryTidying => 'Tidying';

  @override
  String get questsCategoryRecent => 'Recent';

  @override
  String get authErrorOperationNotAllowed =>
      'Anonymous sign-in is not enabled for this project.';

  @override
  String get authErrorWeakPassword => 'The password provided is too weak.';

  @override
  String get authErrorEmailAlreadyInUse =>
      'An account already exists for that email.';

  @override
  String get authErrorInvalidEmail => 'The email address is not valid.';

  @override
  String get authErrorUserDisabled => 'This user has been disabled.';

  @override
  String get authErrorUserNotFound => 'No user found for this email.';

  @override
  String get authErrorWrongPassword => 'Wrong password provided for this user.';

  @override
  String get authErrorAccountExistsWithDifferentCredential =>
      'An account already exists with the same email address but different sign-in credentials.';

  @override
  String get authErrorInvalidCredential =>
      'The credential received is malformed or has expired.';

  @override
  String get authErrorUnknown => 'An unknown error occurred.';

  @override
  String get back => 'Back';

  @override
  String get pairMatchingTimeoutTitle => 'Matching Timed Out';

  @override
  String get pairMatchingTimeoutMessage =>
      'We couldn\'t find a buddy for you in time. Please try again or check back later.';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get messageSentFailed => 'Failed to send message';

  @override
  String get chatInputHint => 'Type a message...';

  @override
  String get notificationPermissionDialogTitle => 'Enable Notifications?';

  @override
  String get notificationPermissionDialogMessage =>
      'Get reminders for your quests and updates from your buddy. You can change this anytime in settings.';

  @override
  String get notificationPermissionDialogBenefitsHeading =>
      'What you get by enabling notifications';

  @override
  String get notificationPermissionDialogBenefitReminders =>
      'Receive quest reminders at the times you choose.';

  @override
  String get notificationPermissionDialogBenefitPair =>
      'Never miss encouragement or updates from your pair.';

  @override
  String get notificationPermissionDialogBenefitGoal =>
      'Stay on track by logging goals right away.';

  @override
  String get notificationPermissionDialogFooter =>
      'You can adjust notification settings anytime.';

  @override
  String get enable => 'Enable';

  @override
  String get later => 'Later';

  @override
  String get shareFailed => 'Failed to share progress. Please try again.';

  @override
  String get accountDeletionTitle => 'Account Deletion';

  @override
  String get accountDeletionWarning =>
      'This is a permanent action. After a 7-day grace period, all your data, including quests, progress, and pairs, will be permanently erased. You can cancel this process by logging in again within 7 days.';

  @override
  String get accountDeletionConfirmationCheckbox =>
      'I understand the consequences and wish to permanently delete my account.';

  @override
  String get accountDeletionConfirmDialogTitle => 'Final confirmation';

  @override
  String get accountDeletionConfirmDialogDescription =>
      'Deleting your account will:\n• Permanently remove quests and progress logs\n• Erase pair chat history\n• Require sign-in within 7 days to restore\n\nAre you absolutely sure you want to continue?';

  @override
  String get accountDeletionConfirmDialogPrompt =>
      'Type the following to confirm';

  @override
  String get accountDeletionConfirmPhrase => 'DELETE';

  @override
  String get accountDeletionConfirmButton => 'Permanently delete';

  @override
  String get deleteMyAccountButton => 'Delete My Account';

  @override
  String get blockUser => 'ユーザーをブロックする';

  @override
  String get reportUser => 'ユーザーを報告する';

  @override
  String get userBlocked => 'User has been blocked.';

  @override
  String get reportSubmitted => 'Report has been submitted.';

  @override
  String get block => 'ブロックする';

  @override
  String get report => 'Report';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get blockConfirmation =>
      'Blocking this user will prevent them from contacting you. This can be undone in settings.';

  @override
  String get reportConfirmation =>
      'Please provide a brief reason for the report. This helps us take appropriate action.';

  @override
  String get reason => 'Reason';

  @override
  String get notSignedIn => 'You are not signed in.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again later.';

  @override
  String get pairTitle => 'ペア';

  @override
  String get pairAnonymousPartner => '匿名のパートナー';

  @override
  String pairPairedQuest(Object questName) {
    return '$questNameのクエストでペアリング中';
  }

  @override
  String get pairHighFiveAction => 'ハイタッチを送る';

  @override
  String get pairHighFiveSent => 'ハイタッチを送信済み';

  @override
  String get pairQuickMessagePrompt => 'ひとことメッセージを送る';

  @override
  String get pairQuickMessageGreat => 'すばらしいよ！';

  @override
  String get pairQuickMessageKeepGoing => 'その調子でいこう！';

  @override
  String get pairQuickMessageFinishStrong => '最後までやり切ろう！';

  @override
  String get pairQuickMessageCompletedGoal => '目標を達成したよ！';

  @override
  String streakDayCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '連続$count日',
      zero: '連続0日',
    );
    return '$_temp0';
  }

  @override
  String get celebrationNewLongestStreak => '連続記録を更新しました！';

  @override
  String celebrationStreakMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日連続を達成！',
      zero: 'まだ記録がありません。今日から始めましょう！',
    );
    return '$_temp0';
  }

  @override
  String get celebrationLongestSubtitle => '自己ベストを更新しました！';

  @override
  String get celebrationKeepGoingSubtitle => 'とても順調です。この調子で続けましょう。';

  @override
  String get celebrationRewardTitle => 'ごほうび';

  @override
  String get celebrationRewardName => '1分間の呼吸エクササイズ';

  @override
  String get celebrationRewardDescription => '深呼吸で心を整えましょう';

  @override
  String get celebrationDone => '完了する';

  @override
  String get pairPartnerHeroTitle => 'パートナーと一緒に成長しよう！';

  @override
  String get pairPartnerHeroDescription =>
      'アカウンタビリティパートナーがいると達成率が95%向上します。匿名で安心して続けましょう。';

  @override
  String get pairInviteTitle => '招待コードをお持ちですか？';

  @override
  String get pairInviteHint => 'コードを入力してください';

  @override
  String get pairInviteApply => '適用する';

  @override
  String get pairDividerOr => 'または';

  @override
  String get pairRandomMatchTitle => 'ランダムでマッチングする';

  @override
  String get pairAgeRangeLabel => '年齢帯';

  @override
  String get pairGoalCategoryLabel => '目標カテゴリ';

  @override
  String get pairRandomMatchNote =>
      '匿名性は守られます。年齢帯と目標カテゴリのみが共有され、すべてのやり取りはアプリ内で行われます。';

  @override
  String get pairAgeOption1824 => '18-24歳';

  @override
  String get pairAgeOption2534 => '25-34歳';

  @override
  String get pairAgeOption3544 => '35-44歳';

  @override
  String get pairAgeOption45Plus => '45歳以上';

  @override
  String get pairGoalFitness => 'フィットネス';

  @override
  String get pairGoalLearning => '学習';

  @override
  String get pairGoalWellbeing => 'ウェルビーイング';

  @override
  String get pairGoalProductivity => '生産性';

  @override
  String get newVersionAvailable => 'New Version Available';

  @override
  String newVersionMessage(Object version) {
    return 'A new version ($version) is available.\nWe recommend updating for a better experience.';
  }

  @override
  String get viewDetails => 'View Details';

  @override
  String get skip => 'Skip';

  @override
  String get complete => 'Complete';

  @override
  String get next => 'Next';

  @override
  String get delivered => 'Delivered';

  @override
  String get pending => 'Pending';

  @override
  String get canOpen => 'Can Open';

  @override
  String deliveryDate(int year, int month, int day) {
    return 'Delivery Date: $year/$month/$day';
  }

  @override
  String get tapToOpen => 'Tap to Open';

  @override
  String question(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String get submit => 'Submit';

  @override
  String get send => 'Send';

  @override
  String get pleaseEnterAnswer => 'Please enter your answer';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get userSatisfactionSurvey => 'User Satisfaction Survey';

  @override
  String get userSatisfactionDescription =>
      'Help us improve MinQ by sharing your feedback';

  @override
  String get mostLikedFeature => 'What is your most liked feature?';

  @override
  String get questManagement => 'Quest Management';

  @override
  String get pairFeature => 'Pair Feature';

  @override
  String get statisticsGraphs => 'Statistics & Graphs';

  @override
  String get notificationFeature => 'Notification Feature';

  @override
  String get other => 'Other';

  @override
  String get wouldRecommendMinq => 'Would you recommend MinQ to friends?';

  @override
  String get improvementSuggestions => 'Any suggestions for improvement?';

  @override
  String get serverConnectionFailed => 'Failed to connect to server';

  @override
  String get friendInvitation => 'Friend Invitation';

  @override
  String get inviteFriendsForBonus => 'Invite friends and get bonus points!';

  @override
  String get specialCampaign => 'Special Campaign';

  @override
  String get inviteFriendsMessage =>
      'Invite friends and both of you can get\nup to 3500 points!';

  @override
  String get inviteNow => 'Invite Now';

  @override
  String get start => 'Start';

  @override
  String get resume => 'Resume';

  @override
  String get reset => 'Reset';

  @override
  String get pause => 'Pause';

  @override
  String get completed => 'Completed!';

  @override
  String get paused => 'Paused';

  @override
  String get timerCompleted => 'Timer Completed!';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get noInternetConnection =>
      'No internet connection.\n\nSome features may not work properly.\nPlease check your connection and try again.';

  @override
  String get offline => 'Offline';

  @override
  String get offlineOperationNotAvailable =>
      'This operation is not available offline';

  @override
  String get showActivity => 'Show Activity';

  @override
  String get showActivitySubtitle => 'Display your activity to other users';

  @override
  String get allowInteraction => 'Allow Interaction';

  @override
  String get allowInteractionSubtitle =>
      'Receive encouragement from other users';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackSubtitle => 'Vibrate during activities';

  @override
  String get celebrationEffects => 'Celebration Effects';

  @override
  String get celebrationEffectsSubtitle =>
      'Show celebration effects when completing';

  @override
  String get levelDetails => 'Level Details';

  @override
  String levelDetailsMessage(int level, int progress) {
    return 'Current Level: $level\nProgress: $progress%';
  }

  @override
  String get close => 'Close';

  @override
  String get editHabitScreen => 'Navigate to habit edit screen';

  @override
  String get addNewHabit => 'Add new habit';

  @override
  String get executeHabitToday => 'Execute today\'s habit';

  @override
  String get createMiniHabit => 'Create mini habit';

  @override
  String get navigateToChallenges => 'Navigate to challenges screen';

  @override
  String get executePrevention => 'Execute Prevention';

  @override
  String get executeNow => 'Execute Now';

  @override
  String get showPreventionPlan => 'Show prevention plan';

  @override
  String get navigateToHabitExecution => 'Navigate to habit execution screen';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get detailedAnalysis => 'Detailed Analysis';

  @override
  String get improvementSuggestion => 'Improvement Suggestion';

  @override
  String get createQuest => 'Create Quest';

  @override
  String get viewTodaysQuests => 'View Today\'s Quests';

  @override
  String get findPair => 'Find Pair';

  @override
  String get allowPermission => 'Allow Permission';

  @override
  String get thankYou => 'Thank You';

  @override
  String get voiceTest => 'Voice Test';

  @override
  String get voiceTestSubtitle => 'Test voice coaching';

  @override
  String get weeklyAchievementHeatmap => 'Weekly Achievement Heatmap';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get test => 'Test';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String createdOn(int year, int month, int day) {
    return 'Created on $year/$month/$day';
  }

  @override
  String daysUntil(int days) {
    return '$days days';
  }

  @override
  String get required => ' *Required';

  @override
  String get usabilityRating =>
      'Please rate MinQ\'s usability on a scale of 1-5';

  @override
  String get friendInvitationTitle => 'Friend Invitation';

  @override
  String invitedFriends(int count, int rate) {
    return '$count friends invited • $rate% success rate';
  }

  @override
  String get inviteFriendsBonus => 'Invite friends and get bonus points!';

  @override
  String get specialCampaignTitle => 'Special Campaign';

  @override
  String get inviteFriendsPoints =>
      'Invite friends and both of you can get\nup to 3500 points!';

  @override
  String get searchQuests => 'Search quests...';

  @override
  String get filterByTags => 'Filter by tags';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get estimatedTime => 'Estimated Time';

  @override
  String get location => 'Location';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get duration5min => '5 min';

  @override
  String get duration10min => '10 min';

  @override
  String get duration15min => '15 min';

  @override
  String get duration30min => '30 min';

  @override
  String get duration1hour => '1 hour';

  @override
  String get locationHome => 'Home';

  @override
  String get locationGym => 'Gym';

  @override
  String get locationOffice => 'Office';

  @override
  String get locationOutdoor => 'Outdoor';

  @override
  String get locationLibrary => 'Library';

  @override
  String get progress => 'Progress';

  @override
  String get ready => 'Ready';

  @override
  String get running => 'Running';

  @override
  String get workSession => 'Work Session';

  @override
  String get breakTime => 'Break';

  @override
  String get messageTest => 'Message Test';

  @override
  String get messageTestSubtitle => 'Test coaching messages';

  @override
  String intervalMinutes(int minutes) {
    return '$minutes min interval';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get getStarted => 'Get Started';

  @override
  String get aiImprovementSuggestion => 'AI Improvement Suggestion';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get newsAndChangelog => 'News & Changelog';

  @override
  String get communityBoard => 'Community Board';

  @override
  String get post => 'Post';

  @override
  String failedToLoadPosts(String error) {
    return 'Failed to load posts: $error';
  }

  @override
  String get deleteHabit => 'Delete Habit';

  @override
  String deleteHabitConfirm(String title) {
    return 'Delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get previous => 'Previous';

  @override
  String get update => 'Update';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get unsavedChangesWillBeLost => 'Unsaved changes will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get habitName => 'Habit Name';

  @override
  String get targetValue => 'Target Value';

  @override
  String get reload => 'Reload';

  @override
  String get loadingReminders => 'Loading reminders...';

  @override
  String get addTime => 'Add Time';

  @override
  String get notSignedInCannotRecord =>
      'Cannot record because you are not signed in.';

  @override
  String get photoCancelled => 'Photo capture was cancelled.';

  @override
  String get bgmPlaybackFailed => 'Failed to play BGM.';

  @override
  String get bgmIdentificationUnavailable =>
      'BGM identification is currently unavailable';

  @override
  String get couldNotIdentifySong => 'Could not identify the song';

  @override
  String get bgmIdentificationFailed => 'BGM identification failed';

  @override
  String get stop => 'Stop';

  @override
  String get play => 'Play';

  @override
  String get confirmPhoto => 'Please confirm the photo';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get useThisPhoto => 'Use This Photo';

  @override
  String get showOfflineQueue => 'Show Offline Queue';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get selfReportInstead => 'Self-report instead';

  @override
  String get save => 'Save';

  @override
  String get viewQuests => 'View Quests';

  @override
  String get startNow => 'Start Now';

  @override
  String get csvFormat => 'CSV Format';

  @override
  String get imageFormat => 'Image Format';

  @override
  String get exportFeatureUnavailable =>
      'Export feature is currently unavailable';

  @override
  String get statsDataExported => 'Statistics data exported';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get imageExportInPreparation =>
      'Image export feature is in preparation';

  @override
  String get backToQuestList => 'Back to Quest List';

  @override
  String get questNotFound => 'Quest not found';
}
