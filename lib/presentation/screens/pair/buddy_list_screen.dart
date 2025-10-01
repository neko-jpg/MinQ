import 'package:minq/presentation/routing/app_router.dart';

class BuddyListScreen extends ConsumerWidget {
  const BuddyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final pairAsync = ref.watch(userPairProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('現在のバディ', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: pairAsync.when(
        data: (pair) {
          if (pair == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: tokens.textMuted),
                  const SizedBox(height: 16),
                  const Text('まだバディがいません'),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _BuddyCard(pair: pair),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('新しいバディを探す'),
          onPressed: () => ref.read(navigationUseCaseProvider).goToPairMatching(),
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.brandPrimary,
            foregroundColor: tokens.surface,
            minimumSize: Size.fromHeight(tokens.spacing(14)),
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
            textStyle: tokens.titleSmall,
          ),
        ),
      ),
    );
  }
}

class _BuddyCard extends ConsumerWidget {
  const _BuddyCard({required this.pair});

  final Pair pair;

  void _showOptionsMenu(BuildContext context, WidgetRef ref, String otherMemberId) {
    final repo = ref.read(pairRepositoryProvider);
    final currentUserId = ref.read(uidProvider);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('バディをブロック', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(ctx).pop(); // Close the bottom sheet
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('バディをブロック'),
                  content: const Text('ブロックすると、今後このユーザーとマッチングしなくなります。本当によろしいですか？'),
                  actions: <Widget>[
                    TextButton(child: const Text('キャンセル'), onPressed: () => Navigator.of(dialogCtx).pop()),
                    TextButton(
                      child: const Text('ブロック', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        if (repo != null && currentUserId != null) {
                          repo.blockUser(currentUserId, otherMemberId);
                        }
                        Navigator.of(dialogCtx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ペアを解消', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(ctx).pop(); // Close the bottom sheet
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('ペアを解消'),
                  content: const Text('本当にこのバディとのペアを解消しますか？この操作は取り消せません。'),
                  actions: <Widget>[
                    TextButton(child: const Text('キャンセル'), onPressed: () => Navigator.of(dialogCtx).pop()),
                    TextButton(
                      child: const Text('解消する', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        if (repo != null && currentUserId != null) {
                          repo.leavePair(pair.id, currentUserId);
                        }
                        Navigator.of(dialogCtx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final currentUserId = ref.watch(uidProvider);
    final otherMemberId = pair.members.firstWhere((id) => id != currentUserId, orElse: () => '...');

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: tokens.background,
                  child: Icon(Icons.person, size: 28, color: tokens.textMuted),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buddy#${otherMemberId.substring(0, 4)}', style: tokens.titleSmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('目標：${pair.category}', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: tokens.textMuted),
                  onPressed: () => _showOptionsMenu(context, ref, otherMemberId),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: tokens.border, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionItem(icon: Icons.volunteer_activism_outlined, label: '拍手', color: Colors.green.shade400, onTap: () {
                  final repo = ref.read(pairRepositoryProvider);
                  if (currentUserId != null && repo != null) {
                    repo.sendHighFive(pair.id, currentUserId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('👏 拍手を送りました！')),
                    );
                  }
                }),
                _ActionItem(icon: Icons.chat_bubble_outline, label: 'チャット', color: Colors.blue.shade400, onTap: () => ref.read(navigationUseCaseProvider).goToPairChat(pair.id)),
                _ActionItem(icon: Icons.check_circle_outline, label: 'チェックイン', color: Colors.orange.shade400, onTap: () {
                  final repo = ref.read(pairRepositoryProvider);
                  if (currentUserId != null && repo != null) {
                    repo.sendCheckIn(pair.id, currentUserId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ 今日の達成を報告しました！')),
                    );
                  }
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: tokens.cornerLarge(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: tokens.bodySmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
