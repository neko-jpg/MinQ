import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:minq/data/services/focus_music_service.dart';
import 'package:test/test.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  setUpAll(() {
    registerFallbackValue(LoopMode.off);
  });
  group('FocusMusicService', () {
    late MockAudioPlayer player;
    late FocusMusicService service;

    setUp(() {
      player = MockAudioPlayer();
      when(() => player.playerStateStream).thenAnswer((_) => const Stream.empty());
      when(() => player.setUrl(any())).thenAnswer((_) async {});
      when(() => player.setLoopMode(any())).thenAnswer((_) async {});
      when(() => player.play()).thenAnswer((_) async {});
      service = FocusMusicService(player);
    });

    test('loads url and starts playback for new track', () async {
      final track = FocusMusicService.tracks.first;

      await service.play(track);

      expect(service.currentTrack, equals(track));
      verify(() => player.setUrl(track.url.toString())).called(1);
      verify(() => player.setLoopMode(LoopMode.one)).called(1);
      verify(() => player.play()).called(1);
    });

    test('reuses existing url when playing same track consecutively', () async {
      final track = FocusMusicService.tracks.first;

      await service.play(track);
      await service.play(track);

      verify(() => player.setUrl(track.url.toString())).called(1);
      verify(() => player.play()).called(2);
    });
  });
}
