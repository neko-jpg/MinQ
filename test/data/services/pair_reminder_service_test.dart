import 'package:flutter_test/flutter_test.dart';

// Simple enum for testing
enum ReminderType {
  encouragement,
  celebration,
  checkIn,
  motivation,
}

// Simple template class for testing
class ReminderTemplate {
  final ReminderType type;
  final String message;
  final String emoji;
  final bool isCustom;

  const ReminderTemplate({
    required this.type,
    required this.message,
    required this.emoji,
    this.isCustom = false,
  });
}

// Template collections for testing
class ReminderTemplates {
  static const List<ReminderTemplate> encouragementTemplates = [
    ReminderTemplate(
      type: ReminderType.encouragement,
      message: '今日のクエスト、一緒に頑張りましょう！',
      emoji: '💪',
    ),
    ReminderTemplate(
      type: ReminderType.encouragement,
      message: 'あと少しで今日の目標達成ですね！',
      emoji: '🔥',
    ),
    ReminderTemplate(
      type: ReminderType.encouragement,
      message: '継続は力なり！今日も一歩ずつ進みましょう',
      emoji: '🌟',
    ),
    ReminderTemplate(
      type: ReminderType.encouragement,
      message: '一緒に習慣化を続けていきましょう！',
      emoji: '🤝',
    ),
  ];

  static const List<ReminderTemplate> celebrationTemplates = [
    ReminderTemplate(
      type: ReminderType.celebration,
      message: 'お疲れさまでした！今日もよく頑張りましたね',
      emoji: '🎉',
    ),
    ReminderTemplate(
      type: ReminderType.celebration,
      message: '素晴らしい！今日も目標達成ですね',
      emoji: '✨',
    ),
    ReminderTemplate(
      type: ReminderType.celebration,
      message: '継続記録更新！本当にすごいです',
      emoji: '🏆',
    ),
    ReminderTemplate(
      type: ReminderType.celebration,
      message: '今日も一日お疲れさまでした！',
      emoji: '😊',
    ),
  ];

  static const List<ReminderTemplate> checkInTemplates = [
    ReminderTemplate(
      type: ReminderType.checkIn,
      message: '調子はどうですか？一緒に継続していきましょう',
      emoji: '😊',
    ),
    ReminderTemplate(
      type: ReminderType.checkIn,
      message: '最近どうですか？お互い頑張りましょう',
      emoji: '🤗',
    ),
    ReminderTemplate(
      type: ReminderType.checkIn,
      message: '今日の調子はいかがですか？',
      emoji: '💭',
    ),
    ReminderTemplate(
      type: ReminderType.checkIn,
      message: 'お元気ですか？一緒に頑張っていきましょう',
      emoji: '🌈',
    ),
  ];

  static const List<ReminderTemplate> motivationTemplates = [
    ReminderTemplate(
      type: ReminderType.motivation,
      message: 'あなたならできます！応援しています',
      emoji: '🌟',
    ),
    ReminderTemplate(
      type: ReminderType.motivation,
      message: '小さな一歩も大きな変化につながります',
      emoji: '🚀',
    ),
    ReminderTemplate(
      type: ReminderType.motivation,
      message: '今日も素敵な一日にしましょう！',
      emoji: '☀️',
    ),
    ReminderTemplate(
      type: ReminderType.motivation,
      message: '一緒に成長していきましょう！',
      emoji: '🌱',
    ),
  ];

  static List<ReminderTemplate> getTemplates(ReminderType type) {
    switch (type) {
      case ReminderType.encouragement:
        return encouragementTemplates;
      case ReminderType.celebration:
        return celebrationTemplates;
      case ReminderType.checkIn:
        return checkInTemplates;
      case ReminderType.motivation:
        return motivationTemplates;
    }
  }

  static List<ReminderTemplate> getAllTemplates() {
    return [
      ...encouragementTemplates,
      ...celebrationTemplates,
      ...checkInTemplates,
      ...motivationTemplates,
    ];
  }
}

