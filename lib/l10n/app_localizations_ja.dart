// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get goodMorning => 'おはようございます！';

  @override
  String get todaysQuests => '今日のQuest';

  @override
  String get todays3Recommendations => '今日のおすすめ3件';

  @override
  String get swapOrSnooze => 'スワップまたはスヌーズはワンタップで変更できます。';

  @override
  String get replacedRecommendation => 'おすすめを入れ替えました。';

  @override
  String get snoozedRecommendation => 'このおすすめを明日までスヌーズしました。';

  @override
  String get noQuestsToday => '今日のQuestはまだありません';

  @override
  String get chooseFromTemplate => 'テンプレートから選んで、3タップ習慣をはじめましょう。';

  @override
  String get findAQuest => 'クエストを探す';

  @override
  String get swapRecommendation => '別のおすすめに入れ替える';

  @override
  String get snoozeUntilTomorrow => '明日までスヌーズする';

  @override
  String get snoozed => 'スヌーズ済み';

  @override
  String get undo => '元に戻す';

  @override
  String get dismissHelpBanner => 'ヒントを閉じる';

  @override
  String get openProfile => 'プロフィールを開く';

  @override
  String get snoozeTemporarilyDisabled => 'スヌーズは一時的に無効です';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionGeneral => '一般設定';

  @override
  String get settingsPushNotifications => 'プッシュ通知';

  @override
  String get settingsPushNotificationsSubtitle => 'リマインダーとパートナーの更新';

  @override
  String get settingsNotificationTime => '通知時間';

  @override
  String get settingsSound => 'サウンド';

  @override
  String get settingsProfile => 'プロフィール設定';

  @override
  String get settingsSectionPrivacy => 'プライバシーとデータ';

  @override
  String get settingsDataSync => 'データ同期を設定する';

  @override
  String get settingsDataSyncSubtitle => 'デバイス間でデータを同期する';

  @override
  String get settingsManageBlockedUsers => 'ブロック中のユーザーを管理する';

  @override
  String get settingsExportData => 'データをエクスポートする';

  @override
  String get settingsDeleteAccount => 'アカウントとデータを削除する';

  @override
  String get settingsSectionAbout => 'MinQについて';

  @override
  String get settingsTermsOfService => '利用規約';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsAppVersion => 'アプリのバージョン';

  @override
  String get settingsSectionDeveloper => '開発者向けオプション';

  @override
  String get settingsUseDummyData => 'ダミーデータを使用する';

  @override
  String get settingsUseDummyDataSubtitle => 'データベースの代わりにダミーデータを使用します。';

  @override
  String get settingsSocialSharingDemo => 'ソーシャル共有デモを試す';

  @override
  String get settingsSocialSharingDemoSubtitle => 'ソーシャル共有と祝福機能をテストします';

  @override
  String get questsTitle => 'ミニクエスト';

  @override
  String get questsSearchHint => 'テンプレートを検索...';

  @override
  String get questsFabLabel => 'カスタムを作成する';

  @override
  String get questsCategoryFeatured => 'おすすめ';

  @override
  String get questsCategoryMyQuests => '自分のクエスト';

  @override
  String get questsCategoryAll => 'すべて';

  @override
  String get questsCategoryLearning => '学習';

  @override
  String get questsCategoryExercise => 'エクササイズ';

  @override
  String get questsCategoryTidying => '片付け';

  @override
  String get questsCategoryRecent => '最近';

  @override
  String get authErrorOperationNotAllowed => '匿名サインインはこのプロジェクトでは有効になっていません。';

  @override
  String get authErrorWeakPassword => 'パスワードが弱すぎます。より強力なパスワードを設定してください。';

  @override
  String get authErrorEmailAlreadyInUse => 'このメールアドレスは既に使用されています。';

  @override
  String get authErrorInvalidEmail => 'メールアドレスの形式が正しくありません。';

  @override
  String get authErrorUserDisabled => 'このユーザーは無効化されています。';

  @override
  String get authErrorUserNotFound => 'このメールアドレスのユーザーが見つかりませんでした。';

  @override
  String get authErrorWrongPassword => 'パスワードが間違っています。';

  @override
  String get authErrorAccountExistsWithDifferentCredential =>
      '同じメールアドレスで、異なるログイン情報の既存アカウントがあります。';

  @override
  String get authErrorInvalidCredential => '認証情報が無効か、期限切れです。';

  @override
  String get authErrorUnknown => '不明なエラーが発生しました。';

  @override
  String get back => '戻る';

  @override
  String get pairMatchingTimeoutTitle => 'マッチングがタイムアウトしました';

  @override
  String get pairMatchingTimeoutMessage =>
      '時間内にバディが見つかりませんでした。もう一度試すか、後で再試行してください。';

  @override
  String get retry => '再試行';

  @override
  String get cancel => 'キャンセル';

  @override
  String get messageSentFailed => 'メッセージの送信に失敗しました';

  @override
  String get chatInputHint => 'メッセージを入力...';

  @override
  String get notificationPermissionDialogTitle => '通知を有効にしますか？';

  @override
  String get notificationPermissionDialogMessage =>
      'クエストのリマインダーやバディからの更新情報を受け取れます。この設定は後からいつでも変更できます。';

  @override
  String get notificationPermissionDialogBenefitsHeading => '通知を有効にするとできること';

  @override
  String get notificationPermissionDialogBenefitReminders =>
      '設定した時間にクエストのリマインダーが届きます。';

  @override
  String get notificationPermissionDialogBenefitPair => 'ペアからの応援や連絡をすぐに受け取れます。';

  @override
  String get notificationPermissionDialogBenefitGoal => '目標達成を逃さず記録できます。';

  @override
  String get notificationPermissionDialogFooter => '通知は設定からいつでも変更できます。';

  @override
  String get enable => '有効にする';

  @override
  String get later => '後で';

  @override
  String get shareFailed => '進捗のシェアに失敗しました。もう一度お試しください。';

  @override
  String get accountDeletionTitle => 'アカウントの削除';

  @override
  String get accountDeletionWarning =>
      'これは元に戻せない操作です。7日間の猶予期間の後、あなたのクエスト、進捗、ペア情報を含むすべてのデータが完全に消去されます。この処理は、7日以内に再度ログインすることでキャンセルできます。';

  @override
  String get accountDeletionConfirmationCheckbox =>
      'この操作の結果を理解し、アカウントを完全に削除することを希望します。';

  @override
  String get accountDeletionConfirmDialogTitle => '最終確認';

  @override
  String get accountDeletionConfirmDialogDescription =>
      '\nアカウントを削除すると以下が行われます:\n• クエストと進捗ログの完全削除\n• ペアとのメッセージ履歴の削除\n• 復元には7日以内のログインが必要\n\n本当に削除してもよろしいですか？';

  @override
  String get accountDeletionConfirmDialogPrompt => '確認のため、次の文言を入力してください';

  @override
  String get accountDeletionConfirmPhrase => '削除します';

  @override
  String get accountDeletionConfirmButton => '完全に削除する';

  @override
  String get deleteMyAccountButton => 'アカウントを削除する';

  @override
  String get blockUser => 'ユーザーをブロックする';

  @override
  String get reportUser => 'ユーザーを報告する';

  @override
  String get userBlocked => 'ユーザーをブロックしました。';

  @override
  String get reportSubmitted => '報告が送信されました。';

  @override
  String get block => 'ブロックする';

  @override
  String get report => '報告';

  @override
  String get areYouSure => 'よろしいですか？';

  @override
  String get blockConfirmation =>
      'このユーザーをブロックすると、相手からの連絡を受け取れなくなります。この操作は設定から元に戻せます。';

  @override
  String get reportConfirmation => '報告の理由を簡単にご記入ください。適切な対応の参考にさせていただきます。';

  @override
  String get reason => '理由';

  @override
  String get notSignedIn => 'サインインしていません。';

  @override
  String get errorGeneric => 'エラーが発生しました。時間をおいて再度お試しください。';

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
  String get newVersionAvailable => '新しいバージョンがあります';

  @override
  String newVersionMessage(Object version) {
    return '新しいバージョン（$version）が利用可能です。\nより快適にご利用いただくため、アップデートをおすすめします。';
  }

  @override
  String get viewDetails => '詳細を見る';

  @override
  String get skip => 'スキップ';

  @override
  String get complete => '完了';

  @override
  String get next => '次へ';

  @override
  String get delivered => '配信済み';

  @override
  String get pending => '配信待ち';

  @override
  String get canOpen => '開封可能';

  @override
  String deliveryDate(int year, int month, int day) {
    return '配信日: $year年$month月$day日';
  }

  @override
  String get tapToOpen => 'タップして開封';

  @override
  String question(int current, int total) {
    return '質問 $current / $total';
  }

  @override
  String get submit => '送信';

  @override
  String get send => '送信';

  @override
  String get pleaseEnterAnswer => '回答を入力してください';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get userSatisfactionSurvey => 'ユーザー満足度調査';

  @override
  String get userSatisfactionDescription => 'MinQをより良くするため、ご意見をお聞かせください';

  @override
  String get mostLikedFeature => '最も気に入っている機能は何ですか？';

  @override
  String get questManagement => 'クエスト管理';

  @override
  String get pairFeature => 'ペア機能';

  @override
  String get statisticsGraphs => '統計・グラフ';

  @override
  String get notificationFeature => '通知機能';

  @override
  String get other => 'その他';

  @override
  String get wouldRecommendMinq => '友人にMinQを勧めますか？';

  @override
  String get improvementSuggestions => '改善してほしい点があれば教えてください';

  @override
  String get serverConnectionFailed => 'サーバーへの接続に失敗しました';

  @override
  String get friendInvitation => '友達招待';

  @override
  String get inviteFriendsForBonus => '友達を招待してボーナスポイントをゲット！';

  @override
  String get specialCampaign => '特別キャンペーン';

  @override
  String get inviteFriendsMessage => '友達を招待すると、あなたも友達も\n最大3500ポイントがもらえます！';

  @override
  String get inviteNow => '今すぐ招待';

  @override
  String get start => '開始';

  @override
  String get resume => '再開';

  @override
  String get reset => 'リセット';

  @override
  String get pause => '一時停止';

  @override
  String get completed => '完了！';

  @override
  String get paused => '一時停止中';

  @override
  String get timerCompleted => 'タイマー完了！';

  @override
  String get clearFilters => 'フィルターをクリア';

  @override
  String get offlineMode => 'オフラインモード';

  @override
  String get noInternetConnection =>
      'インターネット接続がありません。\n\n一部の機能が正常に動作しない可能性があります。\n接続を確認して再度お試しください。';

  @override
  String get offline => 'オフライン';

  @override
  String get offlineOperationNotAvailable => 'オフラインのため、この操作は実行できません';

  @override
  String get showActivity => 'アクティビティを表示';

  @override
  String get showActivitySubtitle => '他のユーザーにあなたの活動を表示します';

  @override
  String get allowInteraction => '交流を許可';

  @override
  String get allowInteractionSubtitle => '他のユーザーからの励ましを受け取ります';

  @override
  String get hapticFeedback => '触覚フィードバック';

  @override
  String get hapticFeedbackSubtitle => 'アクティビティ時に振動でお知らせします';

  @override
  String get celebrationEffects => '祝福エフェクト';

  @override
  String get celebrationEffectsSubtitle => '完了時に祝福エフェクトを表示します';

  @override
  String get levelDetails => 'レベル詳細';

  @override
  String levelDetailsMessage(int level, int progress) {
    return '現在レベル: $level\n進捗: $progress%';
  }

  @override
  String get close => '閉じる';

  @override
  String get editHabitScreen => '習慣編集画面に移動します';

  @override
  String get addNewHabit => '新しい習慣を追加します';

  @override
  String get executeHabitToday => '今日の習慣を実行しましょう';

  @override
  String get createMiniHabit => 'ミニ習慣を作成します';

  @override
  String get navigateToChallenges => 'チャレンジ画面に移動します';

  @override
  String get executePrevention => '対策を実行';

  @override
  String get executeNow => '今すぐ実行';

  @override
  String get showPreventionPlan => '対策プランを表示します';

  @override
  String get navigateToHabitExecution => '習慣実行画面に移動します';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get detailedAnalysis => '詳細分析';

  @override
  String get improvementSuggestion => '改善提案';

  @override
  String get createQuest => 'クエストを作成';

  @override
  String get viewTodaysQuests => '今日のクエストを見る';

  @override
  String get findPair => 'ペアを探す';

  @override
  String get allowPermission => '権限を許可';

  @override
  String get thankYou => 'ありがとう';

  @override
  String get voiceTest => '音声テスト';

  @override
  String get voiceTestSubtitle => '音声コーチングをテストします';

  @override
  String get weeklyAchievementHeatmap => '週間達成ヒートマップ';

  @override
  String get privacySettings => 'プライバシー設定';

  @override
  String get notificationSettings => '通知設定';

  @override
  String get test => 'テスト';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityLow => '低';

  @override
  String createdOn(int year, int month, int day) {
    return '$year年$month月$day日作成';
  }

  @override
  String daysUntil(int days) {
    return '$days日後';
  }

  @override
  String get required => ' *必須';

  @override
  String get usabilityRating => 'MinQの使いやすさを5段階で評価してください';

  @override
  String get friendInvitationTitle => '友達招待';

  @override
  String invitedFriends(int count, int rate) {
    return '$count人招待済み・成功率$rate%';
  }

  @override
  String get inviteFriendsBonus => '友達を招待してボーナスポイントをゲット！';

  @override
  String get specialCampaignTitle => '特別キャンペーン';

  @override
  String get inviteFriendsPoints => '友達を招待すると、あなたも友達も\n最大3500ポイントがもらえます！';

  @override
  String get searchQuests => 'クエストを検索...';

  @override
  String get filterByTags => 'タグでフィルター';

  @override
  String get difficulty => '難易度';

  @override
  String get estimatedTime => '推定時間';

  @override
  String get location => '場所';

  @override
  String get difficultyEasy => '簡単';

  @override
  String get difficultyMedium => '普通';

  @override
  String get difficultyHard => '難しい';

  @override
  String get duration5min => '5分';

  @override
  String get duration10min => '10分';

  @override
  String get duration15min => '15分';

  @override
  String get duration30min => '30分';

  @override
  String get duration1hour => '1時間';

  @override
  String get locationHome => '自宅';

  @override
  String get locationGym => 'ジム';

  @override
  String get locationOffice => 'オフィス';

  @override
  String get locationOutdoor => '屋外';

  @override
  String get locationLibrary => '図書館';

  @override
  String get progress => '進捗';

  @override
  String get ready => '準備完了';

  @override
  String get running => '実行中';

  @override
  String get workSession => '作業セッション';

  @override
  String get breakTime => '休憩';

  @override
  String get messageTest => 'メッセージテスト';

  @override
  String get messageTestSubtitle => 'コーチングメッセージをテストします';

  @override
  String intervalMinutes(int minutes) {
    return '$minutes分間隔';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes分';
  }

  @override
  String get getStarted => '始める';

  @override
  String get aiImprovementSuggestion => 'AI改善提案';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get newsAndChangelog => 'お知らせ・変更履歴';

  @override
  String get communityBoard => 'コミュニティ掲示板';

  @override
  String get post => '投稿する';

  @override
  String failedToLoadPosts(String error) {
    return '投稿の読み込みに失敗しました: $error';
  }

  @override
  String get deleteHabit => '習慣を削除';

  @override
  String deleteHabitConfirm(String title) {
    return '「$title」を削除しますか？この操作は取り消せません。';
  }

  @override
  String get delete => '削除';

  @override
  String get previous => '戻る';

  @override
  String get update => '更新する';

  @override
  String get discardChanges => '変更を破棄しますか？';

  @override
  String get unsavedChangesWillBeLost => '保存されていない変更は失われます。';

  @override
  String get discard => '破棄';

  @override
  String get habitName => '習慣名';

  @override
  String get targetValue => '目標値';

  @override
  String get reload => '再読み込み';

  @override
  String get loadingReminders => 'リマインダーを読み込み中…';

  @override
  String get addTime => '時間を追加';

  @override
  String get notSignedInCannotRecord => 'サインインしていないため記録できません。';

  @override
  String get photoCancelled => '写真の撮影がキャンセルされました。';

  @override
  String get bgmPlaybackFailed => 'BGMの再生に失敗しました。';

  @override
  String get bgmIdentificationUnavailable => 'BGMの識別は現在ご利用いただけません';

  @override
  String get couldNotIdentifySong => '楽曲を特定できませんでした';

  @override
  String get bgmIdentificationFailed => 'BGMの識別に失敗しました';

  @override
  String get stop => '停止';

  @override
  String get play => '再生';

  @override
  String get confirmPhoto => '写真を確認してください';

  @override
  String get retakePhoto => '再撮影';

  @override
  String get useThisPhoto => 'この写真を使用';

  @override
  String get showOfflineQueue => 'オフラインキューを表示';

  @override
  String get openSettings => '設定を開く';

  @override
  String get selfReportInstead => '代わりに自己申告する';

  @override
  String get save => '保存する';

  @override
  String get viewQuests => 'クエストを見る';

  @override
  String get startNow => '今すぐ始める';

  @override
  String get csvFormat => 'CSV形式';

  @override
  String get imageFormat => '画像形式';

  @override
  String get exportFeatureUnavailable => 'エクスポート機能は現在利用できません';

  @override
  String get statsDataExported => '統計データをエクスポートしました';

  @override
  String get exportFailed => 'エクスポートに失敗しました';

  @override
  String get imageExportInPreparation => '画像エクスポート機能は準備中です';

  @override
  String get backToQuestList => 'クエスト一覧に戻る';

  @override
  String get questNotFound => 'クエストが見つかりません';
}
