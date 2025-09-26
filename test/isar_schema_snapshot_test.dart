import 'package:flutter_test/flutter_test.dart';
import 'package:minq/domain/quest/quest.dart';

void main() {
  test('Quest schema remains frozen for v1 release', () {
    expect(QuestSchema.version, '3.1.0+1');
    expect(QuestSchema.properties.keys.toSet(), <String>{
      'category',
      'createdAt',
      'deletedAt',
      'estimatedMinutes',
      'iconKey',
      'owner',
      'status',
      'title',
    });
    expect(QuestSchema.indexes, isEmpty);
    expect(QuestSchema.links, isEmpty);
  });
}
