import 'dart:async';
import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/app_theme.dart';

/// 繧ｯ繧ｨ繧ｹ繝医ち繧､繝槭・繧ｦ繧｣繧ｸ繧ｧ繝・ヨ
/// 鄙呈・螳溯｡梧凾縺ｮ繧ｿ繧､繝槭・讖溯・
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
          // 繧ｿ繧､繝槭・陦ｨ遉ｺ
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
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.primary),
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
          // 繧ｳ繝ｳ繝医Ο繝ｼ繝ｫ繝懊ち繝ｳ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning) ...[
                // 髢句ｧ九・繧ｿ繝ｳ
                _TimerButton(
                  icon: Icons.play_arrow,
                  label: '髢句ｧ・,
                  onPressed: _startTimer,
                  isPrimary: true,
                  tokens: tokens,
                ),
              ] else if (_isPaused) ...[
                // 蜀埼幕繝懊ち繝ｳ
                _TimerButton(
                  icon: Icons.play_arrow,
                  label: '蜀埼幕',
                  onPressed: _resumeTimer,
                  isPrimary: true,
                  tokens: tokens,
                ),
                SizedBox(width: tokens.spacing.md),
                // 繝ｪ繧ｻ繝・ヨ繝懊ち繝ｳ
                _TimerButton(
                  icon: Icons.refresh,
                  label: '繝ｪ繧ｻ繝・ヨ',
                  onPressed: _resetTimer,
                  tokens: tokens,
                ),
              ] else ...[
                // 荳譎ょ●豁｢繝懊ち繝ｳ
                _TimerButton(
                  icon: Icons.pause,
                  label: '荳譎ょ●豁｢',
                  onPressed: _pauseTimer,
                  tokens: tokens,
                ),
                SizedBox(width: tokens.spacing.md),
                // 螳御ｺ・・繧ｿ繝ｳ
                _TimerButton(
                  icon: Icons.check,
                  label: '螳御ｺ・,
                  onPressed: _completeTimer,
                  isPrimary: true,
                  tokens: tokens,
                ),
              ],
            ],
          ),
          if (widget.onCancel != null) ...[
            SizedBox(height: tokens.spacing.md),
            TextButton(
              onPressed: _cancelTimer,
              child: const Text('繧ｭ繝｣繝ｳ繧ｻ繝ｫ'),
            ),
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
      return '螳御ｺ・ｼ・;
    } else if (_isPaused) {
      return '荳譎ょ●豁｢荳ｭ';
    } else if (_isRunning) {
      return '螳溯｡御ｸｭ';
    } else {
      return '貅門ｙ螳御ｺ・;
    }
  }
}

/// 繧ｿ繧､繝槭・繝懊ち繝ｳ
class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final MinqTheme tokens;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? tokens.primary : tokens.surface,
        foregroundColor: isPrimary ? Colors.white : tokens.textPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.full),
          side: isPrimary ? BorderSide.none : BorderSide(color: tokens.border),
        ),
      ),
    );
  }
}

/// 繧ｿ繧､繝槭・逕ｻ髱｢・医ヵ繝ｫ繧ｹ繧ｯ繝ｪ繝ｼ繝ｳ・・
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
        backgroundColor: tokens.background.withValues(alpha: 0.9),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: QuestTimerWidget(
            durationMinutes: durationMinutes,
            onComplete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('繧ｿ繧､繝槭・螳御ｺ・ｼ・)),
              );
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

/// 繝昴Δ繝峨・繝ｭ繧ｿ繧､繝槭・
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
    final duration = _isWorkSession
        ? widget.workMinutes
        : (_currentSession % widget.sessionsUntilLongBreak == 0 && _currentSession > 0)
            ? widget.longBreakMinutes
            : widget.breakMinutes;

    return Column(
      children: [
        // 繧ｻ繝・す繝ｧ繝ｳ陦ｨ遉ｺ
        Container(
          padding: EdgeInsets.all(tokens.spacing.md),
          decoration: BoxDecoration(
            color: tokens.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(tokens.radius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isWorkSession ? Icons.work_outline : Icons.coffee_outlined,
                color: tokens.primary,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                _isWorkSession ? '菴懈･ｭ繧ｻ繝・す繝ｧ繝ｳ' : '莨第・',
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
        // 繧ｿ繧､繝槭・
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
