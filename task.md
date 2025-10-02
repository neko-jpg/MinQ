P0 (必須・不具合/統一) - マストハブ
[x] 色統一: カード背景を tokens.surface に統一（Darkは RGB(61,68,77)）。直指定色を撤去。

[x] Onboarding: ColorScheme 直参照 → すべて context.tokens に置換。_FeatureCard は CardTheme 準拠。

[x] Riverpodエラー対策: ref.listen → ref.listenManual に変更し ProviderSubscription を dispose() で close()。

[x] BOTTOM OVERFLOWED対策: SafeArea、SingleChildScrollView+viewInsets余白、ConstrainedBox(minHeight)、Expanded/Flexible 徹底。

[x] 認証フロー完成: Google/Apple/Email、失敗/再試行、初回プロフィール初期化。

[x] MiniQuest CRUD: 作成/編集/削除/並び替え、通知スケジュール。

[x] 進捗ログ: 記録/取り消し、日跨ぎ・タイムゾーン処理。

[x] Stats確定: 連続日数・7日達成率・当日完了数、0件時の行動喚起カード。

[x] ペア機能の安全: 匿名、通報/ブロック、NGワード基本フィルタ。

[x] プロフィール実データ化: Firestore連携、ダミー撤去ボタンを押したときにしっかりとすべての機能がつかえるようにする。

[x] 同期バナー: 表示条件整理、表示後 acknowledgeBanner()。

[x] エラーUX標準化: SnackBar/Dialog/EmptyState のガイド適用。

[x]戻るボタンや、×ボタンが機能するか確認さらにAndoroidアプリでの戻るボタンでも確認、Appleユーザように戻るボタンも配置かつ機能しているかも確認

[x]'package:flutter_riverpod/src/consumer.dart': Failed assertion: line 600 pos 7: 'debugDoingBuild':
ref.listen can only be used within the build method of a ConsumerWidget
See also: https://docs.flutter.dev/testing/errors　このエラーを直してhome画面と進捗画面が表示されるようにし色統一がされていることを確認する。

P1 (体験磨き) - UX改善
[x] ボタン規格統一: minq_buttons.dart にVariant集約（Elevated/Outlined/Text）。

[x] カード様式統一: 枠線/角丸トークン統一。

[x] ローディング: リスト=スケルトン、ボタン=スピナー、グラフ=フェード。

[x] i18n: ハードコード文言抽出→.arb、ja完了/en雛形。

[x] Onboarding短縮: 最大3枚、通知許可→初回クエスト作成へ直行。

[x] 共有カード調整: 余白/フォント/エクスポート解像度統一。

[x] DeepLink/Push: 通知タップで対象画面へ遷移。

[x] 設定: バックアップ/JSONエクスポート、複数リマインド時刻。

[x] 空状態コピー統一: 次アクション提示。

[x] アクセシビリティ: Semantics、48dpタップ、TextScale 1.3対応。

[x] 画像最適化: cacheWidth/Height 指定の徹底。

[x] ナビ/コピー統一: 肯定=右、否定=左、CTA表現統一。

P2 (成長/収益/運用/技術負債) - 拡張性と安定性
P2-1. アナリティクスと収益
[x] Analytics設計: Auth→Onboard→QuestCreate→Complete→Share のイベント定義。

[x] Remote Config/A-B: コピー/CTA配置の実験基盤。

[x] モネタイズ方針: AdMobの配置ポリシー（実行導線では非表示）、サブスク権限の下準備。

[x] 招待/リファラ: 招待リンク、導線計測。

P2-2. デザインシステムとアクセシビリティ
[x] 祝アニメーション: ペア成立時の軽量アニメ。

[x] 高度統計/CSV出力: 期間比較、エクスポート。

[x] QAチェック: 端末サイズ/ダーク・ライト/オフライン動作の回帰テスト。

[x] テーマトークン監査: Spacing/Radius/Elevation/Border を定義・未使用色削除。

[x] タイポグラフィ階層定義:（H1–H6、Body、Caption、Mono）。

[x] ベースライングリッド適用:（4/8px）とマージン統一。

