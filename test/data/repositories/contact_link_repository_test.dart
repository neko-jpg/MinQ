import 'package:minq/data/repositories/contact_link_repository.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockPreferences extends Mock implements LocalPreferencesService {}

void main() {
  group('ContactLinkRepository', () {
    late MockPreferences preferences;
    late ContactLinkRepository repository;

    setUp(() {
      preferences = MockPreferences();
      repository = ContactLinkRepository(preferences);
    });

    test('loads links once and caches results', () async {
      when(() => preferences.loadQuestContactLinks()).thenAnswer(
        (_) async => <int, String>{1: 'https://example.com'},
      );

      final first = await repository.getLink(1);
      final second = await repository.getLink(1);

      expect(first, equals('https://example.com'));
      expect(second, equals('https://example.com'));
      verify(() => preferences.loadQuestContactLinks()).called(1);
    });

    test('sanitises values when saving and supports removal', () async {
      when(() => preferences.loadQuestContactLinks()).thenAnswer(
        (_) async => <int, String>{},
      );
      when(() => preferences.saveQuestContactLinks(any())).thenAnswer(
        (_) async => true,
      );

      await repository.setLink(1, '  https://contact.example.com  ');
      verify(
        () => preferences.saveQuestContactLinks(
          {1: 'https://contact.example.com'},
        ),
      ).called(1);

      await repository.setLink(1, '');
      verify(
        () => preferences.saveQuestContactLinks(<int, String>{}),
      ).called(1);
    });
  });
}
