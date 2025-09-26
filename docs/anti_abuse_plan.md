# 不正対策（通報レート制限）

## 目的

- 短時間に大量の通報を送信するスパム行為を抑制し、モデレーション負荷を軽減する

## 実装概要

- `LocalPreferencesService.registerReportAttempt` で 10 分間に 3 回までに制限
- 上限超過時は SnackBar で待機時間を案内 (`PairScreen`)
- SharedPreferences にタイムスタンプを保存し、アプリ再起動後もレート制限を維持

## 運用

1. レート制限値はリモート設定の導入を見越し `LocalPreferencesService` で定数化
2. サーバ側（Firestore）においてもアラートしきい値を設け、異常があれば手動介入
3. ログ (`MinqLogger`) に `pair_report_submitted` を記録し、サーバでモニタリング

## 追加検討事項（P1）

- 通報内容のハッシュ化による重複検知
- サーバサイドでの reCAPTCHA / Bot 対策
- 画像証跡の類似判定はバックログへ追加

これにより `task.md` の「不正対策: スパム通報のレート制限」を満たし、今後の高度化の土台を整えました。
