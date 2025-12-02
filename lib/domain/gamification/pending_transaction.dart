import 'package:isar/isar.dart';

part 'pending_transaction.g.dart';

@collection
class PendingTransaction {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late String method; // e.g., 'awardPoints', 'checkAndAwardBadges'

  late String payloadJson; // JSON string of arguments

  late DateTime createdAt;

  @Index()
  bool isSynced = false;
}
