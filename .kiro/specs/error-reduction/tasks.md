# Implementation Plan

- [ ] 1. 環境準備とベースライン確立











  - 現在のエラー数を記録
  - Gitで作業ブランチを作成
  - バックアップコミットを作成
  - _Requirements: 1.1, 9.2_

- [-] 2. Phase 1: 高頻度エラーの一括修正




- [x] 2.1 withOpacityの一括移行

  - `lib/presentation`配下のすべての`.dart`ファイルで`.withOpacity(数値)`を`.withValues(alpha: 数値)`に置換
  - 置換後に`flutter analyze`を実行して問題がないか確認
  - ビルドテストを実行
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 2.2 MinqThemeの拡張実装


  - `lib/presentation/theme/minq_theme.dart`にextensionを追加
  - `typography`, `primary`, `success`, `error`プロパティを実装
  - `spacing`関数と`xs`, `sm`, `md`, `lg`, `xl`, `xxs`, `full`プロパティを実装
  - _Requirements: 3.4, 8.1_


- [x] 2.3 Spacingクラスの定義

  - `lib/presentation/theme/spacing_system.dart`が存在するか確認
  - 存在しない場合は`Spacing`クラスを定義
  - 必要なファイルにインポートを追加
  - _Requirements: 3.4, 8.2_


- [x] 2.4 FocusThemeDataの修正

  - `lib/presentation/theme/focus_system.dart`の`FocusThemeData`参照を修正
  - 適切なクラスに置き換えまたは削除
  - _Requirements: 3.4_


- [x] 2.5 Icons.database_outlinedの修正

  - `lib/presentation/screens/diagnostic_screen.dart`の`Icons.database_outlined`を修正
  - 存在するアイコンに置き換え（例: `Icons.storage`）
  - _Requirements: 3.4_


- [x] 2.6 依存関係の問題解決

  - `lib/data/services/support_chat_service.dart`の`miinq_integrations`インポートをコメントアウト
  - 関連する機能をコメントアウトまたは削除
  - `pubspec.yaml`に不足している依存関係を追加（`riverpod`など）
  - _Requirements: 7.1, 7.2, 7.3_

- [-] 2.7 Phase 1の検証

  - `flutter analyze`を実行してエラー数を確認
  - ビルドが成功することを確認
  - Gitコミット
  - _Requirements: 1.4, 9.2_

- [ ] 3. Phase 2: 型安全性の確保
- [ ] 3.1 referral_serviceの型エラー修正
  - `lib/data/services/referral_service.dart`の`Object` → `String`変換を修正
  - `as String`または`.toString()`を使用
  - _Requirements: 3.1, 3.3_

- [ ] 3.2 AnalyticsService.logEventの修正
  - `lib/data/services/referral_service.dart`の`logEvent`呼び出しを修正
  - メソッドが存在するか確認し、存在しない場合はコメントアウト
  - _Requirements: 3.4_

- [ ] 3.3 quest_recommendation_serviceの型エラー修正
  - `lib/domain/recommendation/quest_recommendation_service.dart`の`num` → `double`変換を修正
  - `.toDouble()`を使用
  - _Requirements: 3.1, 3.3_

- [ ] 3.4 today_logs_screenの型エラー修正
  - `lib/presentation/screens/today_logs_screen.dart`の`ProofType` → `String`変換を修正
  - `ProofType`の比較を適切に修正
  - nullable値の安全な使用を確保
  - _Requirements: 3.1, 3.2, 3.3_

- [ ] 3.5 BuildContext.tokensの修正
  - `BuildContext.tokens`を使用しているファイルを特定
  - 適切なアクセス方法に修正（例: `Theme.of(context).extension<TokensExtension>()`）
  - _Requirements: 3.4, 8.1_

- [ ] 3.6 changelog_screenの未定義パラメータ修正
  - `lib/presentation/screens/changelog_screen.dart`の`children`パラメータを修正
  - 正しいパラメータ名に変更
  - _Requirements: 3.4_

- [ ] 3.7 quest_attributes_selectorのMinqTheme修正
  - `lib/presentation/widgets/quest_attributes_selector.dart`のMinqTheme使用箇所を修正
  - 適切なインポートとアクセス方法を使用
  - _Requirements: 3.4, 8.1_

- [ ] 3.8 offline_mode_indicatorのnetworkStatusProvider修正
  - `lib/presentation/widgets/offline_mode_indicator.dart`の`networkStatusProvider`を修正
  - 適切にインポートまたは定義
  - _Requirements: 3.4_

- [ ] 3.9 badge_widgetのSpacing修正
  - `lib/presentation/widgets/badge_widget.dart`の`Spacing`参照を修正
  - 適切にインポート
  - _Requirements: 3.4, 8.2_

- [ ] 3.10 Phase 2の検証
  - `flutter analyze`を実行してエラー数を確認
  - ビルドが成功することを確認
  - Gitコミット
  - _Requirements: 1.4, 9.2_

- [ ] 4. Phase 3: BuildContext使用の安全性確保
- [ ] 4.1 async gap警告の一括修正
  - `use_build_context_synchronously`警告があるすべてのファイルを特定
  - 各ファイルでasync処理後のBuildContext使用箇所に`if (!context.mounted) return;`を追加
  - _Requirements: 6.1, 6.2, 6.3_

