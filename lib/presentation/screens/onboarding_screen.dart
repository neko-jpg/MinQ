import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/effects/minq_resonance_burst.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _showBurst = false;

  void _triggerBurst() {
    setState(() => _showBurst = true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading:
            Navigator.canPop(context)
                ? BackButton(color: tokens.textPrimary)
                : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing(4),
                    ).copyWith(
                      top: tokens.spacing(8),
                      bottom: tokens.spacing(4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: tokens.spacing(4)),
                        GestureDetector(
                          onTap: _triggerBurst,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: tokens.brandPrimary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              boxShadow: tokens.shadowSoft,
                            ),
                            child: Icon(
                              Icons.touch_app_rounded,
                              color: tokens.brandPrimary,
                              size: 64,
                            ),
                          ),
                        ),
                        SizedBox(height: tokens.spacing(4)),
                        Text(
                          'タップして\n「達成感」を体験',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: tokens.brandPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: tokens.spacing(6)),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: tokens.textPrimary,
                            ),
                            children: const [TextSpan(text: 'MinQへようこそ')],
                          ),
                        ),
                        SizedBox(height: tokens.spacing(4)),
                        Text(
                          'ミニクエストと匿名サポートを通じて、最小限の努力で習慣を築きましょう。',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                        SizedBox(height: tokens.spacing(8)),
                        const _FeatureCard(
                          icon: Icons.bolt,
                          title: '3タップで習慣化',
                          description: '新しい習慣をたった3タップで始められます。とてもシンプルです。',
                        ),
                        SizedBox(height: tokens.spacing(4)),
                        const _FeatureCard(
                          icon: Icons.groups,
                          title: '匿名ペア',
                          description: 'パートナーから、匿名で説明責任とサポートを得られます。',
                        ),
                        SizedBox(height: tokens.spacing(4)),
                        const _FeatureCard(
                          icon: Icons.psychology,
                          title: 'Habit DNA',
                          description: 'あなたの習慣タイプを分析し、最適な行動パターンを提案します。',
                        ),
                        SizedBox(height: tokens.spacing(5)),
                      ],
                    ),
                  ),
                ),
                _BottomNavigation(textTheme: textTheme),
              ],
            ),
            if (_showBurst)
              Positioned.fill(
                child: MinqResonanceBurst(
                  onComplete: () => setState(() => _showBurst = false),
                ),
              ),
          ],
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

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tokens.brandPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tokens.brandPrimary),
            ),
            SizedBox(width: tokens.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tokens.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: tokens.intimateSpace),
                  Text(
                    description,
                    style: tokens.bodyMedium.copyWith(
                      color: tokens.textSecondary,
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
  const _BottomNavigation({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
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
                backgroundColor: tokens.brandPrimary,
                foregroundColor: tokens.ensureAccessibleOnBackground(
                  tokens.textPrimary,
                  tokens.brandPrimary,
                ),
                padding: EdgeInsets.symmetric(vertical: tokens.spacing(3)),
                textStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.cornerLarge(),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('すでにアカウントをお持ちですか？', style: textTheme.bodySmall),
              TextButton(
                onPressed:
                    () => ref.read(navigationUseCaseProvider).goToLogin(),
                child: Text(
                  'ログイン',
                  style: textTheme.bodySmall?.copyWith(
                    color: tokens.brandPrimary,
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
