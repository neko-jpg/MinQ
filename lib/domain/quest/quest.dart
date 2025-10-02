import 'package:isar/isar.dart';

part 'quest.g.dart';

enum QuestStatus {
  active,
  paused,
}

@Collection()
class Quest {
  Quest(); // Empty constructor for Isar

  Id id = Isar.autoIncrement;

  late String owner;
  late String title;
  late String category;

  int estimatedMinutes = 5;
  String? difficulty; // 'easy', 'medium', 'hard'
  String? location; // 'home', 'gym', 'office', etc.

  String? iconKey;

  @Enumerated(EnumType.name)
  late QuestStatus status;

  late DateTime createdAt;
  DateTime? deletedAt;
}