[x] コントラスト検証:（WCAG AA/AAA）と不適合箇所修正。

[x] Magic Number撤去:→全てトークン化。

[x] EdgeInsets直書き撤去:→Spacingトークンへ置換。

[x] アセットアイコン統一:（アイコンセット固定・不要削除・ツリーシェイク）。

[x] Reduce Motion対応:（OS設定でアニメ無効）。

[x] ハプティクス規格:（成功/警告/軽タップの統一）。

[x] フォーカスリング/アクセント色: のキーボード操作対応。

P2-3. UIコンポーネントとエラー処理
[x] SnackBarグローバルマネージャ導入:（重複排他）。

[x] ダイアログ/ボトムシートの標準コンポーネント化。

[x] 空状態イラスト/アイコンのスタイル統一。

[x] フォームValidationメッセージ統一:（行内/下部どちらかに統一）。

[x] IMEオーバーラップ検証:（長文入力・日本語変換中）。

[x] TextOverflowポリシー統一:（ellipsis/softWrap）。

[x] 画像プレースホルダ/失敗時のFallback実装。

[x] Hero/ImplicitアニメのEasing/Duration規格化。

[x] タブ/BottomNavのバッジ規格:（数値/点表示）。

[x] スクロール到達インジケータ:（EdgeGlow/Scrollbar統一）。

P2-4. アーキテクチャとテスト
[x] ProviderObserver導入:（Riverpod遷移ログ）。

[x] AsyncValue.guard の標準化:（例外→UI表現変換）。

[x] Repositoryインターフェース化＋Fake実装。

[x] Now/Clock Provider導入:（時刻依存のテスト容易化）。

[x] AutoDispose/keepAlive の方針整理。

[x] 依存循環検知:（import_lint設定）。

[x] Navigatorガード:（未ログイン時の保護）。

[x] flutter_lints強化＋analyzer拡張:（prefer_const/avoid_print等）。

[x] import順序/未使用警告ゼロ化:（lint-staged）。

[x] pre-commitフック:（format/lint/test）。

[x] Dart-defineで環境切替:（dev/stg/prod）。

[x] Flavor別Firebaseプロジェクト分離。

[x] Logger導入:（JSON構造ログ）。

[x] Crashlytics導入:（非致命ログ＋キー/パンくず）。

[x] Performance Monitoring:（起動/描画/HTTPトレース）。

[x] Sentryオプション:（リリースビルドのみ）。

[x] Renovate/Dependabot設定:（依存更新）。

[x] GitHub Actions: Lint/Test/Build/Artifacts。

[x] CIでgoldenテスト差分チェック。

[x] Fastlane:（署名/ビルド番号/配布自動化）。

[x] コードカバレッジ収集:（閾値設定）。

[x] Conventional Commits:＋自動CHANGELOG生成。

[x] CODEOWNERS/レビュー規約。

[x] ユニットテスト:（Notifier/Repo）。

[x] ウィジェットテスト:（主要画面の状態分岐）。

[x] ゴールデンテスト:（デバイス3種・ライト/ダーク）。

[x] integration_test:（認証→作成→達成→共有フロー）。

[x] パフォーマンステスト:（初回描画/フレームドロップ）。

[x] 回帰テストシナリオ表作成:（手動QA）。

P2-5. Firebase/インフラストラクチャ
[x] Firestoreルールv2整理:（最小権限・ロール分離）。

[x] ルールユニットテスト:（エミュレータ）。

[x] インデックス/複合インデックス定義。

[x] TTL/ソフトデリート方針。

[x] 一意制約:（Cloud Functionsで強制）。

[x] オフライン永続化/キャッシュ上限設定。

[x] 競合解決ポリシー:（last-write-win/merge）。

[x] リトライ/バックオフ:（ネット不安定時）。

[x] 書込レート制御:（料金最適化）。

[x] データモデル版管理/移行スクリプト。

[x] BigQueryエクスポート有効化。

P2-6. 通知とディープリンク
[x] 通知チャンネル定義:（Android：重要/通常/消音）。

[x] 通知アクション:（完了/スヌーズ）。