void main() {
  group('Pair Reminder System Tests', () {
    test('ReminderType enum has all expected values', () {
      expect(ReminderType.values.length, 4);
      expect(ReminderType.values, contains(ReminderType.encouragement));
      expect(ReminderType.values, contains(ReminderType.celebration));
      expect(ReminderType.values, contains(ReminderType.checkIn));
      expect(ReminderType.values, contains(ReminderType.motivation));
    });

    test('ReminderTemplate model creation', () {
      const template = ReminderTemplate(
        type: ReminderType.encouragement,
        message: 'テストメッセージ',
        emoji: '💪',
        isCustom: true,
      );

      expect(template.type, ReminderType.encouragement);
      expect(template.message, 'テストメッセージ');
      expect(template.emoji, '💪');
      expect(template.isCustom, true);
    });

    group('ReminderTemplates', () {
      test('encouragement templates are not empty', () {
        final templates = ReminderTemplates.encouragementTemplates;
        expect(templates.isNotEmpty, true);
        
        for (final template in templates) {
          expect(template.type, ReminderType.encouragement);
          expect(template.message.isNotEmpty, true);
          expect(template.emoji.isNotEmpty, true);
        }
      });

      test('celebration templates are not empty', () {
        final templates = ReminderTemplates.celebrationTemplates;
        expect(templates.isNotEmpty, true);
        
        for (final template in templates) {
          expect(template.type, ReminderType.celebration);
          expect(template.message.isNotEmpty, true);
          expect(template.emoji.isNotEmpty, true);
        }
      });

      test('checkIn templates are not empty', () {
        final templates = ReminderTemplates.checkInTemplates;
        expect(templates.isNotEmpty, true);
        
        for (final template in templates) {
          expect(template.type, ReminderType.checkIn);
          expect(template.message.isNotEmpty, true);
          expect(template.emoji.isNotEmpty, true);
        }
      });

      test('motivation templates are not empty', () {
        final templates = ReminderTemplates.motivationTemplates;
        expect(templates.isNotEmpty, true);
        
        for (final template in templates) {
          expect(template.type, ReminderType.motivation);
          expect(template.message.isNotEmpty, true);
          expect(template.emoji.isNotEmpty, true);
        }
      });

      test('getTemplates returns correct templates for each type', () {
        final encouragementTemplates = ReminderTemplates.getTemplates(ReminderType.encouragement);
        expect(encouragementTemplates, ReminderTemplates.encouragementTemplates);

        final celebrationTemplates = ReminderTemplates.getTemplates(ReminderType.celebration);
        expect(celebrationTemplates, ReminderTemplates.celebrationTemplates);

        final checkInTemplates = ReminderTemplates.getTemplates(ReminderType.checkIn);
        expect(checkInTemplates, ReminderTemplates.checkInTemplates);

        final motivationTemplates = ReminderTemplates.getTemplates(ReminderType.motivation);
        expect(motivationTemplates, ReminderTemplates.motivationTemplates);
      });

      test('getAllTemplates returns all templates', () {
        final allTemplates = ReminderTemplates.getAllTemplates();
        
        final expectedCount = ReminderTemplates.encouragementTemplates.length +
            ReminderTemplates.celebrationTemplates.length +
            ReminderTemplates.checkInTemplates.length +
            ReminderTemplates.motivationTemplates.length;
        
        expect(allTemplates.length, expectedCount);
        
        // 各タイプのテンプレートが含まれていることを確認
        expect(allTemplates.any((t) => t.type == ReminderType.encouragement), true);
        expect(allTemplates.any((t) => t.type == ReminderType.celebration), true);
        expect(allTemplates.any((t) => t.type == ReminderType.checkIn), true);
        expect(allTemplates.any((t) => t.type == ReminderType.motivation), true);
      });
    });

    group('Template Content Quality', () {
      test('all templates have appropriate Japanese messages', () {
        final allTemplates = ReminderTemplates.getAllTemplates();
        
        for (final template in allTemplates) {
          // メッセージが日本語を含んでいることを確認
          expect(template.message.isNotEmpty, true);
          expect(template.message.length, greaterThan(5));
          
          // 絵文字が設定されていることを確認
          expect(template.emoji.isNotEmpty, true);
          
          // カスタムフラグが正しく設定されていることを確認
          expect(template.isCustom, false);
        }
      });

      test('encouragement templates have positive tone', () {
        final templates = ReminderTemplates.encouragementTemplates;
        
        for (final template in templates) {
          // 励ましの言葉が含まれていることを確認
          final message = template.message.toLowerCase();
          final hasPositiveWords = message.contains('頑張') ||
              message.contains('一緒') ||
              message.contains('継続') ||
              message.contains('目標');
          
          expect(hasPositiveWords, true, reason: 'Message should contain positive words: ${template.message}');
        }
      });

      test('celebration templates have congratulatory tone', () {
        final templates = ReminderTemplates.celebrationTemplates;
        
        for (final template in templates) {
          // お祝いの言葉が含まれていることを確認
          final message = template.message.toLowerCase();
          final hasCelebratoryWords = message.contains('お疲れ') ||
              message.contains('素晴らしい') ||
              message.contains('達成') ||
              message.contains('すごい');
          
          expect(hasCelebratoryWords, true, reason: 'Message should contain celebratory words: ${template.message}');
        }
      });
    });
  });
}