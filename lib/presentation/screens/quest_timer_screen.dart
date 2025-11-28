import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/ai/ai_integration_manager.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
import 'package:minq/presentation/controllers/quest_log_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/ai_coach_overlay.dart';
import 'package:minq/presentation/widgets/badge_notification_widget.dart';

/// クエストタイマー画面
/// タイマーとストップウォッチの両方の機能を提供
class QuestTimerScreen extends ConsumerStatefulWidget {
  const QuestTimerScreen({
    super.key,
    required this.questId,
    this.initialMode = TimerMode.timer,
  });

  final int questId;
  final TimerMode initialMode;

  @override
  ConsumerState<QuestTimerScreen> createState() => _QuestTimerScreenState();
}

class _QuestTimerScreenState extends ConsumerState<QuestTimerScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _pulseController;
  late AnimationController _completionController;

  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  Duration _targetDuration = const Duration(minutes: 25); // デフォルト25分
  bool _isRunning = false;
  bool _isPaused = false;
  TimerMode _currentMode = TimerMode.timer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _pageController = PageController(initialPage: _currentMode.index);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // クエスト情報を取得して推定時間を設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestInfo();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _loadQuestInfo() async {
    final quest = await ref.read(questByIdProvider(widget.questId).future);
    if (quest != null && quest.estimatedMinutes > 0) {
      setState(() {
        _targetDuration = Duration(minutes: quest.estimatedMinutes);
      });
    }
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _startTime = DateTime.now();
    });

    _pulseController.repeat(reverse: true);

    // AIコーチング開始
    _startAICoaching();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentMode == TimerMode.timer) {
          // タイマーモード: カウントダウン
          if (_currentDuration < _targetDuration) {
            _currentDuration += const Duration(seconds: 1);
          } else {
            _completeTimer();
          }
        } else {
          // ストップウォッチモード: カウントアップ
          _currentDuration += const Duration(seconds: 1);
        }
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning || _isPaused) return;

    setState(() {
      _isPaused = true;
    });

    _timer?.cancel();
    _pulseController.stop();

    // AIコーチング停止
    _stopAICoaching();
  }

  void _resumeTimer() {
    if (!_isRunning || !_isPaused) return;

    setState(() {
      _isPaused = false;
    });

    _pulseController.repeat(reverse: true);

    // AIコーチング再開
    _startAICoaching();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentMode == TimerMode.timer) {
          if (_currentDuration < _targetDuration) {
            _currentDuration += const Duration(seconds: 1);
          } else {
            _completeTimer();
          }
        } else {
          _currentDuration += const Duration(seconds: 1);
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _stopAICoaching();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _currentDuration = Duration.zero;
      _startTime = null;
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _stopAICoaching();

    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    // 完了アニメーション
    _completionController.forward();

    // 触覚フィードバック
    HapticFeedback.heavyImpact();

    // 完了処理
    _handleCompletion();
  }

  void _handleCompletion() async {
    final quest = await ref.read(questByIdProvider(widget.questId).future);
    if (quest == null) return;

    // クエストログに記録
    final success = await ref
        .read(questLogControllerProvider.notifier)
        .recordProgress(widget.questId);

    if (success && mounted) {
      // 成功通知
      FeedbackMessenger.showSuccessToast(context, '${quest.title}を完了しました！');

      // 祝福画面に遷移
      context.push(AppRoutes.celebration);
    }
  }

  void _startAICoaching() async {
    final quest = await ref.read(questByIdProvider(widget.questId).future);
    if (quest == null) return;

    try {
      final aiManager = ref.read(aiIntegrationManagerProvider);
      await aiManager.startRealtimeCoaching(
        questId: widget.questId.toString(),
        questTitle: quest.title,
        estimatedDuration: _targetDuration,
      );
    } catch (e) {
      // AIコーチングエラーは無視
    }
  }

  void _stopAICoaching() async {
    try {
      final aiManager = ref.read(aiIntegrationManagerProvider);
      await aiManager.stopRealtimeCoaching();
    } catch (e) {
      // AIコーチングエラーは無視
    }
  }

  void _switchMode(TimerMode mode) {
    if (_isRunning) return; // 実行中は切り替え不可

    setState(() {
      _currentMode = mode;
      _currentDuration = Duration.zero;
    });

    _pageController.animateToPage(
      mode.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final questAsync = ref.watch(questByIdProvider(widget.questId));

    return AICoachOverlay(
      questId: widget.questId.toString(),
      child: Scaffold(
        backgroundColor: tokens.background,
        appBar: AppBar(
          title: questAsync.when(
            data:
                (quest) => Text(
                  quest?.title ?? 'クエスト',
                  style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
                ),
            loading: () => const Text('読み込み中...'),
            error: (_, __) => const Text('エラー'),
          ),
          centerTitle: true,
          backgroundColor: tokens.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_isRunning) {
                _showExitConfirmation();
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettings,
            ),
          ],
        ),
        body: Column(
          children: [
            // モード切り替えタブ
            _buildModeSelector(tokens),

            // タイマー/ストップウォッチ表示
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (!_isRunning) {
                    setState(() {
                      _currentMode = TimerMode.values[index];
                      _currentDuration = Duration.zero;
                    });
                  }
                },
                children: [
                  _buildTimerView(tokens),
                  _buildStopwatchView(tokens),
                ],
              ),
            ),

            // コントロールボタン
            _buildControlButtons(tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(MinqTheme tokens) {
    return Container(
      margin: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: tokens.cornerLarge(),
      ),
      child: Row(
        children:
            TimerMode.values.map((mode) {
              final isSelected = _currentMode == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _switchMode(mode),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: tokens.spacing(3)),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? tokens.brandPrimary : Colors.transparent,
                      borderRadius: tokens.cornerLarge(),
                    ),
                    child: Text(
                      mode.displayName,
                      textAlign: TextAlign.center,
                      style: tokens.bodyMedium.copyWith(
                        color: isSelected ? Colors.white : tokens.textMuted,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTimerView(MinqTheme tokens) {
    final progress =
        _targetDuration.inSeconds > 0
            ? _currentDuration.inSeconds / _targetDuration.inSeconds
            : 0.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 円形プログレス
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景円
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.surfaceVariant,
                      ),
                    ),

                    // プログレス円
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          _isRunning && !_isPaused
                              ? Color.lerp(
                                tokens.brandPrimary,
                                tokens.brandPrimary.withValues(alpha: 0.6),
                                _pulseController.value,
                              )!
                              : tokens.brandPrimary,
                        ),
                      ),
                    ),

                    // 時間表示
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDuration(_targetDuration - _currentDuration),
                          style: tokens.displayMedium.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: tokens.spacing(2)),
                        Text(
                          '残り時間',
                          style: tokens.bodyMedium.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: tokens.spacing(6)),

          // 目標時間設定
          if (!_isRunning) _buildTimerSettings(tokens),
        ],
      ),
    );
  }

  Widget _buildStopwatchView(MinqTheme tokens) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ストップウォッチ表示
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.surfaceVariant,
              border: Border.all(
                color:
                    _isRunning && !_isPaused
                        ? tokens.brandPrimary
                        : tokens.border,
                width: 4,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDuration(_currentDuration),
                    style: tokens.displayMedium.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    '経過時間',
                    style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSettings(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Text(
            '目標時間',
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
          ),
          SizedBox(height: tokens.spacing(2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeButton(tokens, '5分', const Duration(minutes: 5)),
              SizedBox(width: tokens.spacing(2)),
              _buildTimeButton(tokens, '15分', const Duration(minutes: 15)),
              SizedBox(width: tokens.spacing(2)),
              _buildTimeButton(tokens, '25分', const Duration(minutes: 25)),
              SizedBox(width: tokens.spacing(2)),
              _buildTimeButton(tokens, '45分', const Duration(minutes: 45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(MinqTheme tokens, String label, Duration duration) {
    final isSelected = _targetDuration == duration;

    return GestureDetector(
      onTap: () {
        setState(() {
          _targetDuration = duration;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing(3),
          vertical: tokens.spacing(2),
        ),
        decoration: BoxDecoration(
          color: isSelected ? tokens.brandPrimary : Colors.transparent,
          borderRadius: tokens.cornerMedium(),
          border: Border.all(
            color: isSelected ? tokens.brandPrimary : tokens.border,
          ),
        ),
        child: Text(
          label,
          style: tokens.bodySmall.copyWith(
            color: isSelected ? Colors.white : tokens.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 停止ボタン
          if (_isRunning || _isPaused)
            _buildControlButton(
              tokens,
              icon: Icons.stop,
              label: '停止',
              color: Colors.red,
              onPressed: _stopTimer,
            ),

          // メインボタン（開始/一時停止/再開）
          _buildMainControlButton(tokens),

          // 完了ボタン
          if (_isRunning || _isPaused)
            _buildControlButton(
              tokens,
              icon: Icons.check,
              label: '完了',
              color: Colors.green,
              onPressed: _completeTimer,
            ),
        ],
      ),
    );
  }

  Widget _buildMainControlButton(MinqTheme tokens) {
    IconData icon;
    String label;
    VoidCallback onPressed;

    if (!_isRunning) {
      icon = Icons.play_arrow;
      label = '開始';
      onPressed = _startTimer;
    } else if (_isPaused) {
      icon = Icons.play_arrow;
      label = '再開';
      onPressed = _resumeTimer;
    } else {
      icon = Icons.pause;
      label = '一時停止';
      onPressed = _pauseTimer;
    }

    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.brandPrimary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            SizedBox(height: tokens.spacing(1)),
            Text(
              label,
              style: tokens.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    MinqTheme tokens, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            Text(
              label,
              style: tokens.bodySmall.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => _TimerSettingsSheet(
            currentDuration: _targetDuration,
            onDurationChanged: (duration) {
              setState(() {
                _targetDuration = duration;
              });
            },
          ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('タイマーを終了しますか？'),
            content: const Text('進行中のタイマーが停止されます。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _stopTimer();
                  context.pop();
                },
                child: const Text('終了'),
              ),
            ],
          ),
    );
  }
}

/// タイマー設定シート
class _TimerSettingsSheet extends StatefulWidget {
  const _TimerSettingsSheet({
    required this.currentDuration,
    required this.onDurationChanged,
  });

  final Duration currentDuration;
  final ValueChanged<Duration> onDurationChanged;

  @override
  State<_TimerSettingsSheet> createState() => _TimerSettingsSheetState();
}

class _TimerSettingsSheetState extends State<_TimerSettingsSheet> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.currentDuration.inHours;
    _minutes = widget.currentDuration.inMinutes.remainder(60);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'タイマー設定',
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: tokens.spacing(4)),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 時間選択
              Column(
                children: [
                  Text('時間', style: tokens.bodySmall),
                  SizedBox(
                    width: 80,
                    height: 120,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _hours = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              '$index',
                              style: tokens.titleMedium.copyWith(
                                color:
                                    index == _hours
                                        ? tokens.brandPrimary
                                        : tokens.textMuted,
                              ),
                            ),
                          );
                        },
                        childCount: 24,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: tokens.spacing(4)),

              // 分選択
              Column(
                children: [
                  Text('分', style: tokens.bodySmall),
                  SizedBox(
                    width: 80,
                    height: 120,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _minutes = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              '$index',
                              style: tokens.titleMedium.copyWith(
                                color:
                                    index == _minutes
                                        ? tokens.brandPrimary
                                        : tokens.textMuted,
                              ),
                            ),
                          );
                        },
                        childCount: 60,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: tokens.spacing(4)),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
              ),
              SizedBox(width: tokens.spacing(2)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final duration = Duration(hours: _hours, minutes: _minutes);
                    widget.onDurationChanged(duration);
                    Navigator.of(context).pop();
                  },
                  child: const Text('設定'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// タイマーモード
enum TimerMode {
  timer('タイマー'),
  stopwatch('ストップウォッチ');

  const TimerMode(this.displayName);
  final String displayName;
}