[x] まとめ通知:（デイリーサマリ）。

[x] iOS provisional許可対応:（静かに配信）。

[x] DeepLinkパラメタ検証/サニタイズ。

[x] Android App Links/ iOS Universal Links整備。

[x] Webフォールバックページ:（DeepLink失敗時）。

P2-7. App Storeとプラットフォーム連携
[x] In-App Review導線。

[x] In-App Update:（Android柔軟更新）。

[x] Widget対応:（iOS/Androidホームウィジェット）。

[x] Quick Actions / App Shortcuts。

[x] 共有シートエクスポート:（画像/テキスト）。

[x] アバターアップロード:（Crop/圧縮）。

[x] 画像ストレージリサイズ:（Functionsで生成）。

[x] CSV/JSONエクスポート/インポート。

[x] カレンダー連携:（ICS出力）。

[x] バックアップ/リストア:（Drive/Files）。

P2-8. ペア機能の高度化とモデレーション
[x] モデレーション方針:（ペア機能：通報→審査→措置）。

[x] NGワード辞書更新フロー。

[x] レート制限/スパム対策:（Cloud Functions）。

[x] ブロック/ミュート実装拡張:（期間/解除）。

[x] マッチング設定:（時間帯/言語/目的）。

[x] 再マッチ回避/クールダウン。

P2-9. ユーザ体験の磨き込み
[x] Onboarding計測:（ステップ別離脱）。

[x] コーチマーク/チュートリアル。

[x] ライフログのテンプレ/おすすめ導線。

[x] 習慣の一時停止/スキップ/凍結日:（Streak保護）。

[x] スヌーズ/Do Not Disturb時間帯。

[x] スマート提案:（過去実績→通知時刻提案）。

[x] バッジ/実績/週次チャレンジ。

[x] ペアスコアボード/軽量ランキング。

[x] 多言語整形:（日時/数値/通貨/単位）。

[x] Bidi対応:（RTL検証）。

[x] 日本語固有表記:（全角/半角/長音）方針。

[x] 曜日/祝日表示:（ロケール準拠）。

P2-10. 端末対応とパフォーマンス
[x] 端末マトリクスQA:（小/中/大/折りたたみ/タブ）。

[x] セーフエリア/ノッチ/ホームインジケータ検証。

[x] 画面回転/ランドスケープ制御。

[x] 低速端末/低メモリ耐性。

[x] 起動時間短縮:（遅延初期化/画像プリフェッチ）。

[x] ABI別分割/圧縮:（Android App Bundle最適化）。

[x] 未使用アセット/フォント削除。

[x] ベクター化:（PNG→SVG/PNGW）。

[x] 背景Isolateで重処理:（集計/書き出し）。

P2-11. 法務とリリース運用
[x] 法務: 利用規約/プライバシーポリシー整備。

[x] データセーフティフォーム:（Play Console）。

[x] アカウント削除/データ削除導線:（GDPR/個人情報保護法）。

[x] 年齢配慮/ペア機能の年少者保護。

[x] 追跡拒否トグル:（Do Not Track）。

[x] メタデータ多言語化/ASOキーワード。

[x] 内部テスト/クローズドテスト/オープンβ運用。

[x] プレローンチレポート対応:（クラッシュ/互換）。

[x] バグ報告機能:（スクショ添付/ログ同梱）。

[x] ストア素材作成:（スクショ/動画/アイコン/説明文）。

[x] インアプリFAQ/ヘルプ/問い合わせ。

[x] 稼働監視ダッシュボード:（障害/指標）。

[x] Slack/メール通知:（重大イベント）。

[x] リモートフラグのキルスイッチ。

[x] 実験テンプレ:（対象/指標/期間）。

[x] 料金/権限のフェンス:（無料/有料機能切替）。

[x] リファラ計測:（招待リンク/詐欺対策）。

[x] 変更履歴/お知らせセンター。

[x] テックドキュメント整備:（ARCHITECTURE.md/RUNBOOK.md）。

[x] デザインシステムガイド:（色/タイポ/モーション）。

[x] TODO/DEBT棚卸しと優先度付け。

