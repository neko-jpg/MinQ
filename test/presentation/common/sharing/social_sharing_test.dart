import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/domain/social/achievement_share.dart';
import 'package:minq/presentation/common/celebration/celebration_system.dart';
import 'package:minq/presentation/common/sharing/progress_share_card.dart';

void main() {
  group('Social Sharing & Recognition System Tests', () {
    testWidgets('ProgressShareCard renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressShareCard(
              currentStreak: 15,
              bestStreak: 25,
              totalQuests: 100,
              completedToday: 3,
            ),
          ),
        ),
      );

      // ウィジェットが正常に描画されることを確認
      expect(find.byType(ProgressShareCard), findsOneWidget);
      
      // 基本的なテキストが含まれていることを確認
      expect(find.text('習慣化の記録'), findsOneWidget);
      expect(find.text('進捗をシェア'), findsOneWidget);
    });

    testWidgets('ProgressShareCard without share button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressShareCard(
              currentStreak: 5,
              bestStreak: 10,
              totalQuests: 50,
              completedToday: 2,
              showShareButton: false,
            ),
          ),
        ),
      );

      // シェアボタンが表示されないことを確認
      expect(find.text('進捗をシェア'), findsNothing);
    });

    test('CelebrationSystem returns random celebration', () {
      final celebration1 = CelebrationSystem.getRandomCelebration();
      final celebration2 = CelebrationSystem.getRandomCelebration();

      // 祝福演出の設定が取得できることを確認
      expect(celebration1, isA<CelebrationConfig>());
      expect(celebration2, isA<CelebrationConfig>());
      expect(celebration1.type, isA<CelebrationType>());
      expect(celebration2.type, isA<CelebrationType>());
    });

    test('CelebrationSystem returns appropriate celebration for streak', () {
      // 100日連続の場合
      final celebration100 = CelebrationSystem.getStreakCelebration(100);
      expect(celebration100.type, CelebrationType.golden);
      expect(celebration100.message, contains('100日達成'));

      // 50日連続の場合
      final celebration50 = CelebrationSystem.getStreakCelebration(50);
      expect(celebration50.type, CelebrationType.trophy);
      expect(celebration50.message, contains('50日達成'));

      // 30日連続の場合
      final celebration30 = CelebrationSystem.getStreakCelebration(30);
      expect(celebration30.type, CelebrationType.fireworks);
      expect(celebration30.message, contains('30日達成'));

      // 7日連続の場合
      final celebration7 = CelebrationSystem.getStreakCelebration(7);
      expect(celebration7.type, CelebrationType.confetti);
      expect(celebration7.message, contains('1週間達成'));
    });

    group('Celebration Types', () {
      test('All celebration types have valid configurations', () {
        for (final type in CelebrationType.values) {
          final config = CelebrationSystem.getCelebration(type);
          expect(config.type, type);
          expect(config.message, isNotNull);
          expect(config.message!.isNotEmpty, true);
          expect(config.duration.inMilliseconds, greaterThan(0));
        }
      });
    });

    group('Social Sharing System Components', () {
      test('ProgressShareCardPreview can be created', () {
        final progressShare = ProgressShare(
          currentStreak: 10,
          bestStreak: 15,
          totalQuests: 50,
          completedToday: 2,
          shareDate: DateTime.now(),
        );
        
        final preview = ProgressShareCardPreview(
          progressShare: progressShare,
        );
        
        expect(preview.progressShare.currentStreak, 10);
        expect(preview.progressShare.bestStreak, 15);
        expect(preview.progressShare.totalQuests, 50);
        expect(preview.progressShare.completedToday, 2);
      });
    });
  });
}