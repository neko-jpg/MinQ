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
      FeedbackMessenger.showErrorToast(context, '繧ｳ繝溘Η繝九ユ繧｣謗ｲ遉ｺ譚ｿ繧貞茜逕ｨ縺ｧ縺阪∪縺帙ｓ');
      return;
    }

    final textController = ref.read(newCommunityPostControllerProvider);
    final message = textController.text.trim();
    if (message.isEmpty) {
      FeedbackMessenger.showErrorToast(context, '繝｡繝・そ繝ｼ繧ｸ繧貞・蜉帙＠縺ｦ縺上□縺輔＞');
      return;
    }

    final userId = ref.read(uidProvider);
    final displayName = userId?.substring(0, userId.length.clamp(0, 6)) ?? '蛹ｿ蜷阪Θ繝ｼ繧ｶ繝ｼ';

    try {
      await repository.create(
        authorId: userId ?? 'anonymous',
        displayName: displayName,
        message: message,
      );
      textController.clear();
      FeedbackMessenger.showSuccessToast(context, '謚慕ｨｿ縺励∪縺励◆');
    } catch (error) {
      FeedbackMessenger.showErrorToast(context, '謚慕ｨｿ縺ｫ螟ｱ謨励＠縺ｾ縺励◆');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider);
    final tokens = context.tokens;
    final controller = ref.watch(newCommunityPostControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('繧ｳ繝溘Η繝九ユ繧｣謗ｲ遉ｺ譚ｿ'),
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
                    '莉ｲ髢薙・騾ｲ謐励ｄ繧｢繧､繝・い繧偵す繧ｧ繧｢縺励ｈ縺・,
                    style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '莉頑律蜿悶ｊ邨・ｓ縺縺薙→繧・ｷ･螟ｫ繧貞・譛峨＠縺ｾ縺励ｇ縺・,
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
                      label: const Text('謚慕ｨｿ縺吶ｋ'),
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
                              '縺ｾ縺謚慕ｨｿ縺後≠繧翫∪縺帙ｓ縲よ怙蛻昴・謚慕ｨｿ閠・↓縺ｪ繧翫∪縺励ｇ縺・ｼ・,
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
                    child: Text('謚慕ｨｿ縺ｮ隱ｭ縺ｿ霎ｼ縺ｿ縺ｫ螟ｱ謨励＠縺ｾ縺励◆: $error'),
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
                  label: const Text('蝣ｱ蜻・),
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
      return '縺溘▲縺滉ｻ・;
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}蛻・燕';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}譎る俣蜑・;
    }
    return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
  }
}
