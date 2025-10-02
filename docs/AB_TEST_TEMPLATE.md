# A/Bテスト・実験テンプレート

このドキュメントは、A/Bテストや機能実験を実施する際のテンプレートです。

## 実験計画テンプレート

### 実験ID
`EXP-YYYYMMDD-001`

### 実験名
例: ホーム画面のCTA配置変更

### 実施期間
- **開始日**: YYYY/MM/DD
- **終了日**: YYYY/MM/DD
- **期間**: XX日間

### 目的
この実験で何を検証したいのかを明確に記載

例:
- ホーム画面のCTAボタンの配置を変更することで、クエスト作成率が向上するか検証する

### 仮説
変更によってどのような結果が期待されるか

例:
- CTAボタンを画面上部に配置することで、ユーザーの目に留まりやすくなり、クエスト作成率が10%向上する

### 対象ユーザー
- **セグメント**: 新規ユーザー / 既存ユーザー / 全ユーザー
- **プラットフォーム**: iOS / Android / 両方
- **地域**: 日本 / グローバル / 特定地域
- **サンプルサイズ**: 最低 1,000 ユーザー

### バリアント

#### コントロール群（A）
- **割合**: 50%
- **内容**: 現在の実装（CTAボタンは画面下部）
- **スクリーンショット**: [添付]

#### テスト群（B）
- **割合**: 50%
- **内容**: 新しい実装（CTAボタンは画面上部）
- **スクリーンショット**: [添付]

### 主要指標（Primary Metrics）

#### 1. クエスト作成率
- **定義**: ホーム画面を訪問したユーザーのうち、クエストを作成したユーザーの割合
- **計算式**: (クエスト作成ユーザー数 / ホーム画面訪問ユーザー数) × 100
- **現在の値**: 15%
- **目標値**: 16.5%（10%向上）
- **最小検出差**: 1.5%

### 副次指標（Secondary Metrics）

#### 1. クエスト作成数
- **定義**: 1ユーザーあたりの平均クエスト作成数
- **現在の値**: 2.5個
- **期待値**: 2.8個

#### 2. セッション時間
- **定義**: 1セッションあたりの平均滞在時間
- **現在の値**: 3分
- **期待値**: 維持または向上

#### 3. 離脱率
- **定義**: ホーム画面からの離脱率
- **現在の値**: 40%
- **期待値**: 維持または低下

### ガードレール指標（Guardrail Metrics）

これらの指標が悪化した場合、実験を中止する

#### 1. クラッシュ率
- **閾値**: 2%以上の増加で中止

#### 2. エラー率
- **閾値**: 5%以上の増加で中止

#### 3. ユーザー満足度
- **閾値**: アプリ評価が0.5以上低下で中止

### 統計的有意性

- **有意水準**: α = 0.05（5%）
- **検出力**: 1 - β = 0.80（80%）
- **必要サンプルサイズ**: 各群 1,000 ユーザー以上

### 実装方法

#### Remote Config設定
```json
{
  "exp_home_cta_position": {
    "defaultValue": "bottom",
    "conditionalValues": {
      "experiment_group_b": "top"
    }
  }
}
```

#### コード実装
```dart
// Remote Configから値を取得
final ctaPosition = ref.watch(remoteConfigProvider)
    .getString('exp_home_cta_position');

// バリアントに応じて表示を切り替え
Widget build(BuildContext context) {
  return Column(
    children: [
      if (ctaPosition == 'top') CreateQuestButton(),
      QuestList(),
      if (ctaPosition == 'bottom') CreateQuestButton(),
    ],
  );
}
```

#### Analytics設定
```dart
// 実験グループを記録
await analytics.setUserProperty(
  name: 'exp_home_cta_position',
  value: ctaPosition,
);

// イベントを記録
await analytics.logEvent(
  name: 'quest_created',
  parameters: {
    'exp_group': ctaPosition,
    'source': 'home_screen',
  },
);
```

### リスク評価

#### 技術的リスク
- **リスク**: レイアウト崩れ
- **対策**: 複数デバイスでテスト
- **影響度**: 低

#### ビジネスリスク
- **リスク**: ユーザー体験の悪化
- **対策**: ガードレール指標の監視
- **影響度**: 中

#### 運用リスク
- **リスク**: 実験の長期化
- **対策**: 明確な終了条件の設定
- **影響度**: 低

### 成功基準

以下のすべてを満たす場合、テスト群を採用

1. クエスト作成率が統計的に有意に向上（p < 0.05）
2. ガードレール指標が悪化していない
3. 副次指標が維持または向上

### 終了条件

以下のいずれかに該当する場合、実験を終了

1. 必要サンプルサイズに到達
2. 統計的有意差が確認された
3. ガードレール指標が閾値を超えた
4. 実施期間が終了した

### データ収集

#### 収集するデータ
- ユーザーID
- 実験グループ（A/B）
- イベント（画面表示、ボタンクリック、クエスト作成）
- タイムスタンプ
- デバイス情報
- プラットフォーム

#### データ保存先
- Firebase Analytics
- BigQuery（詳細分析用）

### 分析方法

