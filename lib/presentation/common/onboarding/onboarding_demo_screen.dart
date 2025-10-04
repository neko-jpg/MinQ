import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ繧ｷ繧ｹ繝・Β縺ｮ繝・Δ逕ｻ髱｢
class OnboardingDemoScreen extends StatefulWidget {
  const OnboardingDemoScreen({super.key});

  @override
  State<OnboardingDemoScreen> createState() => _OnboardingDemoScreenState();
}

class _OnboardingDemoScreenState extends State<OnboardingDemoScreen> {
  bool _hasCompletedOnboarding = false;
  int _currentStep = 0;
  final List<String> _viewedTooltips = [];

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final completed = await OnboardingEngine.hasCompletedOnboarding();
    final step = await OnboardingEngine.getCurrentStep();

    setState(() {
      _hasCompletedOnboarding = completed;
      _currentStep = step;
    });
  }

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadOnboardingState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ迥ｶ諷九ｒ繝ｪ繧ｻ繝・ヨ縺励∪縺励◆'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startInteractiveTour() {
    final steps = TourStepBuilder.buildDefaultTour();
    OnboardingEngine.startInteractiveTour(context, steps);
  }

  void _showContextualGuide(String screenId) {
    OnboardingEngine.showContextualGuide(screenId, context);
  }

  void _showProgressiveHint() {
    const progress = UserProgress(
      totalQuests: 0,
      completedQuests: 0,
      currentStreak: 0,
      bestStreak: 0,
    );
    OnboardingEngine.showProgressiveHint(progress);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ繧ｷ繧ｹ繝・Β 繝・Δ'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _resetOnboarding,
            icon: const Icon(Icons.refresh),
            tooltip: '繝ｪ繧ｻ繝・ヨ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 迥ｶ諷玖｡ｨ遉ｺ
            _buildStatusCard(theme),

            const SizedBox(height: 24),

            // 繧､繝ｳ繧ｿ繝ｩ繧ｯ繝・ぅ繝悶ヤ繧｢繝ｼ
            _buildSectionCard(theme, '繧､繝ｳ繧ｿ繝ｩ繧ｯ繝・ぅ繝悶ヤ繧｢繝ｼ', '繧ｹ繝・ャ繝励ヰ繧､繧ｹ繝・ャ繝励・繧ｬ繧､繝峨ヤ繧｢繝ｼ', [
              ElevatedButton.icon(
                onPressed: _startInteractiveTour,
                icon: const Icon(Icons.tour),
                label: const Text('繝・い繝ｼ繧帝幕蟋・),
              ),
            ]),

            const SizedBox(height: 16),

            // 繧ｳ繝ｳ繝・く繧ｹ繝井ｾ晏ｭ倥ぎ繧､繝・
            _buildSectionCard(theme, '繧ｳ繝ｳ繝・く繧ｹ繝井ｾ晏ｭ倥ぎ繧､繝・, '逕ｻ髱｢縺ｫ蠢懊§縺溘ぎ繧､繝峨ｒ陦ｨ遉ｺ', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => _showContextualGuide('home'),
                    child: const Text('繝帙・繝縺ｸ遘ｻ蜍輔☆繧・),
                  ),
                  ElevatedButton(
                    onPressed: () => _showContextualGuide('quest_creation'),
                    child: const Text('繧ｯ繧ｨ繧ｹ繝医ｒ菴懈・縺吶ｋ'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showContextualGuide('stats'),
                    child: const Text('邨ｱ險医ｒ隕九ｋ'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showContextualGuide('pair'),
                    child: const Text('繝壹い繧呈爾縺・),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: 16),

            // 繧ｹ繝槭・繝医ヤ繝ｼ繝ｫ繝√ャ繝・
            _buildSectionCard(theme, '繧ｹ繝槭・繝医ヤ繝ｼ繝ｫ繝√ャ繝・, '荳蠎ｦ縺縺題｡ｨ遉ｺ縺輔ｌ繧九ヤ繝ｼ繝ｫ繝√ャ繝・, [
              Row(
                children: [
                  SmartTooltip(
                    message: '縺薙ｌ縺ｯ髟ｷ謚ｼ縺励〒陦ｨ遉ｺ縺輔ｌ繧九ヤ繝ｼ繝ｫ繝√ャ繝励〒縺・,
                    tooltipId: 'demo_longpress_tooltip',
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('髟ｷ謚ｼ縺励〒陦ｨ遉ｺ縺吶ｋ'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SmartTooltip(
                    message: '縺薙ｌ縺ｯ繧ｿ繝・・縺ｧ陦ｨ遉ｺ縺輔ｌ繧九ヤ繝ｼ繝ｫ繝√ャ繝励〒縺・,
                    tooltipId: 'demo_tap_tooltip',
                    trigger: TooltipTrigger.tap,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('繧ｿ繝・・縺ｧ陦ｨ遉ｺ縺吶ｋ'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AutoSmartTooltip(
                message: '閾ｪ蜍戊｡ｨ遉ｺ縺輔ｌ繧九ヤ繝ｼ繝ｫ繝√ャ繝・,
                tooltipId: 'demo_auto_tooltip',
                delay: const Duration(seconds: 1),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('閾ｪ蜍輔ヤ繝ｼ繝ｫ繝√ャ繝嶺ｻ倥″繧ｳ繝ｳ繝・リ'),
                ),
              ),
            ]),

            _buildSectionCard(theme, '繝励Ο繧ｰ繝ｬ繝・す繝悶ヲ繝ｳ繝・, '繝ｦ繝ｼ繧ｶ繝ｼ縺ｮ騾ｲ謐励↓蠢懊§縺溘ヲ繝ｳ繝・, [
              ElevatedButton.icon(
                onPressed: _showProgressiveHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('繝偵Φ繝医ｒ陦ｨ遉ｺ縺吶ｋ'),
              ),
            ]),

            const SizedBox(height: 16),

            // 繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ繧ｪ繝ｼ繝舌・繝ｬ繧､
            _buildSectionCard(theme, '繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ繧ｪ繝ｼ繝舌・繝ｬ繧､', '繧ｫ繧ｹ繧ｿ繝繧ｪ繝ｼ繝舌・繝ｬ繧､繧ｬ繧､繝・, [
              ElevatedButton.icon(
                onPressed: () => _showCustomOverlay(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('繧ｪ繝ｼ繝舌・繝ｬ繧､繧定｡ｨ遉ｺ縺吶ｋ'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showStepByStepGuide(context),
                icon: const Icon(Icons.assistant),
                label: const Text('繧ｬ繧､繝峨ｒ髢句ｧ九☆繧・),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ迥ｶ諷・,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _hasCompletedOnboarding
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _hasCompletedOnboarding ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _hasCompletedOnboarding ? '螳御ｺ・ｸ医∩' : '譛ｪ螳御ｺ・,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '迴ｾ蝨ｨ縺ｮ繧ｹ繝・ャ繝・ $_currentStep',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme,
    String title,
    String description,
    List<Widget> actions,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ...actions,
          ],
        ),
      ),
    );
  }

  void _showCustomOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => OnboardingOverlay(
            title: '繧ｫ繧ｹ繧ｿ繝繧ｪ繝ｼ繝舌・繝ｬ繧､',
            description:
                '縺薙ｌ縺ｯ繧ｫ繧ｹ繧ｿ繝繧ｪ繝ｼ繝舌・繝ｬ繧､縺ｮ萓九〒縺吶・
                '繝ｦ繝ｼ繧ｶ繝ｼ縺ｫ驥崎ｦ√↑諠・ｱ繧剃ｼ昴∴繧九◆繧√↓菴ｿ逕ｨ縺ｧ縺阪∪縺吶・,
            onDismiss: () => Navigator.of(context).pop(),
            customContent: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('繧ｫ繧ｹ繧ｿ繝繧ｳ繝ｳ繝・Φ繝・ｒ霑ｽ蜉縺ｧ縺阪∪縺・)),
                ],
              ),
            ),
          ),
    );
  }

  void _showStepByStepGuide(BuildContext context) {
    final steps = [
      const GuideStep(
        title: '繧ｹ繝・ャ繝・1',
        description: '縺薙ｌ縺ｯ譛蛻昴・繧ｹ繝・ャ繝励〒縺吶ょ渕譛ｬ逧・↑謫堺ｽ懊ｒ隱ｬ譏弱＠縺ｾ縺吶・,
      ),
      const GuideStep(
        title: '繧ｹ繝・ャ繝・2',
        description: '縺薙ｌ縺ｯ2逡ｪ逶ｮ縺ｮ繧ｹ繝・ャ繝励〒縺吶ゅｈ繧願ｩｳ邏ｰ縺ｪ讖溯・繧定ｪｬ譏弱＠縺ｾ縺吶・,
      ),
      const GuideStep(
        title: '繧ｹ繝・ャ繝・3',
        description: '縺薙ｌ縺ｯ譛蠕後・繧ｹ繝・ャ繝励〒縺吶るｫ伜ｺｦ縺ｪ讖溯・繧定ｪｬ譏弱＠縺ｾ縺吶・,
      ),
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StepByStepOverlay(
            steps: steps,
            onComplete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('繧ｹ繝・ャ繝励ヰ繧､繧ｹ繝・ャ繝励ぎ繧､繝峨′螳御ｺ・＠縺ｾ縺励◆・・),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
    );
  }
}
