import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum PairMatchingStatus { searching, matchFound, noMatch, confirmed, timeout }

class PairMatchingScreen extends ConsumerStatefulWidget {
  const PairMatchingScreen({super.key, this.code});
  final String? code;

  @override
  ConsumerState<PairMatchingScreen> createState() => _PairMatchingScreenState();
}

class _PairMatchingScreenState extends ConsumerState<PairMatchingScreen>
    with TickerProviderStateMixin {
  PairMatchingStatus _status = PairMatchingStatus.searching;
  late final AnimationController _controller;
  String? _foundPairId;
  Timer? _pairingTimer;
  Future<Pair?>? _pairPreviewFuture;
  bool _hasShownMatchToast = false;
  bool _hasShownFailure = false;
  bool _hasSubscribedToPair = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => _startPairing());
  }

  void _startPairing() {
    setState(() {
      _status = PairMatchingStatus.searching;
    });

    _hasShownFailure = false;
    _hasShownMatchToast = false;
    _hasSubscribedToPair = false;

    _pairingTimer?.cancel();
    _pairingTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _status = PairMatchingStatus.timeout);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          FeedbackMessenger.showErrorSnackBar(
            context,
            '一定時間内にマッチングできませんでした。',
            actionLabel: '再試行',
            onAction: _startPairing,
          );
          FeedbackManager.warning();
        });
      }
    });

    _executePairingLogic();
  }

  Future<void> _executePairingLogic() async {
    final repo = ref.read(pairRepositoryProvider);
    final uid = ref.read(uidProvider);
    if (repo == null || uid == null) {
      if (mounted) setState(() => _status = PairMatchingStatus.noMatch);
      _pairingTimer?.cancel();
      return;
    }

    String? pairId;
    if (widget.code != null) {
      // pairId = await repo.joinPairWithCode(uid, widget.code!);
      pairId = 'mock_pair_id_from_code'; // Placeholder
    } else {
      const category = 'Fitness';
      pairId = await repo.requestRandomPair(uid, category);
    }

    _pairingTimer?.cancel();

    if (mounted) {
      setState(() {
        if (pairId != null) {
          _foundPairId = pairId;
          _pairPreviewFuture = repo.getPairById(pairId);
          _status = PairMatchingStatus.matchFound;
        } else {
          _pairPreviewFuture = null;
          _status = PairMatchingStatus.noMatch;
        }
      });

      if (pairId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          if (!_hasShownMatchToast) {
            FeedbackMessenger.showSuccessToast(
              context,
              'バディが見つかりました！',
            );
            await FeedbackManager.achievementUnlocked();
            _hasShownMatchToast = true;
          }
          if (!_hasSubscribedToPair) {
            await _subscribeToNotifications(pairId);
            _hasSubscribedToPair = true;
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _hasShownFailure) return;
          FeedbackMessenger.showErrorSnackBar(
            context,
            '現在マッチングできませんでした。',
            actionLabel: '再試行する',
            onAction: _startPairing,
          );
          _hasShownFailure = true;
        });
      }
    }
  }

  void _cancelPairing() {
    _pairingTimer?.cancel();
    final repo = ref.read(pairRepositoryProvider);
    final uid = ref.read(uidProvider);
    // TODO: Implement cancellation on the backend if a request was sent
    // if (uid != null && repo != null) {
    //   repo.cancelPairingRequest(uid);
    // }
    if (context.canPop()) {
      context.pop();
    }
  }

  Future<void> _subscribeToNotifications(String pairId) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      await messaging.subscribeToTopic('pair_$pairId');

      final uid = ref.read(uidProvider);
      if (uid != null) {
        await messaging.subscribeToTopic('user_$uid');
      }

      await ref.read(notificationServiceProvider).init();
    } catch (error, stackTrace) {
      debugPrint('Failed to subscribe to pair notifications: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pairingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: tokens.background,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: switch (_status) {
            PairMatchingStatus.searching => _buildSearchingUI(context, tokens, l10n),
            PairMatchingStatus.matchFound =>
                _buildMatchFoundUI(context, tokens, l10n),
            PairMatchingStatus.noMatch =>
                _buildNoMatchUI(context, tokens, l10n),
            PairMatchingStatus.confirmed =>
                _buildConfirmedUI(context, tokens, l10n),
            PairMatchingStatus.timeout => _buildTimeoutUI(context, tokens, l10n),
          },
        ),
      ),
    );
  }

  Widget _buildSearchingUI(BuildContext context, MinqTheme tokens, AppLocalizations l10n) {
    return Column(
      key: const ValueKey('searching'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        SizedBox(
          width: 192,
          height: 192,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 192,
                  height: 192,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        tokens.brandPrimary.withOpacity(0.1),
                        tokens.brandPrimary,
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Icon(Icons.groups_2_rounded, color: tokens.brandPrimary, size: 64),
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
          label: l10n.cancel,
          onPressed: _cancelPairing,
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildTimeoutUI(BuildContext context, MinqTheme tokens, AppLocalizations l10n) {
    return Padding(
      key: const ValueKey('timeout'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(
            Icons.timer_off_outlined,
            color: tokens.accentWarning,
            size: 72,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.pairMatchingTimeoutTitle,
            textAlign: TextAlign.center,
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.pairMatchingTimeoutMessage,
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          const Spacer(),
          MinqPrimaryButton(
            label: l10n.retry,
            icon: Icons.refresh,
            onPressed: _startPairing,
          ),
          const SizedBox(height: 16),
          MinqTextButton(
            label: l10n.cancel,
            onTap: () async {
              context.pop();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMatchFoundUI(BuildContext context, MinqTheme tokens, AppLocalizations l10n) {
    final pairId = _foundPairId;

    return Padding(
      key: const ValueKey('matchFound'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.emoji_events, color: tokens.brandPrimary, size: 72),
          const SizedBox(height: 24),
          Text(
            'バディが見つかりました！',
            textAlign: TextAlign.center,
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '相手に挨拶を送り、目標を共有しましょう。',
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 24),
          Card(
            color: tokens.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: FutureBuilder<Pair?>(
                future: _pairPreviewFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 72,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ペア情報を取得できませんでした',
                          style: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'しばらくしてからもう一度お試しください。',
                          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                        ),
                      ],
                    );
                  }

                  final pair = snapshot.data!;
                  final joinedAt = pair.createdAt;
                  final formattedDate =
                      '${joinedAt.year}/${joinedAt.month.toString().padLeft(2, '0')}/${joinedAt.day.toString().padLeft(2, '0')}';
                  final partnerCount = pair.members.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(tokens, 'カテゴリ', pair.category),
                      SizedBox(height: tokens.spacing(2)),
                      _buildInfoRow(tokens, 'メンバー数', '$partnerCount'),
                      SizedBox(height: tokens.spacing(2)),
                      _buildInfoRow(tokens, 'ペア作成日', formattedDate),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          MinqPrimaryButton(
            label: 'チャットを開く',
            icon: Icons.chat_bubble_outline,
            onPressed: () async {
              FeedbackManager.selected();
              ref.read(navigationUseCaseProvider).goToPair();
            },
          ),
          const SizedBox(height: 12),
          MinqSecondaryButton(
            label: 'ホームに戻る',
            icon: Icons.home_outlined,
            onPressed: () async {
              FeedbackManager.selected();
              ref.read(navigationUseCaseProvider).goHome();
            },
          ),
          const Spacer(),
          if (pairId != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'ペアID: $pairId',
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoMatchUI(BuildContext context, MinqTheme tokens, AppLocalizations l10n) {
    return Padding(
      key: const ValueKey('noMatch'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.sentiment_dissatisfied, size: 72, color: tokens.textMuted),
          const SizedBox(height: 24),
          Text(
            '現在マッチング中のユーザーが見つかりませんでした',
            textAlign: TextAlign.center,
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '数分後に再試行するか、招待コードで参加してみましょう。',
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          const Spacer(),
          MinqPrimaryButton(
            label: 'もう一度探す',
            icon: Icons.refresh,
            onPressed: () async {
              FeedbackManager.buttonPressed();
              _startPairing();
            },
          ),
          const SizedBox(height: 12),
          MinqTextButton(
            label: 'ホームに戻る',
            onPressed: () async {
              FeedbackManager.selected();
              ref.read(navigationUseCaseProvider).goHome();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildConfirmedUI(BuildContext context, MinqTheme tokens, AppLocalizations l10n) {
    return Padding(
      key: const ValueKey('confirmed'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.verified_rounded, color: tokens.brandPrimary, size: 72),
          const SizedBox(height: 24),
          Text(
            'マッチングを確定しました',
            textAlign: TextAlign.center,
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ペアチャットで自己紹介を送り、目標や活動時間を共有しましょう。',
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          const Spacer(),
          MinqPrimaryButton(
            label: 'ペアチャットを開く',
            icon: Icons.message_outlined,
            onPressed: () async {
              FeedbackManager.buttonPressed();
              ref.read(navigationUseCaseProvider).goToPair();
            },
          ),
          const SizedBox(height: 12),
          MinqSecondaryButton(
            label: l10n.cancel,
            icon: Icons.close,
            onPressed: () async {
              FeedbackManager.selected();
              if (context.mounted) {
                context.pop();
              }
            },
          ),
          const SizedBox(height: 24),
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
}