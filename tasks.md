# MinQ Master Task List (100万DLへの道)

このリストは、`GROWTH_STRATEGY.md`（成長戦略）と `REVIEW_REPORT.md`（コードレビュー）に基づいて作成された統合タスクリストです。
これまでの `task.md` の内容はここに統合・再編されました。

---

## Phase 1: Foundation & Refactoring (基盤固め) 🚧
**目標:** スパゲッティコードを解消し、デザインシステムを適用して、「当たり前品質」を担保する。

### 1.1 UI Refactoring (Design System Adoption)
- [ ] **Home Screen V2 (`lib/features/home/presentation/screens/home_screen_v2.dart`)**
  - [ ] Hardcoded strings を `AppLocalizations` に置き換える。
  - [ ] Hardcoded colors/sizes を `MinqTheme` (context.tokens) に置き換える。
  - [ ] プレースホルダー部分にローディング/エラー/空の状態を追加する。
- [ ] **Quest Creation Screen (`lib/features/onboarding/presentation/screens/guided_quest_creation_screen.dart`)**
  - [ ] デザインシステムを適用し、見た目を整える。
  - [ ] テンプレートリストをハードコーディングからサービス経由に変更する。

### 1.2 Architecture Refactoring
- [ ] **Split `providers.dart`**
  - [ ] `lib/data/providers.dart` を解体し、各Featureディレクトリ (`features/home/providers.dart` 等) に分散させる。
  - [ ] `appStartupProvider` のロジックを `StartupService` クラスに移動する。
- [ ] **Create Application Layer (Controllers)**
  - [ ] `QuestController` (または `QuestNotifier`) を作成し、クエスト完了時のフロー（Isar更新 -> ポイント計算 -> Sync）を一元管理する。
- [ ] **Externalize Seed Data**
  - [ ] `QuestRepository` 内の `_templateSeedData` を `assets/data/initial_quests.json` に移動し、読み込みロジックを修正する。

---

## Phase 2: Core Logic Implementation (習慣化ループの確立) ⚙️
**目標:** 「クエスト完了 → 即時報酬」のコアループを正常に動作させる。

### 2.1 Gamification Engine (`lib/core/gamification`)
- [ ] **GamificationEngine**
  - [ ] `awardPoints`: クエスト完了イベントを検知してポイントを加算するロジックを実装。
  - [ ] `checkAndAwardBadges`: ユーザーの進捗（ストリーク等）に基づきバッジを付与するロジックを実装。
  - [ ] `calculateRank`: ポイントに基づくランク計算ロジックを実装。
- [ ] **Reward System**
  - [ ] Firestoreから報酬カタログを取得するロジック。
  - [ ] ポイント消費による報酬交換フローの実装。

### 2.2 Quest & Progress Logic
- [ ] **Challenge Service**
  - [ ] デイリー/ウィークリーチャレンジの生成と保存ロジック。
  - [ ] チャレンジ達成時の報酬付与ロジック。
- [ ] **Progress Visualization**
  - [ ] ストリーク計算ロジックの実装（`quest_logs` の分析）。
  - [ ] マイルストーン達成（7日, 30日）の検知ロジック。

### 2.3 Home Screen Integration
- [ ] **Connect UI to Logic**
  - [ ] 今日のクエスト一覧の「ワンタップ完了」を `QuestController` に接続。
  - [ ] ストリーク表示を `ProgressVisualizationService` に接続。
  - [ ] アクティブなチャレンジ表示を `ChallengeService` に接続。

---

## Phase 3: Growth Engines (100万DL機能の実装) 🚀
**目標:** バイラルとリテンションを強化する「キラー機能」の実装。

### 3.1 Viral Features (Acquisition)
- [ ] **Kizuna Pass (絆パス) System**
  - [ ] 招待コード生成ロジックの実装。
  - [ ] 招待コード入力によるペア成立と特典（プレミアム体験）付与ロジック。
- [ ] **AI Habit DNA (Shareable Content)**
  - [ ] `HabitDNAService`: ユーザー行動ログからタイプ診断を行うロジック。
  - [ ] `OgpImageGenerator`: 診断結果をSNSシェア用画像に変換するロジック。

### 3.2 Retention Features (Social Pressure)
- [ ] **Resonance Streak (共鳴ストリーク)**
  - [ ] ペアの合算ストリーク計算ロジック。
  - [ ] 「ライフライン（身代わり完了）」機能の実装。
- [ ] **Reverse Accountability**
  - [ ] ペアがクエスト完了した際のプッシュ通知送信。
  - [ ] 「共鳴ボーナス」の実装。

### 3.3 Engagement Features (Community)
- [ ] **World Boss Events**
  - [ ] 全ユーザーのクエスト完了数を集計するバックエンド関数 (Cloud Functions想定)。
  - [ ] ホーム画面へのワールドボスHP表示ウィジェットの実装。

---

## Phase 4: Advanced AI & Health (未来機能) 🧠
*旧タスクリストからの継承項目*

- [ ] **Gemma AI Service:** ローカルLLM (Gemma) の統合とテキスト生成。
- [ ] **Health Sync:** HealthKit/Google Fit 連携によるクエスト自動完了。
- [ ] **Mood Tracking:** 気分ログの保存と習慣との相関分析。
- [ ] **Time Capsule:** 未来の自分へのメッセージ送信。
- [ ] **Voice Input:** 音声認識によるクエスト完了。

---

## Phase 5: Refinements & Release Prep 📦
- [ ] **Push Notifications:** FCMの完全統合。
- [ ] **Localization:** 日本語・英語の完全対応チェック。
- [ ] **Data Export:** PDFエクスポート機能。
- [ ] **In-App Purchases:** 課金フローの実装。
