import 'package:isar/isar.dart';

part 'pending_sync_job.g.dart';

@Collection()
class PendingSyncJob {
  PendingSyncJob();

  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String uid;

  @Index(caseSensitive: false)
  late String type;

  /// JSON payload describing the job.
  late String payload;

  late DateTime createdAt;

  DateTime? lastAttemptAt;

  int attemptCount = 0;

  String? lastError;
}

class SyncJobTypes {
  static const String userProfileUpsert = 'user_profile_upsert';
}
