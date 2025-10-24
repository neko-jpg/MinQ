import 'package:flutter/material.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/community/community_post.dart';
import 'package:riverpod/riverpod.dart';

final communityPostsProvider = StreamProvider<List<CommunityPost>>((ref) {
  final repository = ref.watch(communityBoardRepositoryProvider);
  if (repository == null) {
    return const Stream<List<CommunityPost>>.empty();
  }
  return repository.watchLatest();
});

final newCommunityPostControllerProvider =
    StateProvider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});
