import 'dart:async';
import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/ai/realtime_coach_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class AICoachOverlay extends ConsumerStatefulWidget {
  const AICoachOverlay({super.key, required this.child, this.questId});

  final Widget child;
  final String? questId;

  @override
  ConsumerState<AICoachOverlay> createState() => _AICoachOverlayState();
}

class _AICoachOverlayState extends ConsumerState<AICoachOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  StreamSubscription<CoachingMessage>? _messageSubscription;
  CoachingMessage? _currentMessage;
  Timer? _hideTimer;
  bool _isVisible = false;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startListening();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _messageSubscription?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startListening() {
    _messageSubscription = RealtimeCoachService.instance.messageStream.listen((
      message,
    ) {
      if (widget.questId == null || message.questId == widget.questId) {
        _showMessage(message);
      }
    });
  }

  void _showMessage(CoachingMessage message) {
    setState(() {
      _currentMessage = message;
      _isVisible = true;
      _isMinimized = false;
    });

    _slideController.forward();

    // メッセージタイプに応じてアニメーション
    if (message.type == CoachingMessageType.motivation ||
        message.type == CoachingMessageType.progress) {
      _pulseController.repeat(reverse: true);
    }

    // 自動非表示タイマー
    _hideTimer?.cancel();
    final hideDelay = _getHideDelay(message.type);
    _hideTimer = Timer(hideDelay, () {
      if (mounted) {
        _hideMessage();
      }
    });
  }

  Duration _getHideDelay(CoachingMessageType type) {
    switch (type) {
      case CoachingMessageType.start:
      case CoachingMessageType.completion:
        return const Duration(seconds: 8);
      case CoachingMessageType.intervention:
        return const Duration(seconds: 12);
      case CoachingMessageType.checkIn:
        return const Duration(seconds: 10);
      default:
        return const Duration(seconds: 6);
    }
  }

  void _hideMessage() {
    _pulseController.stop();
    _slideController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
          _currentMessage = null;
        });
      }
    });
  }

  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  void _dismissMessage() {
    _hideTimer?.cancel();
    _hideMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible && _currentMessage != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: _isMinimized ? _buildMinimizedCoach() : _buildFullCoach(),
            ),
          ),
      ],
    );
  }

  Widget _buildFullCoach() {
    final tokens = context.tokens;
    final message = _currentMessage!;

    return Container(
      margin: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getMessageColor(message.type),
            _getMessageColor(message.type).withAlpha((255 * 0.8).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: tokens.shadow.soft,
      ),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _pulseAnimation.value, child: child);
        },
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー
              Row(
                children: [
                  _buildCoachAvatar(message.type),
                  SizedBox(width: tokens.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AIコーチ',
                          style: tokens.typography.caption.copyWith(
                            color: Colors.white.withAlpha((255 * 0.8).round()),
                          ),
                        ),
                        Text(
                          _getMessageTypeLabel(message.type),
                          style: tokens.typography.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleMinimize,
                    icon: const Icon(Icons.minimize, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: _dismissMessage,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: tokens.spacing.md),

              // メッセージ
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(tokens.spacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Text(
                  message.message,
                  style: tokens.typography.body.copyWith(color: Colors.white),
                ),
              ),

              // アクションボタン（チェックインの場合）
              if (message.type == CoachingMessageType.checkIn) ...[
                SizedBox(height: tokens.spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildResponseButton(
                        '順調です',
                        Icons.thumb_up,
                        () => _respondToCheckIn('good'),
                      ),
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    Expanded(
                      child: _buildResponseButton(
                        '少し疲れました',
                        Icons.sentiment_neutral,
                        () => _respondToCheckIn('tired'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimizedCoach() {
    final tokens = context.tokens;
    final message = _currentMessage!;

    return Container(
      margin: EdgeInsets.all(tokens.spacing.lg),
      child: GestureDetector(
        onTap: _toggleMinimize,
        child: Container(
          padding: EdgeInsets.all(tokens.spacing.md),
          decoration: BoxDecoration(
            color: _getMessageColor(message.type),
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            boxShadow: tokens.shadow.soft,
          ),
          child: Row(
            children: [
              _buildCoachAvatar(message.type, size: 32),
              SizedBox(width: tokens.spacing.sm),
              Expanded(
                child: Text(
                  message.message,
                  style: tokens.typography.caption.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.expand_less, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoachAvatar(CoachingMessageType type, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.2).round()),
        shape: BoxShape.circle,
      ),
      child: Icon(_getMessageIcon(type), color: Colors.white, size: size * 0.6),
    );
  }

  Widget _buildResponseButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final tokens = context.tokens;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: tokens.typography.caption),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withAlpha((255 * 0.2).round()),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.sm,
          vertical: tokens.spacing.xs,
        ),
      ),
    );
  }

  Color _getMessageColor(CoachingMessageType type) {
    final tokens = context.tokens;

    switch (type) {
      case CoachingMessageType.start:
        return tokens.encouragement;
      case CoachingMessageType.motivation:
        return tokens.brandPrimary;
      case CoachingMessageType.checkIn:
        return tokens.serenity;
      case CoachingMessageType.progress:
        return tokens.joyAccent;
      case CoachingMessageType.finalSpurt:
        return tokens.warmth;
      case CoachingMessageType.completion:
        return tokens.encouragement;
      case CoachingMessageType.intervention:
        return Colors.orange;
    }
  }

  IconData _getMessageIcon(CoachingMessageType type) {
    switch (type) {
      case CoachingMessageType.start:
        return Icons.play_circle;
      case CoachingMessageType.motivation:
        return Icons.favorite;
      case CoachingMessageType.checkIn:
        return Icons.psychology;
      case CoachingMessageType.progress:
        return Icons.trending_up;
      case CoachingMessageType.finalSpurt:
        return Icons.rocket_launch;
      case CoachingMessageType.completion:
        return Icons.celebration;
      case CoachingMessageType.intervention:
        return Icons.support_agent;
    }
  }

  String _getMessageTypeLabel(CoachingMessageType type) {
    switch (type) {
      case CoachingMessageType.start:
        return 'セッション開始';
      case CoachingMessageType.motivation:
        return '励まし';
      case CoachingMessageType.checkIn:
        return 'チェックイン';
      case CoachingMessageType.progress:
        return '進捗確認';
      case CoachingMessageType.finalSpurt:
        return 'ラストスパート';
      case CoachingMessageType.completion:
        return '完了';
      case CoachingMessageType.intervention:
        return 'サポート';
    }
  }

  void _respondToCheckIn(String response) {
    // TODO: ユーザーの応答を記録・分析
    _dismissMessage();

    // 応答に基づいて追加のコーチングを提供
    if (response == 'tired') {
      Timer(const Duration(seconds: 2), () {
        RealtimeCoachService.instance.triggerEmergencyIntervention(
          'ユーザーが疲労を報告',
        );
      });
    }
  }
}

/// AIコーチ設定画面
class AICoachSettingsScreen extends ConsumerStatefulWidget {
  const AICoachSettingsScreen({super.key});

  @override
  ConsumerState<AICoachSettingsScreen> createState() =>
      _AICoachSettingsScreenState();
}

class _AICoachSettingsScreenState extends ConsumerState<AICoachSettingsScreen> {
  late CoachingSettings _settings;

  @override
  void initState() {
    super.initState();
    // TODO: 保存された設定を読み込み
    _settings = const CoachingSettings();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'AIコーチ設定',
          style: tokens.typography.h3.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: tokens.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本設定
            _buildSettingsSection('基本設定', [
              _buildSwitchTile(
                '音声コーチング',
                '音声でメッセージを読み上げます',
                _settings.enableVoice,
                (value) {
                  setState(() {
                    _settings = _settings.copyWith(enableVoice: value);
                  });
                },
              ),
              _buildSwitchTile(
                '触覚フィードバック',
                'メッセージ時に振動でお知らせします',
                _settings.enableHaptics,
                (value) {
                  setState(() {
                    _settings = _settings.copyWith(enableHaptics: value);
                  });
                },
              ),
              _buildSwitchTile(
                '緊急介入',
                '困難を感じた時にサポートメッセージを送信',
                _settings.enableEmergencyIntervention,
                (value) {
                  setState(() {
                    _settings = _settings.copyWith(
                      enableEmergencyIntervention: value,
                    );
                  });
                },
              ),
            ]),

            SizedBox(height: tokens.spacing.xl),

            // 音声設定
            if (_settings.enableVoice) ...[
              _buildSettingsSection('音声設定', [
                _buildSliderTile('読み上げ速度', _settings.voiceSpeed, 0.5, 1.5, (
                  value,
                ) {
                  setState(() {
                    _settings = _settings.copyWith(voiceSpeed: value);
                  });
                }),
                _buildSliderTile('音量', _settings.voiceVolume, 0.0, 1.0, (
                  value,
                ) {
                  setState(() {
                    _settings = _settings.copyWith(voiceVolume: value);
                  });
                }),
              ]),

              SizedBox(height: tokens.spacing.xl),
            ],

            // 頻度設定
            _buildSettingsSection('頻度設定', [
              _buildIntervalTile('励ましメッセージの間隔', _settings.motivationInterval, (
                value,
              ) {
                setState(() {
                  _settings = _settings.copyWith(motivationInterval: value);
                });
              }),
            ]),

            SizedBox(height: tokens.spacing.xl),

            // テスト機能
            _buildSettingsSection('テスト', [
              ListTile(
                title: Text(AppLocalizations.of(context)!.voiceTest),
                subtitle: Text(AppLocalizations.of(context)!.voiceTestSubtitle),
                trailing: const Icon(Icons.play_arrow),
                onTap: _testVoiceCoaching,
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.messageTest),
                subtitle: Text(AppLocalizations.of(context)!.messageTestSubtitle),
                trailing: const Icon(Icons.message),
                onTap: _testMessage,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tokens.typography.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tokens.spacing.md),
        Card(
          elevation: 0,
          color: tokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            side: BorderSide(color: tokens.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 20,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalTile(
    String title,
    Duration value,
    ValueChanged<Duration> onChanged,
  ) {
    final minutes = value.inMinutes;

    return ListTile(
      title: Text(title),
      subtitle: Text(AppLocalizations.of(context)!.intervalMinutes
        .replaceAll('{minutes}', minutes.toString())),
      trailing: DropdownButton<int>(
        value: minutes,
        items:
            [1, 3, 5, 10, 15, 30].map((min) {
              return DropdownMenuItem(
                value: min, 
                child: Text(AppLocalizations.of(context)!.minutesShort
                  .replaceAll('{minutes}', min.toString()))
              );
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(Duration(minutes: value));
          }
        },
      ),
    );
  }

  void _testVoiceCoaching() {
    // TODO: 音声テスト実装
  }

  void _testMessage() {
    // TODO: メッセージテスト実装
  }
}
