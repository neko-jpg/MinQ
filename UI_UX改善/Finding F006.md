Finding F006 — Supabase同期キューが存在しない

Severity: P1

Area: Offline

Files: lib/data/repositories/user_repository.dart 他

Symptom (現象): プロフィール更新やクエスト編集などがIsarへ楽観的に保存される一方で、Supabaseへの同期処理が実装されていない。ユーザーは複数デバイス間でデータを共有できず、オンライン復帰時も変更が反映されない。
github.com

Likely Root Cause (推定原因): オフラインファーストアーキテクチャへの移行途上で、ローカル永続化を先行させた後にクラウド同期を追加する予定だったが、タスクの優先度が低下した。Supabaseに関わる設定やAPI通信部分が欠落している。

Concrete Fix (修正案):

Supabaseのユーザープロファイルテーブルとクエストテーブルに対応するリモートモデルを定義する。

UserRepository.saveLocalUserやQuestRepository.add等でデータをIsarに保存した後、同期ジョブを非同期キューに追加する。キューはNetworkStatusServiceを監視し、オンライン時にバッチ送信する。

送信成功時はキューから削除し、失敗時は再試行回数を持たせる。

UIにはSyncStatusウィジェットを追加し、同期中・同期失敗・同期完了をユーザーに伝える。

Tests (テスト): 統合テストProfileUpdate_offline_then_syncで、オフライン中にプロフィールを変更し、接続回復後にSupabaseと同期されることを検証する。ユニットテストでキューの再試行ロジックを検証する。

Impact/Effort/Confidence: I=5, E=5 days, C=4

Patch (≤30 lines, unified diff if possible):

この改善は大規模な機能追加となるため、ここでは概念的なコードスケッチのみ示します。詳細な実装は非同期キュー管理やSupabaseクライアント設定に依存します。

// Pseudo-code for enqueueing sync after saving locally
Future<void> saveLocalUser(User user) async {
  await isar.writeTxn(() => users.put(user));
  _syncQueue.add(SyncJob(type: SyncJobType.updateUser, payload: user.toJson()));
}

// Worker that runs periodically when online
void _processSyncQueue() async {
  if (!networkService.isOnline) return;
  final job = _syncQueue.peek();
  final response = await supabaseClient.from(job.table).upsert(job.payload);
  if (response.error == null) {
    _syncQueue.removeFirst();
  } else {
    job.retryCount++;
    if (job.retryCount > maxRetries) {
      // mark as failed and notify UI
    }
  }
}