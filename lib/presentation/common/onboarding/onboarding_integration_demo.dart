import 'package:flutter/material.dart';
import 'package:minq/presentation/common/onboarding/onboarding.dart';

/// Progressive Onboarding System 縺ｮ邨ｱ蜷医ョ繝｢逕ｻ髱｢
/// 隕∽ｻｶ6.1-6.6縺ｮ螳溯｣・ｒ邨ｱ蜷育噪縺ｫ繝・せ繝医☆繧九◆繧√・繝・Δ
class OnboardingIntegrationDemo extends StatefulWidget {
  const OnboardingIntegrationDemo({super.key});

  @override
  State<OnboardingIntegrationDemo> createState() =>
      _OnboardingIntegrationDemoState();
}

class _OnboardingIntegrationDemoState extends State<OnboardingIntegrationDemo> {
  bool _hasCompletedOnboarding = false;
  int _questCount = 0;
  int _completedQuests = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
    _showInitialOnboarding();
  }

  Future<void> _loadOnboardingState() async {
    final completed = await OnboardingEngine.hasCompletedOnboarding();
    setState(() {
      _hasCompletedOnboarding = completed;
    });
  }

  Future<void> _showInitialOnboarding() async {
    // 蛻晏屓繝ｦ繝ｼ繧ｶ繝ｼ蜷代￠縺ｮ繧ｹ繝・ャ繝励ヰ繧､繧ｹ繝・ャ繝励ぎ繧､繝会ｼ郁ｦ∽ｻｶ6.4・・
    if (!await OnboardingEngine.hasCompletedOnboarding()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startInteractiveTour();
      });
    }
  }

  void _startInteractiveTour() {
    final steps = TourStepBuilder.buildDefaultTour();
    OnboardingEngine.startInteractiveTour(context, steps);
  }

  void _simulateUserProgress() {
    setState(() {
      if (_questCount == 0) {
        _questCount = 1;
      } else if (_completedQuests < _questCount) {
        _completedQuests++;
        _currentStreak++;
      } else {
        _questCount++;
      }
    });

    // 繝ｦ繝ｼ繧ｶ繝ｼ縺ｮ騾ｲ謐励↓蠢懊§縺溘ヲ繝ｳ繝郁｡ｨ遉ｺ・郁ｦ∽ｻｶ6.2・・
    final progress = UserProgress(
      totalQuests: _questCount,
      completedQuests: _completedQuests,
      currentStreak: _currentStreak,
      bestStreak: _currentStreak,
    );
    OnboardingEngine.showProgressiveHint(progress);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progressive Onboarding Demo'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: _startInteractiveTour,
            icon: const Icon(Icons.tour),
            tooltip: '繝・い繝ｼ繧貞・髢・,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 繧ｪ繝ｳ繝懊・繝・ぅ繝ｳ繧ｰ迥ｶ諷玖｡ｨ遉ｺ
            _buildStatusCard(theme),

            const SizedBox(height: 24),

            // 繧ｳ繝ｳ繝・く繧ｹ繝井ｾ晏ｭ倥・繧ｬ繧､繝芽｡ｨ遉ｺ繝・Δ・郁ｦ∽ｻｶ6.1・・
            _buildContextualGuideDemo(theme),

            const SizedBox(height: 24),

            // 繧ｹ繝槭・繝医ヤ繝ｼ繝ｫ繝√ャ繝励ョ繝｢・郁ｦ∽ｻｶ6.2・・
            _buildSmartTooltipDemo(theme),

            const SizedBox(height: 24),

            // 繝励Ο繧ｰ繝ｬ繝・す繝悶ヲ繝ｳ繝医ョ繝｢・郁ｦ∽ｻｶ6.2・・
            _buildProgressiveHintDemo(theme),

            const SizedBox(height: 24),

            // 繧､繝ｳ繧ｿ繝ｩ繧ｯ繝・ぅ繝悶ヤ繧｢繝ｼ繝・Δ・郁ｦ∽ｻｶ6.3・・
            _buildInteractiveTourDemo(theme),
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
              '繧ｯ繧ｨ繧ｹ繝域焚: $_questCount, 螳御ｺ・焚: $_completedQuests, 騾｣邯夊ｨ倬鹸: $_currentStreak',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualGuideDemo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '繧ｳ繝ｳ繝・く繧ｹ繝井ｾ晏ｭ倥ぎ繧､繝・,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '逕ｻ髱｢縺ｫ蠢懊§縺滄←蛻・↑繧ｬ繧､繝峨ｒ陦ｨ遉ｺ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed:
                      () =>
                          OnboardingEngine.showContextualGuide('home', context),
                  child: const Text('繝帙・繝逕ｻ髱｢縺ｸ遘ｻ蜍輔☆繧・),
                ),
                ElevatedButton(
                  onPressed:
                      () => OnboardingEngine.showContextualGuide(
                        'quest_creation',
                        context,
                      ),
                  child: const Text('繧ｯ繧ｨ繧ｹ繝医ｒ菴懈・縺吶ｋ'),
                ),
                ElevatedButton(
                  onPressed:
                      () => OnboardingEngine.showContextualGuide(
                        'stats',
                        context,
                      ),
                  child: const Text('邨ｱ險育判髱｢繧定ｦ九ｋ'),
                ),
                ElevatedButton(
                  onPressed:
                      () =>
                          OnboardingEngine.showContextualGuide('pair', context),
                  child: const Text('繝壹い逕ｻ髱｢縺ｸ遘ｻ蜍輔☆繧・),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartTooltipDemo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '繧ｹ繝槭・繝医ヤ繝ｼ繝ｫ繝√ャ繝・,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '荳蠎ｦ縺縺題｡ｨ遉ｺ縺輔ｌ繧九Θ繝ｼ繧ｶ繝ｼ蝗ｺ譛峨・繝・・繝ｫ繝√ャ繝・,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SmartTooltip(
                  message: '縺薙ｌ縺ｯ髟ｷ謚ｼ縺励〒陦ｨ遉ｺ縺輔ｌ繧九ヤ繝ｼ繝ｫ繝√ャ繝励〒縺吶ゆｸ蠎ｦ陦ｨ遉ｺ縺輔ｌ繧九→谺｡蝗槭・陦ｨ遉ｺ縺輔ｌ縺ｾ縺帙ｓ縲・,
                  tooltipId: 'demo_longpress_tooltip',
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('髟ｷ謚ｼ縺励〒陦ｨ遉ｺ縺吶ｋ'),
                  ),
                ),
                const SizedBox(width: 16),
                SmartTooltip(
                  message: '縺薙ｌ縺ｯ繧ｿ繝・・縺ｧ陦ｨ遉ｺ縺輔ｌ繧九ヤ繝ｼ繝ｫ繝√ャ繝励〒縺吶・,
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
              delay: const Duration(seconds: 2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('2遘貞ｾ後↓閾ｪ蜍輔〒繝・・繝ｫ繝√ャ繝励′陦ｨ遉ｺ縺輔ｌ縺ｾ縺・),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressiveHintDemo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '繝励Ο繧ｰ繝ｬ繝・す繝悶ヲ繝ｳ繝・,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '繝ｦ繝ｼ繧ｶ繝ｼ縺ｮ騾ｲ謐励↓蠢懊§縺溘ヲ繝ｳ繝郁｡ｨ遉ｺ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _simulateUserProgress,
              icon: const Icon(Icons.trending_up),
              label: const Text('騾ｲ謐励ｒ繧ｷ繝溘Η繝ｬ繝ｼ繝・),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveTourDemo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '繧､繝ｳ繧ｿ繝ｩ繧ｯ繝・ぅ繝悶ヤ繧｢繝ｼ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '繧ｹ繝・ャ繝励ヰ繧､繧ｹ繝・ャ繝励・繧ｬ繧､繝峨ヤ繧｢繝ｼ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _startInteractiveTour,
                  icon: const Icon(Icons.tour),
                  label: const Text('繝・ヵ繧ｩ繝ｫ繝医ヤ繧｢繝ｼ'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _startCustomTour(),
                  icon: const Icon(Icons.assistant),
                  label: const Text('繧ｫ繧ｹ繧ｿ繝繝・い繝ｼ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startCustomTour() {
    final customSteps = [
      const TourStep(
        title: '繧ｫ繧ｹ繧ｿ繝繝・い繝ｼ縺ｸ繧医≧縺薙◎',
        description:
            '縺薙ｌ縺ｯ繧ｫ繧ｹ繧ｿ繝槭う繧ｺ縺輔ｌ縺溘ヤ繧｢繝ｼ縺ｮ萓九〒縺吶・
            '繧｢繝励Μ縺ｮ迚ｹ螳壹・讖溯・縺ｫ辟ｦ轤ｹ繧貞ｽ薙※縺溘ぎ繧､繝峨ｒ菴懈・縺ｧ縺阪∪縺吶・,
      ),
      const TourStep(
        title: 'Progressive Onboarding 縺ｮ迚ｹ蠕ｴ',
        description:
            '繧ｳ繝ｳ繝・く繧ｹ繝井ｾ晏ｭ倥・繧ｬ繧､繝芽｡ｨ遉ｺ縺ｫ繧医ｊ縲・
            '繝ｦ繝ｼ繧ｶ繝ｼ縺悟ｿ・ｦ√↑譎ゅ↓蠢・ｦ√↑諠・ｱ縺縺代ｒ謠蝉ｾ帙＠縺ｾ縺吶・,
      ),
      const TourStep(
        title: '繧ｹ繝槭・繝医ヤ繝ｼ繝ｫ繝√ャ繝・,
        description:
            '荳蠎ｦ縺縺題｡ｨ遉ｺ縺輔ｌ繧倶ｻ慕ｵ・∩縺ｫ繧医ｊ縲・
            '繝ｦ繝ｼ繧ｶ繝ｼ繧堤・繧上○繧九％縺ｨ縺ｪ縺城←蛻・↑繧ｿ繧､繝溘Φ繧ｰ縺ｧ繝偵Φ繝医ｒ謠蝉ｾ帙＠縺ｾ縺吶・,
      ),
      const TourStep(
        title: '繝・い繝ｼ螳御ｺ・,
        description:
            'Progressive Onboarding System 縺ｫ繧医ｊ縲・
            '繝ｦ繝ｼ繧ｶ繝ｼ縺ｯ谿ｵ髫守噪縺ｫ繧｢繝励Μ縺ｮ菴ｿ縺・婿繧貞ｭｦ鄙偵〒縺阪∪縺吶・,
      ),
    ];

    OnboardingEngine.startInteractiveTour(context, customSteps);
  }
}
