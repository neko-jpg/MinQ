import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
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
    final tokens = MinqTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: tokens.background,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: switch (_status) {
            PairMatchingStatus.searching => _buildSearchingUI(context, tokens, l10n),
            PairMatchingStatus.matchFound => _buildMatchFoundUI(context, tokens, l10n),
            PairMatchingStatus.noMatch => _buildNoMatchUI(context, tokens, l10n),
            PairMatchingStatus.confirmed => _buildConfirmedUI(context, tokens, l10n),
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
                        tokens.brandPrimary.withValues(alpha: 0.1),
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
          '繝舌ョ繧｣繧呈爾縺励※縺・∪縺吮ｦ',
          style: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            '縺ゅ↑縺溘・繝励Λ繧､繝舌す繝ｼ縺ｯ菫晁ｭｷ縺輔ｌ縺ｦ縺・∪縺吶ら嶌謇九↓縺ｯ縺ゅ↑縺溘・蟷ｴ鮨｢螻､縺ｨ逶ｮ讓吶き繝・ざ繝ｪ縺ｮ縺ｿ縺悟・譛峨＆繧後∪縺吶・,
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
    return const Padding(
      key: ValueKey('matchFound'),
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ... (existing implementation, can be localized later if needed)
        ],
      ),
    );
  }

  Widget _buildNoMatchUI(BuildContext context, MinqTheme tokens, AppLocalizations l10n) {
    return const Padding(
      key: ValueKey('noMatch'),
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ... (existing implementation, can be localized later if needed)
        ],
      ),
    );
  }

  Widget _buildConfirmedUI(BuildContext context, MinqTheme tokens, AppLocalizations l10n) {
    return const Padding(
      key: ValueKey('confirmed'),
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ... (existing implementation, can be localized later if needed)
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