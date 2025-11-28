import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

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

    _pairingTimer?.cancel();
    _pairingTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _status = PairMatchingStatus.timeout);
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
    try {
      if (widget.code != null) {
        // 招待コードでペアに参加
        pairId = await repo.joinByInvitation(widget.code!, uid);
      } else {
        // ランダムマッチング
        const category = 'Fitness';
        pairId = await repo.requestRandomPair(uid, category);
      }
    } catch (e) {
      // エラー時はマッチング失敗として処理
      pairId = null;
    }

    _pairingTimer?.cancel();

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

  Future<void> _cancelPairing() async {
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

  Future<void> _subscribeToNotifications() async {
    // ... (existing implementation)
  }

  @override
  void dispose() {
    _controller.dispose();
    _pairingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pairAssignmentStreamProvider, (previous, next) {
      next.whenData((doc) {
        if (doc != null && doc.exists) {
          final data = doc.data();
          final pairId = data?['pairId'] as String?;
          if (pairId != null && _status == PairMatchingStatus.searching) {
            _pairingTimer?.cancel();
            setState(() {
              _foundPairId = pairId;
              _status = PairMatchingStatus.matchFound;
            });
          }
        }
      });
    });

    final tokens = MinqTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: tokens.background,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: switch (_status) {
            PairMatchingStatus.searching => _buildSearchingUI(
              context,
              tokens,
              l10n,
            ),
            PairMatchingStatus.matchFound => _buildMatchFoundUI(
              context,
              tokens,
              l10n,
            ),
            PairMatchingStatus.noMatch => _buildNoMatchUI(
              context,
              tokens,
              l10n,
            ),
            PairMatchingStatus.confirmed => _buildConfirmedUI(
              context,
              tokens,
              l10n,
            ),
            PairMatchingStatus.timeout => _buildTimeoutUI(
              context,
              tokens,
              l10n,
            ),
          },
        ),
      ),
    );
  }

  Widget _buildSearchingUI(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
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
              Icon(
                Icons.groups_2_rounded,
                color: tokens.brandPrimary,
                size: 64,
              ),
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
        MinqSecondaryButton(label: l10n.cancel, onPressed: _cancelPairing),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildTimeoutUI(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Padding(
      key: const ValueKey('timeout'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.timer_off_outlined, color: tokens.accentWarning, size: 72),
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

  Widget _buildMatchFoundUI(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Padding(
      key: const ValueKey('matchFound'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.celebration, color: tokens.accentSuccess, size: 72),
          const SizedBox(height: 24),
          Text(
            'マッチング成功！',
            textAlign: TextAlign.center,
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'バディが見つかりました。一緒に習慣を続けていきましょう！',
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          const Spacer(),
          MinqPrimaryButton(
            label: 'ペア画面へ',
            icon: Icons.arrow_forward,
            onPressed: () async {
              if (_foundPairId != null) {
                await _subscribeToNotifications();
                if (context.mounted) {
                  context.go(AppRoutes.pair);
                }
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNoMatchUI(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Padding(
      key: const ValueKey('noMatch'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.search_off, color: tokens.textMuted, size: 72),
          const SizedBox(height: 24),
          Text(
            'マッチングできませんでした',
            textAlign: TextAlign.center,
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '現在マッチング可能なバディがいません。時間をおいて再度お試しください。',
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

  Widget _buildConfirmedUI(
    BuildContext context,
    MinqTheme tokens,
    AppLocalizations l10n,
  ) {
    return Padding(
      key: const ValueKey('confirmed'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(Icons.check_circle, color: tokens.accentSuccess, size: 72),
          const SizedBox(height: 24),
          Text(
            'ペアリング完了',
            textAlign: TextAlign.center,
            style: tokens.titleLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'バディとのペアリングが完了しました。',
            textAlign: TextAlign.center,
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          const Spacer(),
          MinqPrimaryButton(
            label: 'ペア画面へ',
            icon: Icons.arrow_forward,
            onPressed: () async {
              context.go(AppRoutes.pair);
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
