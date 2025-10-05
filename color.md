0. 基本パレット（トークン）
トークン名	HEX (Light)	HEX (Dark)	用途
primary	#18A0FB	#90CAF9	主操作・CTA ボタン／リンク
primary-hover	#0B74D8	#64B5F6	押下・フォーカス
secondary	#06BCB5	#4DD0C4	補助操作・アクセント Badges 等
background	#FFFFFF	#121212	画面背景
surface (card)	#F7FAFC	#1E1E1E	カード／モーダル／シート
surface-alt	#EFF3F8	#242424	入れ子カード・スケルトン
divider	#E0E0E0	#262626	区切線・ヘアライン
text-primary	#0D0D0D	#ECEFF1	メイン本文
text-secondary	#4F4F4F	#B0BEC5	補助テキスト
success	#3CB371	#66BB6A	達成／チェック
warning	#F0A202	#FFB74D	注意／残りわずか
error	#E55D5D	#EF9A9A	入力エラー／失敗
1. ウェルカム／オンボーディング

ヒーロータイトル: text-primary on background

メイン CTA ボタン: primary → hover/pressed は primary-hover

サブ CTA (ログイン/スキップなど): secondary アウトライン（線色＝secondary, 背景 transparent）

カード (3ステップ説明)

背景: surface

アイコン内円: primary 20% opacity

タイトル文字: text-primary

説明文: text-secondary

黒カードは重く感じるため廃止。カードシャドウは Elevation 2dp、ダークでは代わりにアウトライン=divider。

2. ホーム

今日やることバナー

背景: primary 8% opacity（ライト）、primary 16% opacity（ダーク）

アイコン: primary

アクションボタン（完了）: success Filled + セカンダリテキスト=白

進捗サマリカード

背景: surface

プログレスバー: トラック=divider、フィル=primary

バッジ（連続日数）: 背景=primary、文字=白

空状態 (No habits today)

イラスト: primary 24%

文言: text-secondary

“習慣を追加” CTA: primary

3. 習慣一覧 & 詳細

リストセル

背景: background（デフォルト）／完了済み行は surface-alt

前景チェックマーク: primary （未達は divider）

削除スワイプアクション: 背景=error, アイコン=白

詳細画面グラフ

ライン: primary

ポイント: primary outline 2px

グリッドライン: divider 50% opacity

編集ボタン (FAB): secondary, アイコン=白 → pressed=secondary 80%

4. 記録／ログ入力

入力フィールド

枠線: divider → フォーカス=primary

プレースホルダ: text-secondary 70% opacity

エラー: 枠線=error, ヘルパー文=error

“記録する” ボタン: primary (Enabled)／primary 40% opacity (Disabled)

オフラインバナー

背景=warning 16%

アイコン=warning

テキスト=text-secondary

5. 統計／実績

カード (週／月サマリ)

背景: surface

KPI 数字: text-primary

ラベル: text-secondary

勝利トロフィー

アイコンベース=success

背景バッジ=success 16%

タブ切替

アクティブ: テキスト=primary, インジケータ=primary

インアクティブ: text-secondary

6. ペア／チャット

自分の吹き出し: 背景=primary, 文字=白

相手の吹き出し: 背景=surface, 文字=text-primary

未読バッジ: 背景=primary, 文字=白, Elevation 0

送信エラー: 小アイコン=error, チップ背景=error 16%

7. 設定／アクセシビリティ

トグル ON: スイッチ Track=primary 40%, Thumb=primary

トグル OFF: Track=divider, Thumb=surface

セクション見出し: text-secondary

危険操作 (アカウント削除)

ボタン背景=error, 文字=白 → hover=error 80%

8. 通知 & ポリシー関連

通知チップ “New”: 背景=primary, 文字=白, Radius=12

プラン／価格表

FREE 列: 背景=surface

PRO 列: 背景=primary 8%, ボタン=primary

推奨ラベル: 背景=secondary, 文字=白

9. システム／エラー画面

致命的エラー: アイコン=error, 見出し=error

リロードボタン: 背景=primary, 文字=白

クラッシュログカード: 背景=surface-alt, テキスト=text-secondary
