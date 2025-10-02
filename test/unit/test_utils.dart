import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

/// テストユーティリティ
class TestUtils {
  /// モックデータを生成
  static Map<String, dynamic> createMockQuest({
    String? id,
    String? title,
    String? userId,
  }) {
    return {
      'id': id ?? 'test_quest_1',
      'title': title ?? 'Test Quest',
      'userId': userId ?? 'test_user_1',
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
    };
  }

  /// モックユーザーを生成
  static Map<String, dynamic> createMockUser({
    String? id,
    String? name,
    String? email,
  }) {
    return {
      'id': id ?? 'test_user_1',
      'name': name ?? 'Test User',
      'email': email ?? 'test@example.com',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// 非同期テストを実行
  static Future<void> runAsyncTest(
    Future<void> Function() test, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await test().timeout(timeout);
  }

  /// エラーをキャッチしてテスト
  static Future<void> expectThrows<T extends Exception>(
    Future<void> Function() test,
  ) async {
    try {
      await test();
      fail('Expected exception was not thrown');
    } catch (e) {
      expect(e, isA<T>());
    }
  }
}

/// モックビルダー
class MockBuilder {
  /// モックリストを生成
  static List<T> buildList<T>(T Function(int) builder, int count) {
    return List.generate(count, builder);
  }

  /// ランダムな文字列を生成
  static String randomString([int length = 10]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (i) => chars[i % chars.length]).join();
  }

  /// ランダムな日時を生成
  static DateTime randomDateTime() {
    final now = DateTime.now();
    final random = DateTime(
      now.year,
      now.month,
      now.day - (now.day % 30),
    );
    return random;
  }
}

/// テストマッチャー
class CustomMatchers {
  /// 日付が近いかチェック
  static Matcher isCloseTo(DateTime expected, {Duration tolerance = const Duration(seconds: 1)}) {
    return predicate<DateTime>(
      (actual) {
        final diff = actual.difference(expected).abs();
        return diff <= tolerance;
      },
      'is close to $expected within $tolerance',
    );
  }

  /// リストが空でないかチェック
  static Matcher isNotEmpty = predicate<List>(
    (list) => list.isNotEmpty,
    'is not empty',
  );
}