#### 1. 記述統計
```sql
-- BigQuery
SELECT
  exp_group,
  COUNT(DISTINCT user_id) as users,
  COUNT(CASE WHEN event_name = 'quest_created' THEN 1 END) as quest_created,
  COUNT(CASE WHEN event_name = 'quest_created' THEN 1 END) / COUNT(DISTINCT user_id) as creation_rate
FROM
  analytics_events
WHERE
  event_date BETWEEN '2025-10-01' AND '2025-10-14'
  AND exp_group IN ('bottom', 'top')
GROUP BY
  exp_group
```

#### 2. 統計的検定
- **手法**: 2標本t検定（比率の差の検定）
- **ツール**: Python（scipy.stats）、R、または Google Sheets

```python
from scipy import stats

# コントロール群
control_success = 150  # クエスト作成数
control_total = 1000   # 総ユーザー数

# テスト群
test_success = 180
test_total = 1000

# 比率の差の検定
z_stat, p_value = stats.proportions_ztest(
    [control_success, test_success],
    [control_total, test_total]
)

print(f'Z統計量: {z_stat}')
print(f'p値: {p_value}')
print(f'有意差あり: {p_value < 0.05}')
```

### レポート

#### 実験結果サマリー

**実験ID**: EXP-20251001-001  
**実験名**: ホーム画面のCTA配置変更  
**実施期間**: 2025/10/01 - 2025/10/14（14日間）

**結果**: ✅ 成功（テスト群を採用）

| 指標 | コントロール群 | テスト群 | 差分 | p値 | 有意差 |
|------|--------------|---------|------|-----|--------|
| クエスト作成率 | 15.0% | 18.0% | +3.0% | 0.001 | ✅ |
| 平均作成数 | 2.5個 | 2.8個 | +0.3個 | 0.023 | ✅ |
| セッション時間 | 3.0分 | 3.2分 | +0.2分 | 0.156 | ❌ |
| 離脱率 | 40.0% | 38.0% | -2.0% | 0.089 | ❌ |

**ガードレール指標**: すべて正常

**結論**:
- CTAボタンを画面上部に配置することで、クエスト作成率が統計的に有意に向上した（+3.0%, p=0.001）
- 副次指��も改善傾向にあり、ガードレール指標に問題なし
- テスト群の実装を全ユーザーに展開することを推奨

**次のアクション**:
1. テスト群を100%展開
2. 2週間後に効果を再検証
3. 他の画面でも同様の改善を検討

---

## 実験チェックリスト

### 計画段階
- [ ] 実験の目的と仮説を明確化
- [ ] 主要指標と副次指標を定義
- [ ] ガードレール指標を設定
- [ ] 必要サンプルサイズを計算
- [ ] 実施期間を決定
- [ ] リスク評価を実施
- [ ] ステークホルダーの承認を取得

### 実装段階
- [ ] Remote Configを設定
- [ ] コードを実装
- [ ] Analyticsイベントを実装
- [ ] 開発環境でテスト
- [ ] ステージング環境でテスト
- [ ] コードレビューを実施

### 実施段階
- [ ] 実験を開始
- [ ] 初日にデータ収集を確認
- [ ] 毎日ガードレール指標を監視
- [ ] 週次で進捗を確認
- [ ] 問題があれば即座に対応

### 分析段階
- [ ] データを収集
- [ ] 記述統計を算出
- [ ] 統計的検定を実施
- [ ] 結果をレポートにまとめる
- [ ] ステークホルダーに報告

### 展開段階
- [ ] 勝者バリアントを決定
- [ ] 段階的に展開（10% → 50% → 100%）
- [ ] 展開後の効果を監視
- [ ] ドキュメントを更新

---

## 実験の種類

### 1. UI/UX実験
- ボタンの配置、色、サイズ
- レイアウトの変更
- コピーの変更

### 2. 機能実験
- 新機能の効果検証
- 機能の有効化/無効化
- 機能の実装方法の比較

### 3. アルゴリズム実験
- レコメンドアルゴリズムの比較
- ランキングアルゴリズムの比較
- 通知タイミングの最適化

### 4. 価格実験
- 課金額の変更
- 無料トライアル期間の変更
- プランの比較

---

## ツール

### Remote Config
- Firebase Remote Config
- LaunchDarkly
- Optimizely

### Analytics
- Firebase Analytics
- Google Analytics 4
- Mixpanel
- Amplitude

### 統計分析
- Python（scipy, statsmodels）
- R
- Google Sheets
- Excel

### 可視化
- Looker Studio
- Tableau
- Metabase

---

## ベストプラクティス

### DO（推奨）

✅ 明確な仮説を立てる
✅ 十分なサンプルサイズを確保する
✅ ガードレール指標を設定する
✅ 統計的有意性を確認する
✅ 実験結果をドキュメント化する

### DON'T（非推奨）

❌ 仮説なしで実験しない
❌ サンプルサイズが不十分なまま結論を出さない
❌ p値だけで判断しない（実務的な意味も考慮）
❌ 複数の実験を同時に実施しない（交絡を避ける）
❌ 実験を長期間放置しない

---

## 参考リソース

- [A/B Testing Guide](https://www.optimizely.com/optimization-glossary/ab-testing/)
- [Statistical Significance Calculator](https://www.evanmiller.org/ab-testing/sample-size.html)
- [Firebase A/B Testing](https://firebase.google.com/docs/ab-testing)

---

## 更新履歴

- 2025-10-02: 初版作成
