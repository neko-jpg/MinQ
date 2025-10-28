import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: MinqTokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? BackButton(color: MinqTokens.textPrimary)
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: MinqTokens.spacing(4),
                ).copyWith(
                    top: MinqTokens.spacing(6), bottom: MinqTokens.spacing(3)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MinqTokens.spacing(6)),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: MinqTokens.brandPrimary.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.checklist,
                        color: MinqTokens.brandPrimary,
                        size: 56,
                      ),
                    ),
                    SizedBox(height: MinqTokens.spacing(4)),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: MinqTokens.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MinqTokens.textPrimary,
                        ),
                        children: const [TextSpan(text: 'MinQへようこそ')],
                      ),
                    ),
                    SizedBox(height: MinqTokens.spacing(3)),
                    Text(
                      'ミニクエストと匿名サポートを通じて、最小限の努力で習慣を築きましょう。',
                      textAlign: TextAlign.center,
                      style: MinqTokens.bodyLarge.copyWith(
                        color: MinqTokens.textSecondary,
                      ),
                    ),
                    SizedBox(height: MinqTokens.spacing(6)),
                    _FeatureCard(
                      icon: Icons.touch_app,
                      title: '3タップで習慣化',
                      description: '新しい習慣をたった3タップで始められます。とてもシンプルです。',
                    ),
                    SizedBox(height: MinqTokens.spacing(3)),
                    _FeatureCard(
                      icon: Icons.groups,
                      title: '匿名ペア',
                      description: 'パートナーから、匿名で説明責任とサポートを得られます。',
                    ),
                    SizedBox(height: MinqTokens.spacing(3)),
                    _FeatureCard(
                      icon: Icons.explore,
                      title: 'ミニクエスト',
                      description: 'あなたの目標を、達成感のある小さなクエストに変えましょう。',
                    ),
                    SizedBox(height: MinqTokens.spacing(4)),
                  ],
                ),
              ),
            ),
            _BottomNavigation(),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: MinqTokens.surface,
      shape:
          RoundedRectangleBorder(borderRadius: MinqTokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MinqTokens.brandPrimary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: MinqTokens.brandPrimary),
            ),
            SizedBox(width: MinqTokens.spacing(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MinqTokens.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MinqTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: MinqTokens.spacing(1)),
                  Text(
                    description,
                    style: MinqTokens.bodyMedium.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigation extends ConsumerWidget {
  _BottomNavigation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(top: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => ref.read(navigationUseCaseProvider).goToLogin(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('始める'),
              style: FilledButton.styleFrom(
                backgroundColor: MinqTokens.brandPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: MinqTokens.spacing(3)),
                textStyle: MinqTokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: MinqTokens.cornerLarge(),
                ),
              ),
            ),
          ),
          SizedBox(height: MinqTokens.spacing(3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('すでにアカウントをお持ちですか？', style: MinqTokens.bodySmall),
              TextButton(
                onPressed:
                    () => ref.read(navigationUseCaseProvider).goToLogin(),
                child: Text(
                  'ログイン',
                  style: MinqTokens.bodySmall.copyWith(
                    color: MinqTokens.brandPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
