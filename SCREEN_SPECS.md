# 画面実装仕様書 (Screen Implementation Specs)

本ドキュメントは、MinQアプリ（v3）における各画面のUI/UX要件および実装すべきロジックの仕様を定義します。開発者は本仕様書に基づき、各画面の「モダン化」と「システム連携」を行います。

---

## 1. ホーム画面 (Home Screen)

**役割**: アプリの玄関。「今日のイチオシ」を提示し、迷わず実行させる。

*   **現状 (Status)**: UI刷新完了（Mockデータ）。ロジック未接続。
*   **UI要件 (Target UI)**:
    *   **Hero Section**: 画面上部50%を使用し、最も推奨度の高いクエストをカード表示。
    *   **Queue List**: その下に、残りの推奨クエスト（3〜5件）をリスト表示。
    *   **Header**: ユーザー名、挨拶、設定アイコン（右上）。
*   **ロジック要件 (Target Logic)**:
    *   **Data Source**: `QuestRepository` から全アクティブクエストを取得。
    *   **Filtering**: `RecommendationEngine` を使用してスコアリングし、上位1件をHero、その他をListに振り分け。
    *   **Action**: カードタップで `RecordScreen` へ遷移（`questId`渡し）。

---

## 2. クエスト一覧画面 (Quests Screen)

**役割**: 新しい習慣の発見・追加、および全クエストの管理。

*   **現状 (Status)**: 古いグリッドレイアウト。タブ切り替えが煩雑。
*   **UI要件 (Target UI)**:
    *   **List View**: ホーム画面と同様の「横長カード（Pill形状）」リストに変更。グリッドは廃止。
    *   **Categories**: タブではなく、画面上部の「チップ（Chips）」でフィルタリング。
    *   **Search**: 検索バーをヘッダーと一体化させ、モダンな見た目に。
*   **ロジック要件 (Target Logic)**:
    *   **Provider**: `questListProvider` (全クエスト取得)。
    *   **Filter Logic**: チップ選択時に `category` プロパティでフィルタリング。
    *   **Search Logic**: タイトル・タグに対する部分一致検索（Debounce処理付き）。

---

## 3. 記録・実行画面 (Record Screen)

**役割**: 行動の実行と証明（写真/チェック）。

*   **現状 (Status)**: 機能は動作するが、ボタンデザイン等が旧テーマのまま。
*   **UI要件 (Target UI)**:
    *   **Buttons**: 「写真を撮る」「自己申告」ボタンを、`MinqTheme` の `CornerXLarge` (32px) を適用した大きなボタンに変更。
    *   **Focus Music**: BGM再生パネルをカード化し、整理する。
*   **ロジック要件 (Target Logic)**:
    *   **Validation**: 写真撮影後の「不適切画像（暗すぎる等）」の判定ロジック（`ImageModerationService`）の継続利用。
    *   **Completion**: 完了時に `QuestLog` を作成し、Firestoreへ送信。成功時に `CelebrationScreen` へ遷移。

---

## 4. 進捗・統計画面 (Stats Screen)

**役割**: 継続の可視化とモチベーション維持。

*   **現状 (Status)**: `ListTile` を多用したリスト形式。情報密度が高い。
*   **UI要件 (Target UI)**:
    *   **Streak Heatmap**: カレンダーヒートマップ（草）のデザインを、ドット（円）を大きくし、余白を広げる。
    *   **Cards**: 各統計指標（週間達成率など）を独立したカードにし、影（Shadow）を柔らかくする。
*   **ロジック要件 (Target Logic)**:
    *   **Aggregation**: `QuestLogRepository` から過去のログを集計し、ストリーク日数・完了率を計算。
    *   **Insight**: 「先週比 +10%」などの比較データを動的に生成。

---

## 5. ペア画面 (Pair Screen)

**役割**: 他者との緩やかな繋がりによる強制力。

*   **現状 (Status)**: 古いチャット風UIの可能性あり（要確認）。
*   **UI要件 (Target UI)**:
    *   **Comparison View**: 画面を左右（または上下）に分割し、「自分」と「相手」の今日の達成状況を対比表示。
    *   **Reactions**: テキストチャットではなく、「スタンプ（Good, Fire）」のみを送れるシンプルなUI。
*   **ロジック要件 (Target Logic)**:
    *   **Realtime**: Firestore `snapshots` を監視し、相手の達成状況をリアルタイム反映。
    *   **Notification**: 相手が達成した瞬間に通知をトリガー。

---

## 6. 設定画面 (Settings Screen)

**役割**: アプリの挙動設定、プロフィール管理。

*   **現状 (Status)**: 標準的なリストビュー。
*   **UI要件 (Target UI)**:
    *   **Profile**: ユーザーアイコンと名前を大きく表示。
    *   **Grouped List**: 設定項目を「アカウント」「通知」「サポート」などのセクションごとのカードにまとめる。
*   **ロジック要件 (Target Logic)**:
    *   **Auth**: ログアウト、アカウント削除機能の呼び出し。
    *   **Preferences**: `SharedPreferences` への設定保存（テーマ、通知時刻）。

---

## 共通実装事項 (Common)
*   **Navigation**: 全画面で `GoRouter` を使用。`context.push` ではなく `navigation.goToXxx` メソッド経由で統一。
*   **Error Handling**: データ取得失敗時は `MinqErrorState` ウィジェット（かわいいイラスト付き）を表示。
*   **Loading**: 読み込み中はスケルトンローディング（`MinqSkeleton`）を表示。
