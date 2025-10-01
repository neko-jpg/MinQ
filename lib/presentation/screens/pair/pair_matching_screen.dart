import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

enum PairMatchingStatus { searching, matchFound, noMatch, confirmed }

class PairMatchingScreen extends ConsumerStatefulWidget {
  const PairMatchingScreen({super.key});

  @override
  ConsumerState<PairMatchingScreen> createState() => _PairMatchingScreenState();
}

class _PairMatchingScreenState extends ConsumerState<PairMatchingScreen>
    with TickerProviderStateMixin {
  PairMatchingStatus _status = PairMatchingStatus.searching;
  late final AnimationController _controller;
  String? _foundPairId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => _startPairing());
  }

  Future<void> _startPairing() async {
    setState(() {
      _status = PairMatchingStatus.searching;
    });

    final repo = ref.read(pairRepositoryProvider);
    final uid = ref.read(uidProvider);
    if (repo == null || uid == null) {
      if (mounted) setState(() => _status = PairMatchingStatus.noMatch);
      return;
    }

    // TODO: Get category from previous screen
    const category = 'Fitness';
    final pairId = await repo.requestRandomPair(uid, category);

    if (mounted) {
      setState(() {
        if (pairId != null) {
          _foundPairId = pairId;
          _status = PairMatchingStatus.matchFound;
        } else {
          _status = PairMatchingStatus.noMatch;
        }
      });
    }
  }

  Future<void> _subscribeToNotifications() async {
    final messaging = FirebaseMessaging.instance;
    final repo = ref.read(pairRepositoryProvider);
    final uid = ref.read(uidProvider);

    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('通知が許可されませんでした。')));
      return;
    }

    final token = await messaging.getToken();
    if (token != null && uid != null && repo != null) {
      // TODO: Get category from previous screen
      const category = 'Fitness';
      await repo.subscribeToPairingNotifications(uid, token, category);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('通知を登録しました！')));
      context.pop();
    } else {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('通知の登録に失敗しました。')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSearchingUI(BuildContext context, MinqTheme tokens) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        SizedBox(
          width: 192,
          height: 192,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tokens.brandPrimary.withOpacity(0.2),
                    width: 4,
                  ),
                ),
              ),
              RotationTransition(
                turns: _controller,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tokens.brandPrimary.withOpacity(0.4),
                      width: 4,
                    ),
                  ),
                ),
              ),
              Icon(Icons.groups, color: tokens.brandPrimary, size: 64),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'バディを探しています…',
          style: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'あなたのプライバシーは保護されています。相手にはあなたの年齢層と目標カテゴリのみが共有されます。',
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
        ),
        const Spacer(flex: 3),
        MinqSecondaryButton(
          label: 'キャンセル',
          onPressed: () async => context.pop(),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildMatchFoundUI(BuildContext context, MinqTheme tokens) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            'バディが見つかりました！',
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: tokens.cornerXLarge(),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  tokens,
                  '匿名ID',
                  'Buddy#${_foundPairId?.substring(0, 4) ?? '????'}',
                ),
                Divider(color: tokens.border, height: 32),
                _buildInfoRow(tokens, '年齢帯', '18-24'), // TODO: Get real data
                Divider(color: tokens.border, height: 32),
                _buildInfoRow(
                  tokens,
                  '目標カテゴリ',
                  'Fitness',
                ), // TODO: Get real data
              ],
            ),
          ),
          const Spacer(flex: 3),
          MinqPrimaryButton(
            label: 'このバディとペアを組む',
            onPressed: () async {
              // This part is simplified. In a real app, you might confirm the pairing.
              setState(() => _status = PairMatchingStatus.confirmed);
            },
          ),
          const SizedBox(height: 16),
          MinqSecondaryButton(label: '別の候補を探す', onPressed: _startPairing),
          const SizedBox(height: 16),
          MinqTextButton(label: 'キャンセル', onTap: () => context.pop()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNoMatchUI(BuildContext context, MinqTheme tokens) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.sentiment_dissatisfied,
            color: tokens.brandPrimary,
            size: 72,
          ),
          const SizedBox(height: 24),
          Text(
            '現在、条件に合う\n候補が見つかりませんでした',
            textAlign: TextAlign.center,
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '条件に合うバディが現れた際に通知を受け取るか、検索条件を変更して再度お試しください。',
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          const Spacer(),
          MinqPrimaryButton(
            label: '通知を受け取る',
            icon: Icons.notifications,
            onPressed: _subscribeToNotifications,
          ),
          const SizedBox(height: 16),
          MinqSecondaryButton(
            label: '条件を広げる',
            onPressed: () async => context.pop(), // Go back to filter screen
          ),
          const SizedBox(height: 16),
          MinqTextButton(label: '再度探す', onTap: _startPairing),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildConfirmedUI(BuildContext context, MinqTheme tokens) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            '🎉 バディ成立！ 🎉',
            style: tokens.displaySmall.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '新しいバディと一緒に目標達成を目指しましょう！',
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: tokens.cornerXLarge(),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  tokens,
                  '匿名ID',
                  'Buddy#${_foundPairId?.substring(0, 4) ?? '????'}',
                ),
                Divider(color: tokens.border, height: 32),
                _buildInfoRow(tokens, '年齢帯', '18-24'),
                Divider(color: tokens.border, height: 32),
                _buildInfoRow(tokens, '目標カテゴリ', 'Fitness'),
              ],
            ),
          ),
          const Spacer(flex: 3),
          MinqPrimaryButton(
            label: '共通クエストを始める',
            onPressed:
                () async =>
                    ref
                        .read(navigationUseCaseProvider)
                        .goHome(), // Navigate to home or quest screen
          ),
          const SizedBox(height: 16),
          MinqSecondaryButton(
            label: '後で開始する',
            onPressed: () async => context.pop(),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildInfoRow(MinqTheme tokens, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        Text(
          value,
          style: tokens.bodyMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: switch (_status) {
            PairMatchingStatus.searching => _buildSearchingUI(context, tokens),
            PairMatchingStatus.matchFound => _buildMatchFoundUI(
              context,
              tokens,
            ),
            PairMatchingStatus.noMatch => _buildNoMatchUI(context, tokens),
            PairMatchingStatus.confirmed => _buildConfirmedUI(context, tokens),
          },
        ),
      ),
    );
  }
}
