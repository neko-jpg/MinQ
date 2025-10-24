import 'dart:async';
import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// クエストタイマーウィジェット
/// 習慣実行時のタイマー機能
class QuestTimerWidget extends StatefulWidget {
  final int durationMinutes;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const QuestTimerWidget({
    super.key,
    required this.durationMinutes,
    this.onComplete,
    this.onCancel,
  });

  @override
  State<QuestTimerWidget> createState() => _QuestTimerWidgetState();
}

class _QuestTimerWidgetState extends State<QuestTimerWidget> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
    _startTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.durationMinutes * 60;
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
    });
    widget.onComplete?.call();
  }

  void _cancelTimer() {
    _timer?.cancel();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final progress = _remainingSeconds / (widget.durationMinutes * 60);

    return Container(
      padding: EdgeInsets.all(tokens.spacing.xl),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // タイマー表示
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: 1 - progress,
                  strokeWidth: 12,
                  backgroundColor: tokens.background,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: tokens.typography.h1.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    _getStatusText(),
                    style: tokens.typography.body.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          // コントロールボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning) ...[
                // 開始ボタン
                _TimerButton(
                  icon: Icons.play_arrow,
                  label: '開始',
                  onPressed: _startTimer,
                  isPrimary: true,
                ),
              ] else if (_isPaused) ...[
                // 再開ボタン
                _TimerButton(
                  icon: Icons.play_arrow,
                  label: '再開',
                  onPressed: _resumeTimer,
                  isPrimary: true,
                ),
                SizedBox(width: tokens.spacing.md),
                // リセットボタン
                _TimerButton(
                  icon: Icons.refresh,
                  label: 'リセット',
                  onPressed: _resetTimer,
                ),
              ] else ...[
                // 一時停止ボタン
                _TimerButton(
                  icon: Icons.pause,
                  label: '一時停止',
                  onPressed: _pauseTimer,
                ),
                SizedBox(width: tokens.spacing.md),
                // 完了ボタン
                _TimerButton(
                  icon: Icons.check,
                  label: '完了',
                  onPressed: _completeTimer,
                  isPrimary: true,
                ),
              ],
            ],
          ),
          if (widget.onCancel != null) ...[
            SizedBox(height: tokens.spacing.md),
            TextButton(onPressed: _cancelTimer, child: const Text('キャンセル')),
          ],
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getStatusText() {
    if (_remainingSeconds == 0) {
      return '完了！';
    } else if (_isPaused) {
      return '一時停止中';
    } else if (_isRunning) {
      return '実行中';
    } else {
      return '準備完了';
    }
  }
}

/// タイマーボタン
class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? tokens.brandPrimary : tokens.surface,
        foregroundColor: isPrimary ? Colors.white : tokens.textPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.xl),
          side: isPrimary ? BorderSide.none : BorderSide(color: tokens.border),
        ),
      ),
    );
  }
}

/// タイマー画面（フルスクリーン）
class QuestTimerScreen extends StatelessWidget {
  final String questTitle;
  final int durationMinutes;

  const QuestTimerScreen({
    super.key,
    required this.questTitle,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          questTitle,
          style: tokens.typography.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: tokens.background.withAlpha((255 * 0.9).round()),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: QuestTimerWidget(
            durationMinutes: durationMinutes,
            onComplete: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('タイマー完了！')));
              Navigator.of(context).pop(true);
            },
            onCancel: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
      ),
    );
  }
}

/// ポモドーロタイマー
class PomodoroTimerWidget extends StatefulWidget {
  final int workMinutes;
  final int breakMinutes;
  final int longBreakMinutes;
  final int sessionsUntilLongBreak;

  const PomodoroTimerWidget({
    super.key,
    this.workMinutes = 25,
    this.breakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsUntilLongBreak = 4,
  });

  @override
  State<PomodoroTimerWidget> createState() => _PomodoroTimerWidgetState();
}

class _PomodoroTimerWidgetState extends State<PomodoroTimerWidget> {
  int _currentSession = 0;
  bool _isWorkSession = true;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final duration =
        _isWorkSession
            ? widget.workMinutes
            : (_currentSession % widget.sessionsUntilLongBreak == 0 &&
                _currentSession > 0)
            ? widget.longBreakMinutes
            : widget.breakMinutes;

    return Column(
      children: [
        // セッション表示
        Container(
          padding: EdgeInsets.all(tokens.spacing.md),
          decoration: BoxDecoration(
            color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(tokens.radius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isWorkSession ? Icons.work_outline : Icons.coffee_outlined,
                color: tokens.brandPrimary,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                _isWorkSession ? '作業セッション' : '休憩',
                style: tokens.typography.body.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                '${_currentSession + 1}/${widget.sessionsUntilLongBreak}',
                style: tokens.typography.caption.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacing.lg),
        // タイマー
        QuestTimerWidget(
          durationMinutes: duration,
          onComplete: () {
            setState(() {
              if (_isWorkSession) {
                _currentSession++;
              }
              _isWorkSession = !_isWorkSession;
            });
          },
        ),
      ],
    );
  }
}
