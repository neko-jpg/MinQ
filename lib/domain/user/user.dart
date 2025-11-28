import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
class User {
  User();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  late DateTime createdAt;
  late List<String> notificationTimes;
  late String privacy;

  @Name('streak')
  int longestStreak = 0;

  int currentStreak = 0;
  DateTime? longestStreakReachedAt;

  String? pairId;

  // オンボーディング関連
  bool onboardingCompleted = false;
  int? onboardingLevel;

  // ゲーミフィケーション関連
  int currentLevel = 1;
  int totalPoints = 0;
}
