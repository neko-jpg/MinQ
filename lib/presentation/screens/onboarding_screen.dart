import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final navigation = ref.read(navigationUseCaseProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          Positioned.fill(child: _OnboardingBackground(tokens: tokens)),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.lg,
                  vertical: tokens.spacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: navigation.goToLogin,
                        child: const Text('ログインへ'),
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xl),
                    Text(
                      'あなたの毎日を\nクエストに変えよう',
                      style: tokens.typography.h2.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.md),
                    Text(
                      'MinQは、続けたい習慣を冒険のように楽しめる'
                      'タスク管理アプリです。',
                      style: tokens.typography.bodyLarge.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xl),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: const [
                          _FeatureCard(
                            icon: Icons.auto_graph,
                            title: '1日3分のクエスト設計',
                            description:
                                'タスクを小さなクエストに分割し、達成感を'
                                '積み上げられます。',
                          ),
                          _FeatureCard(
                            icon: Icons.groups_outlined,
                            title: '仲間と励まし合えるギルド',
                            description:
                                '同じ目標を持つ仲間と進捗を共有し、'
                                'モチベーションを保てます。',
                          ),
                          _FeatureCard(
                            icon: Icons.psychology_alt_outlined,
                            title: 'AIコーチが24時間サポート',
                            description:
                                'オフラインでも使えるAIが、次に取り組むべき'
                                'クエストを提案します。',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: tokens.spacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: navigation.goToLogin,
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.brandPrimary,
                          padding: EdgeInsets.symmetric(
                            vertical: tokens.spacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              tokens.radius.lg,
                            ),
                          ),
                        ),
                        child: Text(
                          '始めてみる',
                          style: tokens.typography.button.copyWith(
                            color: tokens.primaryForeground,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    Center(
                      child: TextButton(
                        onPressed: navigation.goToLogin,
                        child: const Text('すでにアカウントがあります'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tokens.background, tokens.surfaceAlt],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(32),
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(180),
            color: tokens.accentSecondary.withOpacity(0.08),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: tokens.shadow.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.brandPrimary.withOpacity(0.12),
            ),
            child: Icon(icon, color: tokens.brandPrimary),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tokens.typography.h4.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  description,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
