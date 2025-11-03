import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minq/core/navigation/navigation_use_case.dart';
import 'package:minq/data/services/focus_music_service.dart';
import 'package:minq/data/services/photo_storage_service.dart';

final navigationUseCaseProvider = Provider<NavigationUseCase>((ref) {
  // This is a placeholder. You'll need to replace this with your actual
  // NavigationUseCase implementation.
  return NavigationUseCase();
});

final photoStorageServiceProvider = Provider<PhotoStorageService>((ref) {
  // This is a placeholder. You'll need to replace this with your actual
  // PhotoStorageService implementation.
  return PhotoStorageService();
});

final focusMusicServiceProvider = Provider<FocusMusicService>((ref) {
  // This is a placeholder. You'll need to replace this with your actual
  // FocusMusicService implementation.
  return FocusMusicService();
});

final focusMusicPlayerStateProvider = StreamProvider<PlayerState>((ref) {
  final focusMusicService = ref.watch(focusMusicServiceProvider);
  return focusMusicService.playerStateStream;
});