[x] 依存パッケージのライセンス表記。

P2-12. その他高度な機能・改善
[x] FCMトピック設計:（ニュース/週次まとめ）。

[x] バックグラウンド同期の窓口:（WorkManager等）。

[x] タイムゾーン異常/うるう年/月末処理の境界テスト。

[x] DND中の通知延期ロジック。

[x] 連続通知抑制:（デバウンス/バッチ）。

[x] 例外セーフガード:（エラーバウンダリ相当の画面）。

[x] ネットワーク断/機内モード時のデグレード表示。

[x] CDN/HTTPキャッシュ戦略:（外部静的アセット用）。

[x] 入力サニタイズ:（DeepLink/外部入力全般）。

[x] Play Integrity APIの検討:（改ざん対策）。

[x] アプリ内時刻表現の一貫性:（相対/絶対の規則）。

[x] アプリ起動スプラッシュ画面の統一:（ライト/ダーク/ロゴ解像度）。

[x] ダークモード切替を即時反映:（再起動不要）。

[x] アクセントカラーをユーザ設定で切替可能に:（青/緑/紫系など）。

[x] フォントサイズ変更UI:（ユーザが調整可能）。

[x] プロフィールのニックネーム重複検証。

[x] ペア機能での「おすすめユーザ」表示:（条件：アクティブ度・時間帯）。

[x] タスク/習慣のタグ機能:（分類・検索用）。

[x] クエストのアーカイブ機能:（削除せず非表示）。

[x] クエストのリマインド複数設定:（朝・昼・夜）。

[x] クエストの優先度ラベル:（高/中/低）。

[x] 達成画面のアニメーション追加:（祝福演出）。

[x] Statsでの週単位・月単位切替。

[x] Statsのグラフにツールチップ追加:（正確な数値表示）。

[x] データエクスポートをPDF形式でも提供。

[x] サーバーメンテナンス時のメッセージ画面。

[x] オフラインモード時のUI表示改善:（読み取り専用モード）。

[x] 通知タップで直接「今日のクエスト一覧」へ遷移。

[x] 機種変更時のデータ移行ガイド:（Google Driveバックアップ）。

[x] ストリーク途切れ時のリカバリー機能:（課金や広告視聴で保護）。

[x] ペアの進捗比較画面:（自分と相手のグラフ並列）。

[x] ペア解消機能:（トラブル時に一方解除可）。

[x] ペアリマインド通知:（相手が未達成ならプッシュ）。

[x] サーバーレスポンス遅延時のリトライUI。

[x] バージョンアップ時の変更点案内:（What’s New画面）。

[x] バージョン互換チェック:（古いクライアントを警告）。

[x] ストア評価リクエスト導線:（一定利用後に表示）。

[x] SNSシェア時のOGP画像生成:（クエスト達成バナー）。

[x] ユーザ削除時の二重確認:（誤操作防止）。

[x] 通知の曜日/祝日カスタム:（休みの日は通知しない）。

[x] 習慣テンプレート集:（例：朝ラン・読書・日記）。

[ ] 習慣提案AI:（過去の記録から推奨）。

[x] 習慣に「難易度」属性追加:（簡単/普通/難しい）。

[x] 習慣に「推定時間」属性追加:（5分/15分/30分）。

[x] 習慣の「場所」属性:（ジム/自宅/図書館）。

[ ] 習慣の「連絡先」リンク:（例：ペアのLINE）。

[ ] 音声入力でクエスト作成。

[x] 習慣実行時のタイマー機能。

[ ] 習慣実行中のBGM:（集中モード）。

[ ] ペア同士の軽いチャット:（スタンプ/定型文のみ）。

[x] 不正利用検出:（短時間で大量クエスト完了→警告）。

[ ] 利用時間制限:（親子モード）。

[ ] デバイス通知音のカスタム。

[x] アプリ内での「よくある質問」ヘルプセンター。

[x] フィードバック投稿フォーム:（Googleフォーム連携）。

[x] アプリ内アンケート:（UI改善用）。

[x] バッジシステム:（7日連続達成・30日達成）。

[x] アチーブメント一覧画面。

