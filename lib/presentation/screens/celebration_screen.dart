import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CelebrationScreen extends ConsumerStatefulWidget {
  const CelebrationScreen({super.key});

  @override
  ConsumerState<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends ConsumerState<CelebrationScreen> with TickerProviderStateMixin {
  late final AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final streak = ref.watch(streakProvider).asData?.value ?? 0;
    final longestStreak = ref.watch(longestStreakProvider).asData?.value ?? 0;
    final isLongestStreak = streak > 0 && streak >= longestStreak;

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              const Spacer(flex: 2),
              _buildCelebrationContent(tokens, isLongestStreak, streak),
              const Spacer(),
              _buildRewardCard(tokens),
              const Spacer(),
              _buildDoneButton(context, tokens),
            ],
          ),
          _buildCloseButton(context, tokens),
        ],
      ),
    );
  }

  Widget _buildCelebrationContent(MinqTheme tokens, bool isLongest, int streak) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 288,
            height: 288,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _PingAnimation(controller: _pingController, isLongest: isLongest),
                Text(isLongest ? '🏆' : '🎉', style: const TextStyle(fontSize: 72)),
              ],
            ),
          ),
          SizedBox(height: tokens.spacing(4)),
          Text(
            isLongest ? 'New Longest Streak!' : 'Day $streak Streak!',
            style: tokens.displaySmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            isLongest ? 'You set a new personal best!' : 'You\'re on a roll! Keep it up.',
            style: tokens.bodyLarge.copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: tokens.spacing(2)),
            child: Text('Your Reward', style: tokens.titleSmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: tokens.spacing(3)),
          Material(
            color: tokens.brandPrimary.withOpacity(0.1),
            borderRadius: tokens.cornerLarge(),
            child: InkWell(
              onTap: () { /* TODO: Implement reward action */ },
              borderRadius: tokens.cornerLarge(),
              child: Container(
                padding: EdgeInsets.all(tokens.spacing(4)),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: tokens.spacing(14),
                      height: tokens.spacing(14),
                      decoration: BoxDecoration(
                        color: tokens.brandPrimary.withOpacity(0.2),
                        borderRadius: tokens.cornerLarge(),
                      ),
                      child: Icon(Icons.self_improvement, color: tokens.brandPrimary, size: tokens.spacing(8)),
                    ),
                    SizedBox(width: tokens.spacing(4)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('1-Min Breathing Exercise', style: tokens.titleSmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
                          SizedBox(height: tokens.spacing(1)),
                          Text('Relax and recenter', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: tokens.spacing(4), color: tokens.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context, MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.fromLTRB(tokens.spacing(4), tokens.spacing(4), tokens.spacing(4), tokens.spacing(6)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.go('/home'),
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.brandPrimary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: tokens.spacing(4)),
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerFull()),
          ),
          child: Text('Done', style: tokens.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context, MinqTheme tokens) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: tokens.spacing(2),
      child: IconButton(
        icon: Container(
          width: tokens.spacing(12),
          height: tokens.spacing(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            backgroundBlendMode: BlendMode.overlay,
          ),
          child: const Icon(Icons.close, color: Colors.white),
        ),
        onPressed: () => context.go('/home'),
      ),
    );
  }
}

class _PingAnimation extends AnimatedWidget {
  final AnimationController controller;
  final bool isLongest;

  const _PingAnimation({required this.controller, this.isLongest = false}) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    final color = isLongest ? Colors.amber.shade400 : tokens.brandPrimary;

    return Opacity(
      opacity: 1.0 - animation.value,
      child: Container(
        width: 288 * animation.value,
        height: 288 * animation.value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.3),
        ),
      ),
    );
  }
}