- [ ] 4.2 Phase 3の検証
  - `flutter analyze`を実行して警告が解消されたか確認
  - ビルドが成功することを確認
  - Gitコミット
  - _Requirements: 1.4, 9.2_

- [ ] 5. Phase 4: 非推奨APIの移行
- [ ] 5.1 onPopInvokedの移行
  - `onPopInvoked`を使用しているファイルを特定
  - `onPopInvokedWithResult`に移行
  - _Requirements: 4.2_

- [ ] 5.2 RawKeyEventの移行
  - `lib/presentation/theme/focus_system.dart`の`RawKeyEvent`関連APIを新しいAPIに移行
  - `KeyEvent`を使用
  - _Requirements: 4.3_

- [ ] 5.3 Shareパッケージの移行
  - `Share.shareXFiles`を使用している箇所を特定
  - `SharePlus.instance.share()`に移行
  - _Requirements: 4.4_

- [ ] 5.4 Color APIの移行
  - `color.red`, `color.green`, `color.blue`を`.r`, `.g`, `.b`に移行
  - _Requirements: 4.1_

- [ ] 5.5 Phase 4の検証
  - `flutter analyze`を実行してinfo数を確認
  - ビルドが成功することを確認
  - Gitコミット
  - _Requirements: 1.4, 9.2_

- [ ] 6. Phase 5: 未使用コードのクリーンアップ
- [ ] 6.1 dart fixの自動適用
  - `dart fix --dry-run`で修正内容を確認
  - `dart fix --apply`で自動修正を適用
  - _Requirements: 10.1_

- [ ] 6.2 未使用変数の手動削除
  - `unused_local_variable`警告があるファイルを確認
  - 本当に未使用か確認して削除
  - _Requirements: 5.1_

- [ ] 6.3 未使用フィールドの手動削除
  - `unused_field`警告があるファイルを確認
  - 本当に未使用か確認して削除
  - _Requirements: 5.2_

- [ ] 6.4 未使用メソッドの手動削除
  - `unused_element`警告があるファイルを確認
  - 本当に未使用か確認して削除または`@visibleForTesting`を追加
  - _Requirements: 5.3_

- [ ] 6.5 デッドコードの削除
  - `dead_code`警告があるファイルを確認
  - デッドコードを削除
  - _Requirements: 5.1_

- [ ] 6.6 Phase 5の検証
  - `flutter analyze`を実行して警告数を確認
  - ビルドが成功することを確認
  - Gitコミット
  - _Requirements: 1.4, 9.2_

- [ ] 7. Phase 6: テストの修正
- [ ] 7.1 testパッケージの依存関係確認
  - `pubspec.yaml`の`dev_dependencies`に`test`があるか確認
  - 不足している場合は追加
  - _Requirements: 7.1_

- [ ] 7.2 contact_link_repository_testの修正
  - `test/data/repositories/contact_link_repository_test.dart`のインポートエラーを修正
  - `package:flutter_test/flutter_test.dart`を使用
  - _Requirements: 2.1_

- [ ] 7.3 auth_repository_testのモック修正
  - `test/data/repositories/auth_repository_test.dart`のMissingStubErrorを修正
  - `MockUserCredential.user`のスタブを追加
  - _Requirements: 2.4_

- [ ] 7.4 user_repository_testの型エラー修正
  - `test/data/repositories/user_repository_test.dart`のモック型エラーを修正
  - 適切な型を使用
  - _Requirements: 2.1, 2.4_

- [ ] 7.5 モックの再生成
  - `flutter pub run build_runner build --delete-conflicting-outputs`を実行
  - モックファイルを再生成
  - _Requirements: 2.4_

- [ ] 7.6 Phase 6の検証
  - `flutter test`を実行してすべてのテストがパスするか確認
  - テストカバレッジが低下していないか確認
  - Gitコミット
  - _Requirements: 2.1, 2.2, 2.3, 9.2_

- [ ] 8. 最終検証とドキュメント更新
- [ ] 8.1 最終ビルドテスト
  - `flutter clean`を実行
  - `flutter pub get`を実行
  - `flutter build apk --debug`を実行して成功を確認
  - `flutter build web --debug`を実行して成功を確認
  - _Requirements: 1.4_

- [ ] 8.2 最終analyzeテスト
  - `flutter analyze`を実行
  - エラー、警告、infoの数を記録
  - 目標達成を確認
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 8.3 最終テスト実行
  - `flutter test`を実行
  - すべてのテストがパスすることを確認
  - _Requirements: 2.1, 2.2_

- [ ] 8.4 修正サマリーの作成
  - 修正前後のエラー数を記録
  - 主要な修正内容をリストアップ
  - 今後の注意点をドキュメント化
  - _Requirements: 9.4_

- [ ] 8.5 ERROR_REDUCTION_PLAN.mdの更新
  - 実際の修正内容を反映
  - 達成した目標を記録
  - 残課題があれば記録
  - _Requirements: 9.4_

- [ ] 8.6 最終コミットとマージ
  - すべての変更をコミット
  - メインブランチにマージ
  - タグを作成（例: `error-reduction-complete`）
  - _Requirements: 9.2_