[x] プロフィールに「獲得バッジ数」表示。

[x] イベントモード:（期間限定クエスト）。

[ ] チーム習慣:（ペア以上＝複数人での達成競争）。

[x] イベントランキング:（習慣数で競う）。

[ ] ISO 27001/SOC 2準拠のセキュリティポリシー策定。

[ ] 差分バックアップ+暗号化ZIPのユーザ直接DL機能。

[ ] マルチリージョンFirestore→Datastoreレプリケーション設計。

[ ] CDNヘッダ最適化:（Cache-Control/Etag/ Brotli自動）。

[ ] アプリ起動時プリロード戦略:（Warm-up isolate／DWU削減）。

[ ] Chaos Testing:（ネット断・メモリ圧迫・時刻改変）。

[ ] Fuzz Testing:（フォーム入力の異常系自動生成）。

[x] ライブラリアップデート自動PR:（Renovate Bot）。

[x] 開発用データシードスクリプト:（faker付き）。

[ ] Monorepo化＋Melos/Very Good CLI導入。

[ ] Dart API docs → pub.dev公開自動生成。

[x] タグ/検索バー搭載:（習慣名・タグ・説明全文検索）。

[ ] AIレコメンド:（達成率・時間帯で次の習慣提案）。

[ ] パーソナライズPush:（RFM分析で送信頻度調整）。

[ ] ACR Cloud連携でBGM自動タグ付け:（集中曲提案）。

[x] スクリーンリーダー最適化:（ロール/ヒント/読み順確認）。

[ ] カラーコントラスト自動検証CI:（WCAG 2.2 AA）。

[ ] 日本語漢字変換中のIME候補被りテスト。

[ ] 祝日API同期:（各国ローカル通知自動スキップ）。

[x] DST/うるう秒/閏年パスケース単体テスト。

[ ] オフライン完全モード:（IndexedDB＋PWA用）。

[ ] PWAインストールバナー＆Add to Home Screen対応。

[ ] Mac/Winネイティブビルド:（Flutter Desktop、menu bar timer）。

[ ] Wear OS/Apple Watchクイックチェックアプリ。

[ ] HealthKit/Google Fit連携:（歩数→習慣自動達成）。

[ ] GPT-4o埋め込みチャットサポートBot:（問い合わせ自動回答）。

[ ] アプリ内コミュニティ掲示板:（モデレーション付き）。

[ ] カスタムWebhook IFTTT/Zapier連携。

[ ] Carbon footprint計測:（CI/CD & ランタイム）。

[x] グリーンダークモード:（OLED省電力配色）。

[ ] 動画チュートリアル生成パイプライン:（Lottie＋TTS）。

[ ] Live Activity / Android Live Widget:（進捗リアルタイム表示）。

[ ] Stripe Billing Portal統合:（サブスク管理セルフサービス）。

[ ] アプリ内投げ銭:（Sponsor block ads 解除）。

[x] Referral Code deep link:（友達招待→報酬）。

[x] ユーザートークン制Rate Limiter:（機能乱用対策）。

[ ] 地理的位置連動通知:（ジオフェンス：ジム到着→習慣リマインド）。

[ ] 画像生成AIでSNS共有バナー自動作成。

[x] 高齢者向けアクセシビリティ設定:（特大UI・音声読み上げ速度）。

[x] プログレッシブオンボーディング:（機能解放レベル制）。

[x] Feature flag kill-switch即時反映:（Remote Configのみで停止）。

[ ] KPIダッシュボード自動Snapshot→Slack送信。

[ ] バックエンドコストアラート:（Firestore/Functions超過時）。

[ ] ユーザー行動ヒートマップ:（RepaintBoundary＋解析）。

[x] 自己診断モード:（設定→テスト通知/ストレージ/ネット）。

[ ] 脆弱性SCA:（Software Composition Analysis）定期実行。

[x] 法域別プライバシーコンプライアンス:（COPPA/CCPA/OHCA）。

[x] パブリックAPI公開:（Personal Access Token＋Rate Limit）。

[x] OSS公開計画:（ライセンス選定、CONTRIBUTING.md）。
