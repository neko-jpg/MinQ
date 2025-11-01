import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:minq/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Test', () {
    testWidgets(
      'Complete user flow: Auth -> Create Quest -> Complete -> Share',
      (tester) async {
        // アプリ起動
        app.main();
        await tester.pumpAndSettle();

        // 1. 認証フロー
        await _testAuthFlow(tester);

        // 2. クエスト作成フロー
        await _testQuestCreation(tester);

        // 3. クエスト達成フロー
        await _testQuestCompletion(tester);

        // 4. 共有フロー
        await _testShareFlow(tester);
      },
    );

    testWidgets('Onboarding flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // オンボーディング画面の確認
      expect(find.text('Welcome'), findsOneWidget);

      // 次へボタンをタップ
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // 2ページ目
      expect(find.text('Create Habits'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // 3ページ目
      expect(find.text('Track Progress'), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
    });

    testWidgets('Quest CRUD operations', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ログイン済みと仮定
      await _skipToHome(tester);

      // クエスト作成
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Test Quest');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // クエストが作成されたことを確認
      expect(find.text('Test Quest'), findsOneWidget);

      // クエスト編集
      await tester.tap(find.text('Test Quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Updated Quest');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Updated Quest'), findsOneWidget);

      // クエスト削除
      await tester.tap(find.text('Updated Quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Updated Quest'), findsNothing);
    });

    testWidgets('Stats screen navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _skipToHome(tester);

      // Stats画面へ遷移
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Stats画面の要素を確認
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('Completion Rate'), findsOneWidget);
    });

    testWidgets('Profile settings', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _skipToHome(tester);

      // プロフィール画面へ遷移
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // プロフィール画面の要素を確認
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // 設定画面へ遷移
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });
  });
}

Future<void> _testAuthFlow(WidgetTester tester) async {
  // ログイン画面の確認
  expect(find.text('Sign In'), findsOneWidget);

  // メールアドレス入力
  await tester.enterText(
    find.byKey(const Key('email_field')),
    'test@example.com',
  );

  // パスワード入力
  await tester.enterText(
    find.byKey(const Key('password_field')),
    'password123',
  );

  // ログインボタンをタップ
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

Future<void> _testQuestCreation(WidgetTester tester) async {
  // クエスト作成ボタンをタップ
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // クエスト名入力
  await tester.enterText(
    find.byKey(const Key('quest_name_field')),
    'Morning Run',
  );

  // 通知時刻設定
  await tester.tap(find.text('Set Reminder'));
  await tester.pumpAndSettle();

  // 時刻選択（7:00 AM）
  await tester.tap(find.text('7'));
  await tester.tap(find.text('00'));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // 保存
  await tester.tap(find.text('Create'));
  await tester.pumpAndSettle();

  // クエストが作成されたことを確認
  expect(find.text('Morning Run'), findsOneWidget);
}

Future<void> _testQuestCompletion(WidgetTester tester) async {
  // クエストをタップ
  await tester.tap(find.text('Morning Run'));
  await tester.pumpAndSettle();

  // 完了ボタンをタップ
  await tester.tap(find.byIcon(Icons.check_circle));
  await tester.pumpAndSettle();

  // 祝福アニメーションの確認
  expect(find.byType(AnimatedWidget), findsWidgets);

  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _testShareFlow(WidgetTester tester) async {
  // 共有ボタンをタップ
  await tester.tap(find.byIcon(Icons.share));
  await tester.pumpAndSettle();

  // 共有オプションの確認
  expect(find.text('Share Progress'), findsOneWidget);
  expect(find.text('Share as Image'), findsOneWidget);
  expect(find.text('Share as Text'), findsOneWidget);
}

Future<void> _skipToHome(WidgetTester tester) async {
  // オンボーディングやログインをスキップしてホーム画面へ
  // テスト用のショートカットを使用
  await tester.tap(find.byKey(const Key('skip_to_home')));
  await tester.pumpAndSettle();
}
