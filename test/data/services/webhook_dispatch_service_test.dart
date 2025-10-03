import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/data/services/webhook_dispatch_service.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:test/test.dart';

class MockClient extends Mock implements http.Client {}

class MockPreferences extends Mock implements LocalPreferencesService {}

class MockLogger extends Mock implements AppLogger {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('WebhookDispatchService', () {
    late MockClient client;
    late MockPreferences preferences;
    late MockLogger logger;
    late WebhookDispatchService service;
    late Quest quest;
    late QuestLog log;

    setUp(() {
      client = MockClient();
      preferences = MockPreferences();
      logger = MockLogger();
      service = WebhookDispatchService(
        client: client,
        preferences: preferences,
        logger: logger,
      );

      quest = Quest()
        ..id = 42
        ..owner = 'user'
        ..title = '集中セッション'
        ..category = QuestCategory.productivity.displayName
        ..status = QuestStatus.active
        ..estimatedMinutes = 25
        ..createdAt = DateTime(2024, 1, 1);

      log = QuestLog()
        ..id = 1
        ..uid = 'user'
        ..questId = quest.id
        ..ts = DateTime(2024, 1, 2, 12).toUtc()
        ..proofType = ProofType.check
        ..proofValue = 'done'
        ..synced = true;
    });

    test('does nothing when no endpoints are configured', () async {
      when(() => preferences.loadWebhookEndpoints()).thenAnswer((_) async => <String>[]);

      await service.dispatchQuestCompletion(quest: quest, log: log);

      verifyNever(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')));
    });

    test('posts quest completion payload to configured endpoints', () async {
      final endpoint = 'https://example.com/hook';
      when(() => preferences.loadWebhookEndpoints()).thenAnswer(
        (_) async => <String>[endpoint],
      );
      when(() => client.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('{}', 200));
      when(() => logger.logApiRequest(any(), any(), body: any(named: 'body')))
          .thenReturn(null);
      when(() => logger.logApiResponse(any(), any(), any(), body: any(named: 'body')))
          .thenReturn(null);

      await service.dispatchQuestCompletion(quest: quest, log: log);

      verify(
        () => client.post(
          Uri.parse(endpoint),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).called(1);

      final captured = verify(
        () => logger.logApiRequest('POST', endpoint, body: captureAny(named: 'body')),
      ).captured.single as Map<String, dynamic>;
      expect(captured['questId'], equals(quest.id));
      expect(captured['completedAt'], equals(log.ts.toIso8601String()));
    });
  });
}
