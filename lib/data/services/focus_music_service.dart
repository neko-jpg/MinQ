import 'dart:async';

import 'package:just_audio/just_audio.dart';

class FocusMusicTrack {
  const FocusMusicTrack({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
  });

  final String id;
  final String title;
  final String description;
  final Uri url;
}

class FocusMusicService {
  FocusMusicService(this._player);

  final AudioPlayer _player;
  FocusMusicTrack? _currentTrack;

  static final List<FocusMusicTrack> tracks = <FocusMusicTrack>[
    const FocusMusicTrack(
      id: 'lofi_river',
      title: 'Lofi River',
      description: '静かな川のせせらぎに合わせたローファイBGM',
      url: Uri.parse(
        'https://cdn.pixabay.com/audio/2023/04/18/audio_b00f6805be.mp3',
      ),
    ),
    const FocusMusicTrack(
      id: 'deep_focus',
      title: 'Deep Focus',
      description: '低めのシンセで集中力を高めます',
      url: Uri.parse(
        'https://cdn.pixabay.com/audio/2023/01/31/audio_1ad95bbfb7.mp3',
      ),
    ),
    const FocusMusicTrack(
      id: 'acoustic_breeze',
      title: 'Acoustic Breeze',
      description: '軽やかなアコースティックギターでリラックス',
      url: Uri.parse(
        'https://cdn.pixabay.com/audio/2022/10/16/audio_552541d9d1.mp3',
      ),
    ),
  ];

  FocusMusicTrack? get currentTrack => _currentTrack;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> play(FocusMusicTrack track) async {
    if (_currentTrack?.id != track.id) {
      await _player.setUrl(track.url.toString());
      _currentTrack = track;
    }
    await _player.setLoopMode(LoopMode.one);
    await _player.play();
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}
