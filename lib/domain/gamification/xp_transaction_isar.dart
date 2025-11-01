import 'package:isar/isar.dart';
import 'package:minq/domain/gamification/xp_transaction.dart';

part 'xp_transaction_isar.g.dart';

/// Isar用のXPTransaction
@Collection()
class XPTransactionIsar {
  Id id = Isar.autoIncrement;

  late String userId;
  late int xpAmount;
  late String reason;
  @enumerated
  late XPSource source;
  late DateTime createdAt;
  double? multiplier;
  int? streakBonus;
  int? difficultyBonus;

  // Convert from domain model
  static XPTransactionIsar fromDomain(XPTransaction transaction) {
    return XPTransactionIsar()
      ..id = transaction.id
      ..userId = transaction.userId
      ..xpAmount = transaction.xpAmount
      ..reason = transaction.reason
      ..source = transaction.source
      ..createdAt = transaction.createdAt
      ..multiplier = transaction.multiplier
      ..streakBonus = transaction.streakBonus
      ..difficultyBonus = transaction.difficultyBonus;
  }

  // Convert to domain model
  XPTransaction toDomain() {
    return XPTransaction(
      id: id,
      userId: userId,
      xpAmount: xpAmount,
      reason: reason,
      source: source,
      createdAt: createdAt,
      multiplier: multiplier,
      streakBonus: streakBonus,
      difficultyBonus: difficultyBonus,
    );
  }
}
