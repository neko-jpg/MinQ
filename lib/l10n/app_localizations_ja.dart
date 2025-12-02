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
  String get retry => '再試行する';

  @override
  String get cancel => 'キャンセルする';

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
  String get later => 'あとで';

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
  String get report => '報告する';

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
}
