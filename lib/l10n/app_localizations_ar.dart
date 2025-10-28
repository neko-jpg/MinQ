// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get goodMorning => 'صباح الخير!';

  @override
  String get todaysQuests => 'مهام اليوم';

  @override
  String get todays3Recommendations => '3 توصيات لليوم';

  @override
  String get swapOrSnooze => 'يمكن تغيير التبديل أو الغفوة بنقرة واحدة.';

  @override
  String get replacedRecommendation => 'تم استبدال التوصية.';

  @override
  String get snoozedRecommendation => 'تم تأجيل هذه التوصية حتى الغد.';

  @override
  String get noQuestsToday => 'لا توجد مهام لليوم بعد';

  @override
  String get chooseFromTemplate => 'اختر من القالب وابدأ عادتك بـ 3 نقرات.';

  @override
  String get findAQuest => 'البحث عن مهمة';

  @override
  String get swapRecommendation => 'استبدال بتوصية أخرى';

  @override
  String get snoozeUntilTomorrow => 'تأجيل حتى الغد';

  @override
  String get snoozed => 'مؤجل';

  @override
  String get undo => 'تراجع';

  @override
  String get dismissHelpBanner => 'إغلاق النصائح';

  @override
  String get openProfile => 'فتح الملف الشخصي';

  @override
  String get snoozeTemporarilyDisabled => 'التأجيل معطل مؤقتاً';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSectionGeneral => 'عام';

  @override
  String get settingsPushNotifications => 'الإشعارات الفورية';

  @override
  String get settingsPushNotificationsSubtitle => 'التذكيرات وتحديثات الشريك';

  @override
  String get settingsNotificationTime => 'وقت الإشعار';

  @override
  String get settingsSound => 'الصوت';

  @override
  String get settingsProfile => 'إعدادات الملف الشخصي';

  @override
  String get settingsSectionPrivacy => 'الخصوصية والبيانات';

  @override
  String get settingsDataSync => 'إعداد مزامنة البيانات';

  @override
  String get settingsDataSyncSubtitle => 'مزامنة البيانات عبر الأجهزة';

  @override
  String get settingsManageBlockedUsers => 'إدارة المستخدمين المحظورين';

  @override
  String get settingsExportData => 'تصدير البيانات';

  @override
  String get settingsDeleteAccount => 'حذف الحساب والبيانات';

  @override
  String get settingsSectionAbout => 'حول MinQ';

  @override
  String get settingsTermsOfService => 'شروط الخدمة';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsAppVersion => 'إصدار التطبيق';

  @override
  String get settingsSectionDeveloper => 'خيارات المطور';

  @override
  String get settingsUseDummyData => 'استخدام بيانات وهمية';

  @override
  String get settingsUseDummyDataSubtitle =>
      'استخدام بيانات وهمية بدلاً من قاعدة البيانات.';

  @override
  String get settingsSocialSharingDemo => 'تجربة المشاركة الاجتماعية';

  @override
  String get settingsSocialSharingDemoSubtitle =>
      'اختبار المشاركة الاجتماعية وميزات الاحتفال';

  @override
  String get questsTitle => 'المهام الصغيرة';

  @override
  String get questsSearchHint => 'البحث عن القوالب...';

  @override
  String get questsFabLabel => 'إنشاء مخصص';

  @override
  String get questsCategoryFeatured => 'مميز';

  @override
  String get questsCategoryMyQuests => 'مهامي';

  @override
  String get questsCategoryAll => 'الكل';

  @override
  String get questsCategoryLearning => 'التعلم';

  @override
  String get questsCategoryExercise => 'التمرين';

  @override
  String get questsCategoryTidying => 'الترتيب';

  @override
  String get questsCategoryRecent => 'الأخيرة';

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
  String get back => 'رجوع';

  @override
  String get pairMatchingTimeoutTitle => 'Matching Timed Out';

  @override
  String get pairMatchingTimeoutMessage =>
      'We couldn\'t find a buddy for you in time. Please try again or check back later.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

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
  String get enable => 'تفعيل';

  @override
  String get later => 'لاحقاً';

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
  String get pairTitle => 'الشريك';

  @override
  String get pairAnonymousPartner => 'شريك مجهول';

  @override
  String pairPairedQuest(Object questName) {
    return 'مقترن في مهمة $questName';
  }

  @override
  String get pairHighFiveAction => 'إرسال تحية';

  @override
  String get pairHighFiveSent => 'تم إرسال التحية';

  @override
  String get pairQuickMessagePrompt => 'إرسال رسالة سريعة';

  @override
  String get pairQuickMessageGreat => 'رائع!';

  @override
  String get pairQuickMessageKeepGoing => 'استمر هكذا!';

  @override
  String get pairQuickMessageFinishStrong => 'أكمل بقوة!';

  @override
  String get pairQuickMessageCompletedGoal => 'حققت الهدف!';

  @override
  String streakDayCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم متتالي',
      zero: '0 أيام متتالية',
    );
    return '$_temp0';
  }

  @override
  String get celebrationNewLongestStreak => 'تم تحديث الرقم القياسي المتتالي!';

  @override
  String celebrationStreakMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تحقيق $count يوم متتالي!',
      zero: 'لا يوجد رقم قياسي بعد. لنبدأ اليوم!',
    );
    return '$_temp0';
  }

  @override
  String get celebrationLongestSubtitle => 'تم تحديث أفضل رقم شخصي!';

  @override
  String get celebrationKeepGoingSubtitle =>
      'تسير الأمور بشكل جيد جداً. استمر هكذا.';

  @override
  String get celebrationRewardTitle => 'مكافأة';

  @override
  String get celebrationRewardName => 'تمرين تنفس لمدة دقيقة واحدة';

  @override
  String get celebrationRewardDescription => 'هدئ عقلك بالتنفس العميق';

  @override
  String get celebrationDone => 'إكمال';

  @override
  String get pairPartnerHeroTitle => 'انمُ مع شريك!';

  @override
  String get pairPartnerHeroDescription =>
      'وجود شريك مساءلة يحسن معدل الإنجاز بنسبة 95%. استمر بأمان مع الهوية المجهولة.';

  @override
  String get pairInviteTitle => 'هل لديك رمز دعوة؟';

  @override
  String get pairInviteHint => 'أدخل الرمز';

  @override
  String get pairInviteApply => 'تطبيق';

  @override
  String get pairDividerOr => 'أو';

  @override
  String get pairRandomMatchTitle => 'مطابقة عشوائية';

  @override
  String get pairAgeRangeLabel => 'الفئة العمرية';

  @override
  String get pairGoalCategoryLabel => 'فئة الهدف';

  @override
  String get pairRandomMatchNote =>
      'يتم الحفاظ على إخفاء الهوية. يتم مشاركة الفئة العمرية وفئة الهدف فقط، وجميع التفاعلات تتم داخل التطبيق.';

  @override
  String get pairAgeOption1824 => '18-24 سنة';

  @override
  String get pairAgeOption2534 => '25-34 سنة';

  @override
  String get pairAgeOption3544 => '35-44 سنة';

  @override
  String get pairAgeOption45Plus => '45 سنة فأكثر';

  @override
  String get pairGoalFitness => 'اللياقة البدنية';

  @override
  String get pairGoalLearning => 'التعلم';

  @override
  String get pairGoalWellbeing => 'الرفاهية';

  @override
  String get pairGoalProductivity => 'الإنتاجية';

  @override
  String get newVersionAvailable => 'إصدار جديد متاح';

  @override
  String newVersionMessage(Object version) {
    return 'إصدار جديد ($version) متاح.\nننصح بالتحديث للحصول على تجربة أفضل.';
  }

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get skip => 'تخطي';

  @override
  String get complete => 'إكمال';

  @override
  String get next => 'التالي';

  @override
  String get delivered => 'تم التسليم';

  @override
  String get pending => 'في الانتظار';

  @override
  String get canOpen => 'يمكن الفتح';

  @override
  String deliveryDate(int year, int month, int day) {
    return 'تاريخ التسليم: $day/$month/$year';
  }

  @override
  String get tapToOpen => 'اضغط للفتح';

  @override
  String question(int current, int total) {
    return 'السؤال $current / $total';
  }

  @override
  String get submit => 'إرسال';

  @override
  String get send => 'إرسال';

  @override
  String get pleaseEnterAnswer => 'يرجى إدخال إجابتك';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get userSatisfactionSurvey => 'استطلاع رضا المستخدمين';

  @override
  String get userSatisfactionDescription =>
      'ساعدنا في تحسين MinQ من خلال مشاركة ملاحظاتك';

  @override
  String get mostLikedFeature => 'ما هي الميزة التي تعجبك أكثر؟';

  @override
  String get questManagement => 'إدارة المهام';

  @override
  String get pairFeature => 'ميزة الشريك';

  @override
  String get statisticsGraphs => 'الإحصائيات والرسوم البيانية';

  @override
  String get notificationFeature => 'ميزة الإشعارات';

  @override
  String get other => 'أخرى';

  @override
  String get wouldRecommendMinq => 'هل تنصح الأصدقاء بـ MinQ؟';

  @override
  String get improvementSuggestions => 'أي اقتراحات للتحسين؟';

  @override
  String get serverConnectionFailed => 'فشل في الاتصال بالخادم';

  @override
  String get friendInvitation => 'دعوة صديق';

  @override
  String get inviteFriendsForBonus => 'ادع الأصدقاء واحصل على نقاط إضافية!';

  @override
  String get specialCampaign => 'حملة خاصة';

  @override
  String get inviteFriendsMessage =>
      'ادع الأصدقاء وستحصل أنت وأصدقاؤك على\nما يصل إلى 3500 نقطة!';

  @override
  String get inviteNow => 'ادع الآن';

  @override
  String get start => 'بدء';

  @override
  String get resume => 'استئناف';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get completed => 'مكتمل!';

  @override
  String get paused => 'متوقف مؤقتاً';

  @override
  String get timerCompleted => 'انتهى المؤقت!';

  @override
  String get clearFilters => 'مسح المرشحات';

  @override
  String get offlineMode => 'وضع عدم الاتصال';

  @override
  String get noInternetConnection =>
      'لا يوجد اتصال بالإنترنت.\n\nقد لا تعمل بعض الميزات بشكل صحيح.\nيرجى التحقق من الاتصال والمحاولة مرة أخرى.';

  @override
  String get offline => 'غير متصل';

  @override
  String get offlineOperationNotAvailable =>
      'هذه العملية غير متاحة في وضع عدم الاتصال';

  @override
  String get showActivity => 'إظهار النشاط';

  @override
  String get showActivitySubtitle => 'عرض نشاطك للمستخدمين الآخرين';

  @override
  String get allowInteraction => 'السماح بالتفاعل';

  @override
  String get allowInteractionSubtitle => 'تلقي التشجيع من المستخدمين الآخرين';

  @override
  String get hapticFeedback => 'ردود الفعل اللمسية';

  @override
  String get hapticFeedbackSubtitle => 'الاهتزاز أثناء الأنشطة';

  @override
  String get celebrationEffects => 'تأثيرات الاحتفال';

  @override
  String get celebrationEffectsSubtitle => 'إظهار تأثيرات الاحتفال عند الإكمال';

  @override
  String get levelDetails => 'تفاصيل المستوى';

  @override
  String levelDetailsMessage(int level, int progress) {
    return 'المستوى الحالي: $level\nالتقدم: $progress%';
  }

  @override
  String get close => 'إغلاق';

  @override
  String get editHabitScreen => 'الانتقال إلى شاشة تحرير العادة';

  @override
  String get addNewHabit => 'إضافة عادة جديدة';

  @override
  String get executeHabitToday => 'تنفيذ عادة اليوم';

  @override
  String get createMiniHabit => 'إنشاء عادة صغيرة';

  @override
  String get navigateToChallenges => 'الانتقال إلى شاشة التحديات';

  @override
  String get executePrevention => 'تنفيذ الوقاية';

  @override
  String get executeNow => 'تنفيذ الآن';

  @override
  String get showPreventionPlan => 'إظهار خطة الوقاية';

  @override
  String get navigateToHabitExecution => 'الانتقال إلى شاشة تنفيذ العادة';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get detailedAnalysis => 'تحليل مفصل';

  @override
  String get improvementSuggestion => 'اقتراح التحسين';

  @override
  String get createQuest => 'إنشاء مهمة';

  @override
  String get viewTodaysQuests => 'عرض مهام اليوم';

  @override
  String get findPair => 'البحث عن شريك';

  @override
  String get allowPermission => 'السماح بالإذن';

  @override
  String get thankYou => 'شكراً لك';

  @override
  String get voiceTest => 'اختبار الصوت';

  @override
  String get voiceTestSubtitle => 'اختبار التدريب الصوتي';

  @override
  String get weeklyAchievementHeatmap => 'خريطة الإنجازات الأسبوعية';

  @override
  String get privacySettings => 'إعدادات الخصوصية';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get test => 'اختبار';

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
