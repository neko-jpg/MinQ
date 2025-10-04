import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/community/community_post.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/controllers/community_board_controller.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CommunityBoardScreen extends ConsumerWidget {
  const CommunityBoardScreen({super.key});

  Future<void> _handleSubmit(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final repository = ref.read(communityBoardRepositoryProvider);
    if (repository == null) {
      FeedbackMessenger.showErrorToast(context, 'コミュニティ掲示板を利用できません');
      return;
    }

    final textController = ref.read(newCommunityPostControllerProvider);
    final message = textController.text.trim();
    if (message.isEmpty) {
      FeedbackMessenger.showErrorToast(context, 'メッセージを入力してください');
      return;
    }

    final userId = ref.read(uidProvider);
    final displayName = userId?.substring(0, userId.length.clamp(0, 6)) ?? '匿名ユーザー';

    try {
      await repository.create(
        authorId: userId ?? 'anonymous',
        displayName: displayName,
        message: message,
      );
      textController.clear();
      FeedbackMessenger.showSuccessToast(context, '投稿しました');
    } catch (error) {
      FeedbackMessenger.showErrorToast(context, '投稿に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider);
    final tokens = context.tokens;
    final controller = ref.watch(newCommunityPostControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('コミュニティ掲示板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '仲間の進捗やアイデアをシェアしよう',
                    style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '今日取り組んだことや工夫を共有しましょう',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radius(3)),
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => _handleSubmit(ref, context),
                      icon: const Icon(Icons.send),
                      label: const Text('投稿する'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: postsAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spacing(6)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.groups, size: 64, color: tokens.textMuted),
                            SizedBox(height: tokens.spacing(3)),
                            Text(
                              'まだ投稿がありません。最初の投稿者になりましょう！',
                              style: tokens.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spacing(4)),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => SizedBox(height: tokens.spacing(3)),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _CommunityPostCard(post: post);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacing(6)),
                    child: Text('投稿の読み込みに失敗しました: $error'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostCard extends ConsumerWidget {
  const _CommunityPostCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final repository = ref.watch(communityBoardRepositoryProvider);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  post.authorDisplayName,
                  style: tokens.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatTimestamp(post.createdAt),
                  style: tokens.labelMedium.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(post.message, style: tokens.bodyLarge),
            SizedBox(height: tokens.spacing(3)),
            Row(
              children: [
                IconButton(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_border),
                      SizedBox(width: tokens.spacing(1)),
                      Text(post.likeCount.toString()),
                    ],
                  ),
                  onPressed: repository == null
                      ? null
                      : () => repository.like(post.id),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: repository == null
                      ? null
                      : () => repository.report(post.id),
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('報告'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'たった今';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    }
    return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
  }
}
